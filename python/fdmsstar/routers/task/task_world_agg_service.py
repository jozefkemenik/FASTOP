from asyncio import as_completed, gather
from logging import getLogger

from fdms.forecast_world_aggregation import forecast_world_aggregation
from fdms.config.variable_groups import FL_FSMR
from fastoplib import TaskParams

from .task_base_service import TaskBaseService


class TaskWorldAggService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 3
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def task_program(self):
        return forecast_world_aggregation

    @property
    def task_element(self):
        return 'world aggregation'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        input_df = dict()
        country_ids = []
        try:
            group_countries, set_country_status_result = await gather(
                self._shared.get_cty_group_countries(params.countryIds[0]),
                self._shared.set_country_status(params.countryIds[0], self._prepare_setCountryStatus(params)),
            )
            if set_country_status_result < 0:
                self._logger.error(f'Error resetting aggregation status for FDMS! Result = {set_country_status_result}')

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('pre_prod_a', self._shared.get_pre_prod_df(country_ids, 'A', FL_FSMR)),
                ('imf_weo', self._shared.get_imf_weo_df(country_ids)),
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
