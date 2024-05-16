from asyncio import as_completed
from logging import getLogger

from fastoplib import TaskParams
from fdms.oil_prices import oilPrices

from .task_base_service import TaskBaseService


class TaskOilPricesService(TaskBaseService):

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
        return oilPrices

    @property
    def task_element(self):
        return 'Oil Prices'

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):

        input_df = dict()
        country_ids = params.countryIds
        try:
            for name_and_future in as_completed([self._shared.zip_future_with_name(name, future) for name, future in [
                ('xne_us_ameco_ph', self._shared.get_ameco_ph_df(['US'], ['XNE.1.0.99.0'])),
                ('xne_us_ameco_h', self._shared.get_ameco_history_df(['US'], ['XNE.1.0.99.0'], True)),
                ('oil_usd_q', self._shared.get_oil_price_quarterly_df()),
                ('exchange_rate_a', self._shared.get_usd_annual_exchange_rates_df(True)),
                ('exchange_rate_q', self._shared.get_usd_quarterly_exchange_rates_df(True)),
            ]]):
                name, data = await name_and_future
                input_df[name] = data
                await self._task.add_prep_step(params.appId, task_run_sid)

            params.countryIds = country_ids
            await self._run_task(
                task_run_sid,
                params,
                input_df,
                country_group = country_ids,
            )

        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise(e)

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################
