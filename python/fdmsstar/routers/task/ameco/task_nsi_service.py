from abc import ABC
from logging import getLogger
import time
from typing import List, Tuple, Set, Dict

from fastoplib import AmecoNsiIndicator, TaskParams, TaskAbortError
from fastoplib.config import amecoService
from fastoplib.request_service import RequestService
from fastoplib.task_client import TaskClient

from ...shared.shared_service import SharedService
from ..task_db_service import TaskDbService

class TaskNSIService(ABC):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self.__task = TaskClient.get_service()
        self.__request = RequestService.get_service()
        self.__db = TaskDbService.get_service()
        self.__shared = SharedService.get_service()
        self.__task_configs = {
            'AMECO-NSI': {
                'function': self.__calculate_nsi, 'provider': 'NSI_RSLTS', 'periodicity': 'A',
            },
        }
        self.__config = None

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def prepare_task(self, app_id: str, task_id: str, country_ids: List[str], user: str) -> int:
        steps = 1
        self.__config = self.__task_configs[task_id]
        return await self.__task.prepare_task(app_id, task_id, country_ids, steps, user)

    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        service_function = self.__config.get('function')
        await service_function(task_run_sid, params)

    ###############################################################################################
    #################################### Private Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def __calculate_nsi(self, task_run_sid: int, params: TaskParams):
        periodicity = self.__config.get('periodicity')
        try:
            country_ids = await self.__prepare_country_ids(
                params.appId, task_run_sid, params.countryIds
            )

            await self.__task.add_concurrent_steps(params.appId, task_run_sid, 2)
            nsk_data = await self.__process_nsk_data(country_ids, params.appId, task_run_sid, 1)

            await self.__finish_task(params.appId, task_run_sid, 2, periodicity, nsk_data, params.user)
        except Exception as e:
            await self.__task.error_task(params.appId, task_run_sid, e)
            raise (e)

    ###############################################################################################
    async def __prepare_country_ids(
            self, app_id: str, task_run_sid: int, param_cty_ids: List[str]
    ) -> List[str]:
        country_ids = param_cty_ids if param_cty_ids[0] != 'NSI' else \
            await self.__shared.get_cty_group_countries(param_cty_ids[0])
        await self.__task.add_prep_step(app_id, task_run_sid)
        return country_ids

    ###############################################################################################
    async def __process_nsk_data(
            self, country_ids: List[str], app_id: str, task_run_sid: int, step: int
    ) -> List[AmecoNsiIndicator]:
        start_time = time.time()
        nsi_data = [AmecoNsiIndicator.from_dict(dict_data) for dict_data in (await self.__call_ameco(country_ids))]

        await self.__task.log_step(
            app_id, task_run_sid, step, 0, 'DONE', '', 'FETCHED NSI DATA FOR: ' + ','.join(country_ids),
            'Took {:.2f}s'.format(time.time() - start_time)
        )
        return nsi_data

    ###############################################################################################
    async def __call_ameco(self, country_ids: List[str]) -> Dict:
        return await self.__request.get(amecoService, '/calc/nsi?country_ids=' + ','.join(country_ids))

    ###############################################################################################
    async def __finish_task(
            self, app_id: str, task_run_sid: int, total_steps: int,
            periodicity: str, results: List[AmecoNsiIndicator], user: str
    ):
        await self.__save_result(app_id, task_run_sid, total_steps, periodicity, results, user)
        await self.__task.finish_task(app_id, task_run_sid, total_steps, 'DONE')

    ###############################################################################################
    async def __save_result(
            self, app_id: str, task_run_sid: int, step: int,
            periodicity: str, indicators: List[AmecoNsiIndicator], user: str
    ) -> int:
        self._logger.debug(f'Save {len(indicators)} ameco NSI indicators')

        status = 'DONE'
        message = ''
        try:
            saved = 0
            await self.__task.log_step(app_id, task_run_sid, step, 0, 'SAVING')

            for ind in indicators:
                time_series = [','.join(d.series) for d in ind.data]
                orders = [d.order for d in ind.data]

                res = await self.__db.save_ameco_nsi_indicator_data(
                    ind.nsi_id, ind.country_id, ind.table, periodicity, ind.start_year, time_series, orders, user
                )
                if res < 0:
                    self._logger.error(
                        f'Error saving ameco NSI indicator: {ind.nsi_id} for country {ind.country_id}: {res}!')
                    raise Exception(f'Error saving ameco NSI indicator: {ind.nsi_id}!')
                saved += res

            message = 'Saved ameco NSI indicators:\n' + '\n'.join([i.nsi_id for i in indicators])
            self._logger.debug(f'Saved ameco NSI indicators: {saved}')
        except TaskAbortError:
            status = 'ABORT'
        except BaseException as err:
            self._logger.error(f'Error saving ameco NSI indicators, results: {saved}, err: {err}')
            message = f'ERROR: Saving NSI indicators in the database has failed!\n'
            status = 'ERROR'
        finally:
            await self.__task.log_step(app_id, task_run_sid, step, 0, status, '', 'SAVED NSI DATA', message)

