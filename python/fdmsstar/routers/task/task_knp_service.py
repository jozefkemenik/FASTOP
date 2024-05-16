from asyncio import as_completed
from logging import getLogger

from fastoplib import TaskParams
from fdms.forecast_KNP import forecast_KNP

from .task_base_service import TaskBaseService


class TaskKnpService(TaskBaseService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self._prep_steps = 4
        super().__init__()

    ###############################################################################################
    ##################################### Properties ##############################################
    ###############################################################################################
    @property
    def task_program(self):
        return forecast_KNP

    @property
    def task_element(self):
        return 'KNP'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        input_df = dict()
        country_ids = []
        try:
            set_country_status_result = await self._shared.set_country_status(
                params.countryIds[0],
                self._prepare_setCountryStatus(params)
            )
            if set_country_status_result < 0:
                self._logger.error(f'Error resetting aggregation status for FDMS! Result = {set_country_status_result}')

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_ph', self._shared.get_ameco_ph_df(country_ids, ['UVGD.1.1.0.0', 'OVGD.1.1.0.0', 'KNP.1.0.212.0'])),
                ('ameco_h', self._shared.get_ameco_history_df(country_ids, ['UVGD.1.1.0.0', 'OVGD.1.1.0.0', 'KNP.1.0.212.0'])),
                ('pre_prod_a', self._shared.get_pre_prod_df(country_ids, 'A', ['UVGD.1.1.0.0', 'UVGN.1.1.0.0', 'OVGD.1.1.0.0', 'XNE.1.0.99.0', 'NPTD.1.0.0.0'])),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = ['EU27']
            await self._run_task(task_run_sid, params, input_df)

        except Exception as e:
            await self._task.error_task(params.taskId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
