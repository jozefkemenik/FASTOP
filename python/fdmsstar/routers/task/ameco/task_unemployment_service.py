from abc import ABC
from logging import getLogger
import time
from typing import List, Tuple, Set, Dict

from fastoplib import TaskParams, TaskAbortError, AmecoIndicator, UnemploymentData
from fastoplib.config import amecoService
from fastoplib.indicator_utils import normalize_vector, str_to_float
from fastoplib.request_service import RequestService
from fastoplib.task_client import TaskClient

from ...shared.shared_service import SharedService
from ..task_db_service import TaskDbService

class TaskUnemploymentService(ABC):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self.__db = TaskDbService.get_service()
        self.__task = TaskClient.get_service()
        self._request = RequestService.get_service()
        self.__shared = SharedService.get_service()
        self.__task_configs = {
            'AMECO-UNEMPLOYMENT': {
                'function': self.__calculate_unemployment, 'provider': 'UEP_RSLTS', 'periodicity': 'A',
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
    async def __calculate_unemployment(self, task_run_sid: int, params: TaskParams):
        periodicity = self.__config.get('periodicity')
        provider = self.__config.get('provider')
        try:
            historical = await self.__get_unemployment_data(params.appId, task_run_sid, provider, periodicity)

            await self.__task.add_concurrent_steps(params.appId, task_run_sid, 2)
            unempl_data = await self.__process_unemployment_data(params.appId, task_run_sid, 1)

            await self.__finish_task(task_run_sid, 2, unempl_data, historical, provider, periodicity, params)
        except Exception as e:
            await self.__task.error_task(params.appId, task_run_sid, e)
            raise (e)

    ###############################################################################################
    async def __process_unemployment_data(
            self, app_id: str, task_run_sid: int, step: int
    ) -> UnemploymentData:
        start_time = time.time()
        unempl_data = UnemploymentData.from_dict(await self.__call_ameco())

        await self.__task.log_step(
            app_id, task_run_sid, step, 0, 'DONE', '', 'CALCULATED UNEMPLOYMENT INDICATORS',
            'Took {:.2f}s'.format(time.time() - start_time)
        )

        return unempl_data

    ###############################################################################################
    async def __call_ameco(self) -> Dict:
        return await self._request.get(amecoService, f'/calc/unemployment')

    ###############################################################################################
    async def __finish_task(
            self, task_run_sid: int, total_steps: int, unempl_data: UnemploymentData, historical: Dict,
            provider: str, periodicity: str, params: TaskParams
    ):
        await self.__save_result(task_run_sid, total_steps, unempl_data, historical, provider, periodicity, params)
        await self.__task.finish_task(params.appId, task_run_sid, total_steps, 'DONE')

    ###############################################################################################
    async def __save_result(
            self, task_run_sid: int, step: int, unempl_data: UnemploymentData, historical: Dict,
            provider: str, periodicity: str, params: TaskParams
    ) -> int:
        indicators = unempl_data.indicators
        self._logger.debug(f'Save ameco {len(indicators)} indicators')

        status = 'DONE'
        message = ''
        try:
            saved = 0
            await self.__task.log_step(params.appId, task_run_sid, step, 0, 'SAVING')
            await self.__save_source_dictionary(unempl_data.dictionary)

            for indicator in indicators:
                indicator_id = indicator.indicator_id
                start_year = indicator.start_year
                country_ids, time_series, hst_time_series, src_time_series, level_time_series = [], [], [], [], []
                for country_data in indicator.country_data:
                    country_id = country_data.country_id
                    series = country_data.series
                    historical_vector = historical.get(self.__get_ind_key(country_id, indicator_id))

                    country_ids.append(country_id)
                    time_series.append(','.join(series))
                    src_time_series.append(','.join(country_data.sources))
                    level_time_series.append(','.join(country_data.levels))
                    hst_time_series.append(
                        ','.join(
                            [str(v) for v in self.__normalize_vector(
                                historical_vector, start_year, len(series), periodicity
                            )]
                        )
                    )

                res = await self.__db.save_ameco_indicator_data(
                    provider, indicator_id, indicator.periodicity,
                    start_year, country_ids, time_series, hst_time_series,
                    src_time_series, level_time_series, params.user
                )
                if res < 0:
                    self._logger.error(
                        f'Error saving ameco indicator: {indicator_id} for {provider} provider: {res}!')
                    raise Exception(f'Error saving ameco indicator: {indicator_id}!')
                saved += res

            message = 'Saved ameco indicators:\n' + '\n'.join([i.indicator_id for i in indicators])
            self._logger.debug(f'Saved ameco indicators: {saved}')
        except TaskAbortError:
            status = 'ABORT'
        except BaseException as err:
            self._logger.error(f'Error saving ameco indicators for provider {provider}, results: {saved}, err: {err}')
            message = f'ERROR: Saving ameco indicators in the database has failed!\n'
            status = 'ERROR'
        finally:
            await self.__task.log_step(params.appId, task_run_sid, step, 0, status, '', 'SAVED AMECO INDICATORS', message)

    ###############################################################################################
    async def __get_unemployment_data(
            self, app_id: str, task_run_sid: int, provider: str, periodicity: str
    ) -> Dict:
        data = await self.__db.get_ameco_indicator_data(provider, periodicity, ['NECN', 'NETD', 'NETN', 'NUTN', 'ZUTN'])
        data_dict = {self.__get_ind_key(row[0], row[1]): {
            'start_year': row[3], 'vector': [str_to_float(v) for v in row[4].split(',')]
        } for row in data}
        await self.__task.add_prep_step(app_id, task_run_sid)

        return data_dict

    ###############################################################################################
    def __get_ind_key(self, country_id: str, indicator_id: str) -> str:
        return f'{country_id}_{indicator_id}'

    ###############################################################################################
    def __normalize_vector(
            self, historical_vector: Dict, new_start_year: int, new_length: int, periodicity: str,
    ) -> List[float]:
        return normalize_vector(
            historical_vector.get('start_year'), historical_vector.get('vector'),
            new_start_year, new_length, periodicity,
        ) if historical_vector is not None else []

    ###############################################################################################
    async def __save_source_dictionary(self, dictionary: Dict[str, int]):
        return await self.__db.save_ameco_input_source(list(dictionary.values()), list(dictionary.keys()))
