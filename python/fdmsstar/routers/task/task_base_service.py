from abc import ABC, abstractmethod
from asyncio import gather, get_running_loop
from typing import Any, Dict, List
from functools import partial

from pandas import DataFrame

from fastoplib import RoundKeys, SetCountryStatus, TaskParams
from fastoplib.executor_service import ExecutorService
from fastoplib.task_client import TaskClient
from ..shared.shared_service import SharedService

from . import Save
from .task_db_service import TaskDbService
from .task_worker_single import run_worker_task


class TaskBaseService(ABC):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._loop = get_running_loop()
        self._task = TaskClient.get_service()
        self._db = TaskDbService.get_service()
        self._shared = SharedService.get_service()
        # cache
        self.__forecast_indicators = None

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def concurrency(self): return 1

    @property
    def executor(self):
        return ExecutorService.get_executor()

    @property
    @abstractmethod
    def task_program(self): pass

    @property
    @abstractmethod
    def task_element(self) -> str: pass

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    @abstractmethod
    async def run_task(self, task_run_sid: int, params: TaskParams): pass

    ###############################################################################################
    def prepare_task(self, app_id: str, task_id: str, country_ids: List[str], user: str) -> int:
        return self._task.prepare_task(app_id, task_id, country_ids, self._prep_steps, user, self.concurrency)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
    async def _get_forecast_indicators(self):
        if self.__forecast_indicators is None:
            data = await self._db.get_indicator_codes()
            self.__forecast_indicators = [row[0] for row in data]
        return self.__forecast_indicators

    ###############################################################################################
    def _prepare_setCountryStatus(self, params: TaskParams) -> SetCountryStatus:
        round_keys = RoundKeys(roundSid = params.roundSid, storageSid = params.storageSid)
        return SetCountryStatus(newStatusId = 'ACTIVE', userId = params.user, roundKeys = round_keys)

    ###############################################################################################
    async def _run_task(self,
        task_run_sid: int,
        params: TaskParams,
        input_df: Dict[str, DataFrame],
        save=Save.CALCULATION,
        **kwargs: Any
    ):
        task_input = await self._loop.run_in_executor(self.executor,
            partial(self.task_program.prepare_input,
            input_df,
            (params.year, params.period),
            **kwargs),
        )
        await self._task.add_prep_step(params.appId, task_run_sid)

        await gather(*[self._loop.run_in_executor(None, # self.executor,
            partial(run_worker_task,
            task_run_sid,
            params,
            self.task_element,
            self.task_program,
            [country for idx, country in enumerate(params.countryIds) if idx % self.concurrency == worker],
            task_input,
            self._loop,
            save,
            **kwargs),
        ) for worker in range(self.concurrency)])
