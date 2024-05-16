from aiohttp import ClientSession, ClientTimeout, DummyCookieJar
from enum import Enum
from tenacity import retry, retry_if_exception_type, stop_after_attempt, wait_random
from typing import Dict

from logging import getLogger
from .config import apiKey

logger = getLogger(__name__)

Verbs = Enum('Verbs', 'GET POST PUT DELETE')
Formats = Enum('Formats', 'JSON XML BINARY')

class RequestService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service() -> 'RequestService':
        if RequestService.__instance is None:
            RequestService()
        return RequestService.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        if RequestService.__instance is not None:
            raise Exception("This class is a singleton!")
        else:
            self.__session = self.__get_session()
            RequestService.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    def get(self, node: str, route: str, format: Formats = Formats.JSON):
        return self.__send(node, route, Verbs.GET, None, format)

    ###############################################################################################
    def post(self, node: str, route: str, options: Dict, format: Formats = Formats.JSON, form_data = None, headers: Dict = None):
        return self.__send(node, route, Verbs.POST, options, format, form_data, headers)

    ###############################################################################################
    def put(self, node: str, route: str, options: Dict):
        return self.__send(node, route, Verbs.PUT, options)

    ###############################################################################################
    def delete(self, node: str, route: str, options: Dict = None):
        return self.__send(node, route, Verbs.DELETE, options)

    ###############################################################################################
    async def close_session(self):
        await self.__session.close()

    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################
    def __check_session(self) -> None:
        if self.__session.closed:
            logger.info('Client session closed. Requesting a new one.')
            self.__session = self.__get_session()

    ###############################################################################################
    def __get_session(self) -> ClientSession:
        return ClientSession(
            cookie_jar=DummyCookieJar(),
            raise_for_status=True,
            timeout=ClientTimeout(),
        )

    ###############################################################################################
    @retry(
        retry = retry_if_exception_type(OSError),
        stop = stop_after_attempt(4),
        wait = wait_random(),
    )
    async def __send(
            self, node: str, route: str, verb: Verbs,
            options: Dict = None, format: Formats = Formats.JSON, form_data = None, additional_headers: Dict = None
    ):
        self.__check_session()
        methods = {
            Verbs.GET: self.__session.get,
            Verbs.POST: self.__session.post,
            Verbs.PUT: self.__session.put,
            Verbs.DELETE: self.__session.delete,
        }
        headers = {'apiKey': apiKey, 'internal': 'true'}
        headers.update(additional_headers if additional_headers is not None else {})
        async with methods.get(verb)(
            node + route,
            headers = headers,
            json = options,
            data = form_data,
        ) as resp:
            if format == Formats.JSON: result = resp.json()
            elif format == Formats.XML: result = resp.text()
            elif format == Formats.BINARY: result = resp.read()

            return await result
