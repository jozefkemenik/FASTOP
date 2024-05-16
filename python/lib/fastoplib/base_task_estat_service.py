from abc import ABC, abstractmethod
from asyncio import get_running_loop
from typing import List

from . import TaskParams
from .config import sdmxService
from .request_service import RequestService
from .task_client import TaskClient


class BaseTaskEstatService(ABC):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._loop = get_running_loop()
        self._task = TaskClient.get_service()
        self._request = RequestService.get_service()

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    @abstractmethod
    async def run_task(self, task_run_sid: int, params: TaskParams): pass

    ###############################################################################################
    @abstractmethod
    async def prepare_task(self, app_id: str, task_id: str, country_ids: List[str], user: str) -> int:
        pass

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################

    ###############################################################################################
    async def _call_sdmx(self, dataset: str, key: str, force_json: bool = False):
        return await self._request.get(
            sdmxService, f'/estat/series/{dataset.lower()}/{key.upper()}?force_json={force_json}'
        )
