from fastapi import Request
from logging import getLogger
import os

import tempfile
import aiofiles


class FileUploadService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    ###############################################################################################
    @staticmethod
    def prepare_temp_folder() -> str:
        """
        Create temporary directory where uploaded files will be stored.
        :return: full folder path
        """

        return tempfile.mkdtemp()

    ###############################################################################################
    @staticmethod
    def get_temp_folder_path() -> str:
        """
        Get main temporary folder path.
        :return: full folder path
        """

        return tempfile.gettempdir()

    ###############################################################################################
    ##################################### Singleton ###############################################
    ###############################################################################################
    def __new__(cls):
        if cls.__instance is None:
            cls.__instance = super().__new__(cls)
            cls.__instance.__init__()
        return cls.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self.__logger = getLogger(__name__)

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    def get_upload_file_name(self, request: Request) -> str:
        """
        Extract the file name from request header
        :param request: FastApi.Request
        :return: file name
        """
        return request.headers.get('Original-File-Name')

    ###############################################################################################
    async def save_request_stream_to_file(self, folder_path: str, request: Request) -> str:
        """
        Upload files for given upload task id. Folder location is stored in database.
        File is sent as binary stream, original file name is sent in header: 'Original-File-Name'
        :param folder_path: destination folder path
        :param request: FastApi.Request
        :return: path to the saved file
        """

        original_name = self.get_upload_file_name(request)

        if not os.path.exists(folder_path):
            raise Exception(f"Upload folder doesn't exist: {folder_path}!")

        file_path = os.path.normpath(os.path.join(folder_path, original_name))
        async with aiofiles.open(file_path, 'wb') as f:
            async for chunk in request.stream():
                await f.write(chunk)

        return file_path
