from asyncio import as_completed, gather
from logging import getLogger
from typing import List
from pandas import DataFrame

from fastoplib import TaskParams
from fdms.forecast_tce_calculation import forecast_TCE

from . import Save
from .task_base_service import TaskBaseService


class TaskTceService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 5
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def task_program(self):
        return forecast_TCE

    @property
    def task_element(self):
        return 'TCE'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        # params.countryIds contains only one country group: 'TCE'
        input_df = dict()
        try:
            group_countries, set_country_status_result = await gather(
                self._shared.get_cty_group_countries(params.countryIds[0]),
                self._shared.set_country_status(
                    params.countryIds[0], self._prepare_setCountryStatus(params)
                ),
            )
            if set_country_status_result < 0:
                self.__logger.error(
                    f'Error resetting TCE status for FDMS! Result = {set_country_status_result}'
                )

            for name_and_future in as_completed(
                [self._shared.zip_future_with_name(name, future) for name, future in [
                    ('forecast_a', self._shared.get_forecast_df(
                            [], 'A',
                            ['OMGN', 'OMSN', 'OXGN', 'OXSN', 'UMGN', 'UMSN', 'UXGN', 'UXSN',
                            'XNU.1.0.30.0', 'XNE.1.0.99.0']
                        )
                    ),
                    ('ameco_h', self._shared.get_ameco_history_df(
                            group_countries, ['OMGN.1.1.0.0', 'OMSN.1.1.0.0', 'OXGN.1.1.0.0',
                                              'OXSN.1.1.0.0', 'UMGN.1.1.0.0', 'UMSN.1.1.0.0',
                                              'UXGN.1.1.0.0', 'UXSN.1.1.0.0']
                        )
                    ),
                    ('export_values_usd_goods', self.__get_tce_matrix_data(group_countries, 'TCE_GDS')),
                    ('export_values_usd_services', self.__get_tce_matrix_data(group_countries, 'TCE_SRVCS')),
                ]
             ]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = group_countries
            await self._run_task(
                task_run_sid,
                params,
                input_df,
                Save.TCE,
                country_group = group_countries,
            )

        except Exception as e:
            await self._task.error_task(params.taskId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    async def __get_tce_matrix_data(self, country_ids: List[str], provider_id: str) -> DataFrame:
        data = await self._db.get_tce_matrix_data(provider_id)
        return self.__tce_data_to_df(data, country_ids)

    ###############################################################################################
    def __tce_data_to_df(self, data, country_ids: List[str]) -> DataFrame:
        result = DataFrame(index=country_ids, columns=country_ids)
        country_set = set(country_ids)
        for row in data:
            if row[0] in country_set and row[1] in country_set:
                result.at[row[0], row[1]] = row[2]
        return result

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
