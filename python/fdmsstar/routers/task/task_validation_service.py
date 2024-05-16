from asyncio import as_completed, gather
from logging import getLogger

from fastoplib import TaskParams
from fdms.forecast_validation import forecastValidation

from . import Save
from .task_base_service import TaskBaseService


class TaskValidationService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 6
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def task_program(self):
        return forecastValidation

    @property
    def task_element(self):
        return 'Validation'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):

        input_df = dict()
        country_ids = params.countryIds
        try:
            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_h', self._shared.get_ameco_history_df(country_ids)),
                ('forecast_a', self._shared.get_forecast_df(country_ids, 'A', app_id = params.appId)),
                ('forecast_q', self._shared.get_forecast_df(country_ids, 'Q', app_id = params.appId)),
                ('eurostat_q', self._shared.get_eurostat_df(country_ids, 'Q')),
                ('dfm_measures', self._shared.get_dfm_fdms_measures(country_ids)),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = country_ids
            await self._run_task(
                task_run_sid,
                params,
                input_df,
                Save.VALIDATION,
                country_group = country_ids,
            )

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
