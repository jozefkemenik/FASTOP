import asyncio
from aiohttp import ClientSession, ClientTimeout, DummyCookieJar, BasicAuth
from pandas import DataFrame
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_random
from typing import Dict, List

import json
import logging

class FpapiRequestService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service(logger) -> 'FpapiRequestService':
        if FpapiRequestService.__instance == None:
            FpapiRequestService(logger)
        return FpapiRequestService.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, logger):
        if FpapiRequestService.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            self.__session = self.__get_session()
            self.__logger = logger
            FpapiRequestService.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    @retry(
        retry = retry_if_exception_type(OSError),
        stop = stop_after_attempt(4),
        wait = wait_random(),
    )
    async def get(self, url: str, user: str = None, access_token: str = None) -> List:
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
    def __to_df(self, arrayData: List) -> DataFrame:
        return DataFrame.from_records(columns=arrayData[0], data=arrayData[1:])



logging.basicConfig()
logging.root.setLevel(logging.NOTSET)

async def main():
    service = FpapiRequestService.get_service(logging.getLogger(__name__))
    try:
        url = 'https://intragate.ec.europa.eu/fastop/fpapi/1.0/json/ameco/data?ds=current&key=BEL,AUT,POL.NPTD,NPCN.1,6....A&startPeriod=2010&endPeriod=2013'
        # url = 'https://intragate.ec.europa.eu/fastop/fpapi/1.0/json/ameco/data?ds=public&key=BEL,AUT,POL.NPTD,NPCN.1,6....A&startPeriod=2010&endPeriod=2013'
        # url = 'https://intragate.ec.europa.eu/fastop/fpapi/1.0/json/ameco/data?ds=restricted&key=BEL,AUT,POL.NPTD,NPCN.1,6....A&startPeriod=2010&endPeriod=2013'

        # get results as array
        # array = await service.get(url)
        # print(f'array: {array}')

        # transform to data-frame
        df = await service.get_df(url)
        print(f'df: {df}')

    finally:
        # close session
        await service.close_session()



asyncio.run(main())
