from aiohttp import ClientSession, ClientTimeout, DummyCookieJar, BasicAuth
from pandas import DataFrame
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_random
from typing import Dict

import json

class WQRequestService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service(logger) -> 'WQRequestService':
        if WQRequestService.__instance == None:
            WQRequestService(logger)
        return WQRequestService.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, logger):
        if WQRequestService.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            self.__session = self.__get_session()
            self.__logger = logger
            WQRequestService.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    @retry(
        retry = retry_if_exception_type(OSError),
        stop = stop_after_attempt(4),
        wait = wait_random(),
    )
    async def get(self, url: str, user: str = None, access_token: str = None) -> Dict:
        self.__check_session()
        auth = BasicAuth(login=user, password=access_token) if user is not None and access_token is not None else None
        async with self.__session.get(
                url,
                auth = auth,
        ) as resp:
            result = json.loads(await resp.text())
            return result

    ###############################################################################################
    async def get_df(self, url: str, user: str = None, access_token: str = None) -> DataFrame:
        result = await self.get(url, user, access_token)

        return self.__to_df(result)

    ###############################################################################################
    async def close_session(self):
        await self.__session.close()

    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################
    def __check_session(self) -> None:
        if self.__session.closed:
            self.__info('Client session closed. Requesting a new one.')
            self.__session = self.__get_session()

    ###############################################################################################
    def __get_session(self) -> ClientSession:
        return ClientSession(
            cookie_jar=DummyCookieJar(),
            raise_for_status=True,
            timeout=ClientTimeout(),
        )

    ###############################################################################################
    def __info(self, msg: str):
        if self.__logger is not None:
            self.__logger.info(msg)

    ###############################################################################################
    def __debug(self, msg: str):
        if self.__logger is not None:
            self.__logger.debug(msg)

    ###############################################################################################
    def __to_df(self, jsonData: Dict) -> DataFrame:
        columns = [col['label'] for col in jsonData['columns']]
        data = [tuple([row[col['field']] for col in jsonData['columns']]) for row in jsonData['data']]

        return DataFrame.from_records(data, columns=columns)




