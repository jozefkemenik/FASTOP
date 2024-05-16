import asyncio
import aiofiles
import logging
import os
import glob
from typing import Dict, List

logging.basicConfig()
logging.root.setLevel(logging.NOTSET)

from fastoplib.request_service import Formats, RequestService


class FplakeApiService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    ###############################################################################################
    ##################################### Singleton ###############################################
    ###############################################################################################
    def __new__(cls, lake_manager_url: str):
        if cls.__instance is None:
            cls.__instance = super().__new__(cls)
            cls.__instance.__init__(lake_manager_url)
        return cls.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, lake_manager_url: str):
        self.__lake_manager_url = lake_manager_url
        if self.__lake_manager_url is None:
            raise Exception('Lake manager url is missing!')

        self.__logger = logging.getLogger(__name__)
        self.__request = RequestService.get_service()

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def publish_files(self, provider: str, dataflow: str, files_folder: str):
        """
        Publish parquet files to fplake
        :param provider: provider name ('ecfin' by default)
        :param dataflow: fmr dataflow id
        :param files_folder: full path to folder with .parquet files
        :return:
        """

        self.__logger.info(f'Calling lake manager url: {self.__lake_manager_url}')

        lake_host = await self.__get_lake_host(provider, dataflow)

        self.__logger.info(f'Preparing upload folder at lake url: {lake_host}')
        lake_folder = await self.__prepare_publication(lake_host, provider, dataflow)

        try:

            if not os.path.exists(files_folder):
                raise Exception(f"Files folder doesn't exist! Path: {files_folder}")

            files = await self.__upload_files(files_folder, lake_host, lake_folder)
            await self.__publish(lake_host, lake_folder)

            self.__logger.info(f'Published files: {",".join(files)} to {lake_host}')

        except Exception as ex:
            raise ex
        finally:
            await self.__cleanup_publication(lake_host, lake_folder)


    ###############################################################################################
    async def close_session(self):
        """
        Close aiohttp session
        :return:
        """
        await self.__request.close_session()

    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################

    ###############################################################################################
    async def __upload_files(self, parquet_dir: str, lake_host: str, lake_tmp_folder: str) -> List[str]:
        """
        Upload .parquest files to given lake_host and folder identified by lake_tmp_folder name
        :param parquet_dir: Full path to folder with .parquet files
        :param lake_host: lake url address
        :param lake_tmp_folder: folder name at the lake host (just folder name, not the full path)
        :return:
        """

        try:
            parquet_files = glob.glob(f'{parquet_dir}/*.parquet')

            async with asyncio.TaskGroup() as group:
                tasks = [
                    group.create_task(
                        self.__upload_file(file_path, lake_host, lake_tmp_folder),
                        name=os.path.basename(file_path)
                    ) for file_path in parquet_files
                ]
        except Exception as ex:
            self.__logger.error(f'Exception in fplake upload tasks group: {ex}!')
            raise Exception(f'Internal error when uploading files to fplake: {lake_host}')

        # each task returns http status code, if file was uploaded the returned http code is 201
        failed_tasks = [task for task in tasks if task.exception() or task.result() < 200 or task.result() > 299]

        if len(failed_tasks) > 0:
            task_names = ','.join([task.get_name() for task in failed_tasks])
            raise Exception(f'Failed to transfer file(s): {task_names} to fplake: {lake_host}!')

        return [task.get_name() for task in tasks]

    ###############################################################################################
    async def __upload_file(self, file_path: str, lake_host: str, lake_tmp_folder: str):
        """
        Stream single file to lake host
        :param file_path: full path to file that will be streamed.
        :param lake_host: url address of the lake service
        :param lake_tmp_folder: folder name on lake host machine where the uploaded file will be stored
        :return:
        """

        self.__logger.info(f'Uploading file: {file_path} to fplake: {lake_host}, tmp lake folder: {lake_tmp_folder}')

        async with aiofiles.open(file_path, 'rb') as file:
            return await self.__request.post(
                lake_host, f'/publication/upload/{lake_tmp_folder}', None, Formats.JSON, file,
                {
                    'Content-Type': 'application/octet-stream',
                    'Original-File-Name': os.path.basename(file.name)
                }
            )

    ###############################################################################################
    async def __publish(self, lake_host: str, lake_tmp_folder: str):
        """
        Publish files stored at lake_tmp_service at lake service.
        Publication on fplake means:
        - backup current .parquet files
        - copy new .parquest files
        - reinitialize fplake (reinit duckDb)
        - cleanup the lake_tmp_folder
        :param lake_host: url address of the lake service
        :param lake_tmp_folder: folder name on lake host machine where the uploaded file will be stored
        :return:
        """
        response = await self.__request.put(lake_host, f'/publication/{lake_tmp_folder}', {})
        if response != 200:
            raise Exception(f'Failed to publish data on fplake: {lake_host} from upload folder: {lake_tmp_folder}!')

    ###############################################################################################
    async def __get_lake_host(self, provider: str, dataset: str) -> str:
        """
        Get url address of fplake service that serves data for given provider and dataset (fmr dataflow id)
        :param provider: provider name ('ecfin' is default)
        :param dataset: FMR dataflow id
        :return:
        """
        return await self.__request.get(self.__lake_manager_url, f'/lake/url/{provider}/{dataset}')

    ###############################################################################################
    async def __prepare_publication(self, lake_host: str, provider: str, dataset: str):
        """
        Prepare the folder for uploading .parquet files on given lake host machine.
        :param lake_host: url address of the lake service
        :param provider: provider name ('ecfin' is default)
        :param dataset: FMR dataflow id
        :return: Temporary folder name. Folder name is combination of random characters, provider and dataset.
        """
        return await self.__request.put(
            lake_host, f'/publication/prepare', {'provider': provider, 'dataset': dataset}
        )

    ###############################################################################################
    async def __cleanup_publication(self, lake_host: str, lake_tmp_folder: str):
        """
        Delete the temporary folder (lake_tmp_folder) containing uploaded .parquet files
        :param lake_host: url address of the lake service
        :param lake_tmp_folder: folder name on lake host machine where the uploaded file will are stored
        :return:
        """

        try:
            response = await self.__request.delete(lake_host, f'/publication/{lake_tmp_folder}')
            if response != 200:
                raise Exception(f'Publication delete request returned unexpected response: {response}.')
        except Exception as ex:
            self.__logger.error(
                f'Failed to cleanup the publication tmp folder: {lake_tmp_folder} on host: {lake_host}: {ex}!'
            )


async def main():
    lake_service = FplakeApiService('http://localhost:3510')
    try:
        await lake_service.publish_files('ecfin', 'BDE', r'C:\tmp\parquet')
    finally:
        await lake_service.close_session()


asyncio.run(main())
