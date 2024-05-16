from asyncio import as_completed, gather
from logging import getLogger

from fastoplib import TaskParams
from fdms.forecast_eu_aggregation import forecastEuAggregation

from .task_base_service import TaskBaseService


class TaskEuAggService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 11
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def concurrency(self): return 1

    @property
    def task_program(self):
        return forecastEuAggregation

    @property
    def task_element(self):
        return 'EU aggregation'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        input_df = dict()
        try:
            country_ids, group_countries, set_country_status_result = await gather(
                self._shared.get_cty_group_countries('EU'),
                self._shared.get_cty_group_countries(params.countryIds[0]),
                self._shared.set_country_status(params.countryIds[0], self._prepare_setCountryStatus(params))
            )
            country_ids += ['UK', 'US']
            if set_country_status_result < 0:
                self._logger.error(f'Error resetting aggregation status for FDMS! Result = {set_country_status_result}')

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_ph', self._shared.get_ameco_ph_df(country_ids + group_countries)),
                ('ameco_h', self._shared.get_ameco_history_df(country_ids + group_countries)),
                ('desk_a', self._shared.get_cty_desk_input_df(country_ids, 'A')),
                ('desk_q', self._shared.get_cty_desk_input_df(country_ids, 'Q')),
                ('pre_prod_a', self._shared.get_pre_prod_df(country_ids, 'A')),
                ('pre_prod_q', self._shared.get_pre_prod_df(country_ids, 'Q')),
                ('eurostat_a', self._shared.get_eurostat_df(country_ids + group_countries + ['EU_ADJ', 'EA_ADJ'], 'A')),
                ('eurostat_q', self._shared.get_eurostat_df(country_ids + group_countries, 'Q')),
                ('eurostat_m', self._shared.get_eurostat_df(country_ids + group_countries, 'M')),
                ('exchange_rate', self._shared.get_combined_exchange_rates_df(country_ids + group_countries)),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = [group for group in group_countries if group.startswith(('EA', 'EU', 'XU'))]
            await self._run_task(task_run_sid, params, input_df)

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
