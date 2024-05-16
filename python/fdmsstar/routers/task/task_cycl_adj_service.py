from asyncio import as_completed, gather
from logging import getLogger

from fastoplib import TaskParams
from fdms.cyclical_adjustments import cyclicalAdjustments

from .task_base_service import TaskBaseService
from . import Save


class TaskCyclAdjService(TaskBaseService):

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
        return cyclicalAdjustments

    @property
    def task_element(self):
        return 'Cyclical Ajdustments'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):

        input_df = dict()
        country_ids = params.countryIds
        og_full = None
        if not params.runAllSteps:
            country_ids = await self._shared.get_cty_group_countries(params.countryIds[0])
            params.countryIds = country_ids
            og_full = True

        try:
            forecast_indicators = await self._get_forecast_indicators()

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_ph', self._shared.get_ameco_ph_df(country_ids)),
                ('ameco_h', self._shared.get_ameco_history_df(country_ids)),
                ('forecast_a', self._shared.get_forecast_df(['EA', 'EU', 'EU27'] + country_ids, 'A')),
                ('og_upload', self._shared.get_og_upload_df(country_ids, 'A')),
                ('cyclical_adjustment', self._shared.get_cyclical_adjustments_df(country_ids)),
                ('covid_measures', self._shared.get_covid_df(country_ids)),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = country_ids
            await self._run_task(
                task_run_sid,
                params,
                input_df,
                save = Save.CYCLICAL_ADJUSTMENTS,
                forecast_indicators = forecast_indicators,
                country_group = country_ids,
                run_eucam_light = params.runAllSteps,
                og_full = og_full,
            )

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
