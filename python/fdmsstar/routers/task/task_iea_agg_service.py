from asyncio import as_completed, gather
from logging import getLogger

from fastoplib import RoundKeys, TaskParams
from fdms.external_aggregation import external_assumption_aggregation

from .task_base_service import TaskBaseService


class TaskIeaAggService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 7
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def task_program(self):
        return external_assumption_aggregation

    @property
    def task_element(self):
        return 'iea aggregation'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        input_df = dict()
        country_ids = ['EA', 'EU', 'EUEXEA']
        try:
            accepted_storage, group_countries, set_country_status_result = await gather(
                self._shared.get_last_accepted_storage('AGG'),
                self._shared.get_cty_group_countries(params.countryIds[0]),
                self._shared.set_country_status(params.countryIds[0], self._prepare_setCountryStatus(params), 'fdmsie'),
            )
            self._logger.info(f'Using data from the latest accepted storage: {accepted_storage}')
            round_keys = RoundKeys(
                roundSid = accepted_storage.get('roundSid') or -1,
                storageSid = accepted_storage.get('storageSid') or -1,
            )
            if set_country_status_result < 0:
                self._logger.error(f'Error resetting aggregation status for FDMS! Result = {set_country_status_result}')

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_ph', self._shared.get_ameco_ph_df([])),
                ('ameco_h', self._shared.get_ameco_history_df([], use_latest = True)),
                ('forecast_eu', self._shared.get_pre_prod_df(country_ids, 'A', round_keys = round_keys)),
                ('forecast_non_eu', self._shared.get_pre_prod_df([], 'A', app_id = params.appId)),
                ('exchange_rate', self._shared.get_combined_exchange_rates_df([], True)),
                ('imf_weo', self._shared.get_imf_weo_df([])),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = group_countries
            await self._run_task(task_run_sid, params, input_df)

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
