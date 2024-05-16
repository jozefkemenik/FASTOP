from asyncio import as_completed, gather
from logging import getLogger

from fastoplib import TaskParams
from fdms.forecast_og_aggregation import forecast_og_aggregation

from .task_base_service import TaskBaseService


class TaskOgAggService(TaskBaseService):

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
    def concurrency(self): return 1

    @property
    def task_program(self):
        return forecast_og_aggregation

    @property
    def task_element(self):
        return 'OG aggregation'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        input_df = dict()
        indicators = ['UTCGCP.1.0.319.0', 'UUCGCP.1.0.319.0', 'UVGDH.1.0.99.0', 'XNE.1.0.99.0',
                      'UBLGCP.1.0.319.0', 'UBLGE.1.0.319.0', 'UBLGIE.1.0.319.0', 'UBLGE.1.0.0.0',
                      'UOOMS.1.0.319.0', 'UBLGIE.1.0.0.0', 'UBLGAP.1.0.319.0',
                      'UBLGAPS.1.0.319.0', 'UBLGBP.1.0.319.0', 'UBLGBPS.1.0.319.0']
        cty_grps = ['EA', 'EA17', 'EA18', 'EA19', 'EA19EXIE', 'EA20',
                    'EU', 'EU27', 'XU27', 'EU28', 'EU28EXUK', 'EUEXEA', 'EUEXIE']
        cty_ids = ['AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'ES', 'FI', 'FR', 'HR', 'HU', 'IE', 'IT', 'LT',
                   'LU', 'LV', 'MT', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK', 'UK', 'US', 'JP']

        try:
            country_ids = cty_ids + cty_grps

            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('ameco_h', self._shared.get_ameco_history_df(country_ids, indicators)),
                ('pre_prod_a', self._shared.get_pre_prod_df(country_ids, 'A', indicators)),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = cty_grps
            await self._run_task(task_run_sid, params, input_df, og_full=True)

            # automatically accept the storage
            await self._shared.accept_storage('AGG')

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
