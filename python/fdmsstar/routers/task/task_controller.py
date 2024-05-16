from asyncio import create_task

from fastoplib import TaskParams

from .task_eu_agg_service import TaskEuAggService
from .task_forecast_service import TaskForecastService
from .task_iea_agg_service import TaskIeaAggService
from .task_iea_calc_service import TaskIeaCalcService
from .task_cycl_adj_service import TaskCyclAdjService
from .task_og_agg_service import TaskOgAggService
from .task_knp_service import TaskKnpService
from .task_tce_service import TaskTceService
from .task_oil_prices import TaskOilPricesService
from .task_validation_service import TaskValidationService
from .task_world_agg_service import TaskWorldAggService
from .task_estat_service import TaskEstatService
from .ameco.task_unemployment_service import TaskUnemploymentService
from .ameco.task_nsi_service import TaskNSIService

class TaskController():

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self.task_services = {
            'aggregation': TaskEuAggService,
            'calculation': TaskForecastService,
            'cyclical-adjustments': TaskCyclAdjService,
            'iea-calculation': TaskIeaCalcService,
            'iea-aggregation': TaskIeaAggService,
            'og-aggregation': TaskOgAggService,
            'knp': TaskKnpService,
            'tce': TaskTceService,
            'oil-price': TaskOilPricesService,
            'validation': TaskValidationService,
            'world-aggregation': TaskWorldAggService,
            'estat-a-load': TaskEstatService,
            'estat-q-load': TaskEstatService,
            'estat-m-load': TaskEstatService,
            'ameco-unemployment': TaskUnemploymentService,
            'ameco-nsi': TaskNSIService,
        }

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_id: str, params: TaskParams):

        if task_id in self.task_services:
            service = self.task_services.get(task_id)()
            task_run_sid = await service.prepare_task(params.appId, task_id.upper(), params.countryIds, params.user)
            if task_run_sid > 0:
                create_task(service.run_task(task_run_sid, params))
                return task_run_sid

        return -1
