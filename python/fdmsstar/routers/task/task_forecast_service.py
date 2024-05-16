from asyncio import as_completed, gather
from logging import getLogger

from fastoplib import TaskParams
from fdms.forecast_calculation import forecastCalculation

from .task_base_service import TaskBaseService


class TaskForecastService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 12
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def task_program(self):
        return forecastCalculation

    @property
    def task_element(self):
        return 'Calculation'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):

        input_df = dict()
        country_ids = params.countryIds
        country_ids_with_US = list(set(country_ids + ['US']))
        try:
            forecast_indicators, set_country_status_result = await gather(
                self._get_forecast_indicators(),
                self._shared.set_country_status('AGG', self._prepare_setCountryStatus(params)),
            )
            if set_country_status_result < 0:
                self._logger.error(
                    f'Error resetting aggregation status for FDMS! Result = {set_country_status_result}'
                )

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_ph', self._shared.get_ameco_ph_df(country_ids_with_US)),
                ('ameco_h', self._shared.get_ameco_history_df(country_ids_with_US)),
                ('b1', self._shared.get_b1_df(country_ids)),
                ('country_desk_a', self._shared.get_cty_desk_input_df(country_ids, 'A')),
                ('country_desk_q', self._shared.get_cty_desk_input_df(country_ids, 'Q')),
                ('exchange_rate', self._shared.get_combined_exchange_rates_df(country_ids_with_US)),
                ('eurostat_q', self._shared.get_eurostat_df(country_ids, 'Q')),
                ('eurostat_m', self._shared.get_eurostat_df(country_ids, 'M')),
                ('cyclical_adjustment', self._shared.get_cyclical_adjustments_df(country_ids)),
                ('covid_measures', self._shared.get_covid_df(country_ids)),
                ('eucam_full', self._shared.get_eucam_full_df(country_ids)),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = country_ids
            await self._run_task(
                task_run_sid,
                params,
                input_df,
                forecast_indicators = forecast_indicators,
                country_group = country_ids,
            )

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
