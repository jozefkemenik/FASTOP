from asyncio import get_running_loop, Future, gather
import itertools
from pandas import DataFrame
from typing import Dict, List

from fastoplib import Forecast, RoundKeys, SetCountryStatus
from fastoplib.config import csService, dashboardService, dfmService, fdmsService
from fastoplib.data_access_service import BIND_OUT, DataAccessService, CURSOR, NUMBER, STRING
from fastoplib.executor_service import ExecutorService
from fastoplib.indicator_utils import format_indicators_data
from fastoplib.request_service import RequestService

class SharedService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service() -> 'SharedService':
        if SharedService.__instance == None:
            SharedService()
        return SharedService.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        if SharedService.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            self.__da = DataAccessService.get_service()
            self.__request = RequestService.get_service()
            self.__loop = get_running_loop()
            self.__cty_groups = dict()
            SharedService.__instance = self

    @property
    def executor(self):
        return ExecutorService.get_executor()

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def get_ameco_history_df(self, country_ids: List[str], indicator_ids: List[str] = [], use_latest: bool = False) -> DataFrame:
        data = await self.__get_indicators_data(['AMECO_H'], country_ids, indicator_ids, use_latest = use_latest)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_b1_df(self, country_ids: List[str], indicator_ids: List[str] = [], use_latest: bool = False) -> DataFrame:
        data = await self.__get_indicators_data(['B1'], country_ids, indicator_ids, use_latest = use_latest)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_covid_df(self, country_ids: List[str]) -> DataFrame:
        data = await self.__get_indicators_data(['COVID'], country_ids, use_latest = True)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_eucam_full_df(self, country_ids: List[str]) -> DataFrame:
        data = await self.__get_indicators_data(
            ['OG_EU13', 'OG_EU15', 'OG_US', 'OG_TT'], country_ids, forecast = Forecast.FULLY_FLEDGED.value
        )
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_ameco_ph_df(self, country_ids: List[str], indicator_ids: List[str] = []) -> DataFrame:
        data = await self.__get_ameco_ph_data(country_ids, indicator_ids)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_combined_exchange_rates_df(self, country_ids: List[str], use_latest: bool = False) -> DataFrame:
        data = await self.__get_indicators_data(['IRATES', 'ERATES'], country_ids, use_latest = use_latest)
        return format_indicators_data(data)

    ###############################################################################################
    async def get_cty_desk_input_df(self, country_ids: List[str], periodicity: str, **kwargs) -> DataFrame:
        data = await self.__get_indicators_data(['DESK'], country_ids, periodicity = periodicity, **kwargs)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    async def get_fdms_plus_df(self, periodicity: str, country_ids: List[str] = [], indicator_ids: List[str] = []) -> DataFrame:
        data = await self.__get_indicators_data(['FDMS+'], country_ids, indicator_ids, periodicity = periodicity)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    def get_round_info(self, round_sid: int):
        return self.__request.get(dashboardService, f'/config/rounds/{round_sid}')

    ###############################################################################################
    async def get_cyclical_adjustments_df(self, country_ids: List[str]) -> DataFrame:
        data = await self.__get_cyclical_adjustments(country_ids)
        return format_indicators_data(data)

    ###############################################################################################
    async def get_eurostat_df(self, country_ids: List[str], periodicity: str) -> DataFrame:
        data = await self.__get_indicators_data(['ESTAT_A', 'ESTAT_Q', 'ESTAT_M'], country_ids, periodicity = periodicity)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    async def get_forecast_df(self, country_ids: List[str], periodicity: str, indicator_ids: List[str] = [], **kwargs) -> DataFrame:
        data = await self.__get_indicators_data(['DESK', 'PRE_PROD'], country_ids, indicator_ids, periodicity, **kwargs)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    async def get_imf_weo_df(self, country_ids: List[str], periodicity: str = 'A') -> DataFrame:
        data = await self.__get_latest_indicators_data(['WEO_CTY', 'WEO_AGG'], country_ids, periodicity = periodicity)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    async def get_og_upload_df(self, country_ids: List[str], periodicity: str, indicator_ids: List[str] = []) -> DataFrame:
        data = await self.__get_indicators_data(['OG_EU13', 'OG_EU15', 'OG_US', 'OG_TT'], country_ids, indicator_ids, periodicity)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    async def get_oil_price_quarterly_df(self) -> DataFrame:
        data = await self.__get_indicators_data(['COMM'], ['WORLD'], ['OILPRC.1.0.30.0'], 'Q')
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, 'Q')

    ###############################################################################################
    async def get_usd_quarterly_exchange_rates_df(self, use_latest: bool = False) -> DataFrame:
        data = await self.__get_indicators_data(['EURUSD'], [], ['EURUSD'], 'Q', use_latest = use_latest)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, 'Q')

    ###############################################################################################
    async def get_usd_annual_exchange_rates_df(self, use_latest: bool = False) -> DataFrame:
        data = await self.__get_indicators_data(['ERATES'], ['US'], ['XNE.1.0.99.0'], use_latest = use_latest)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_pre_prod_df(self, country_ids: List[str], periodicity: str, indicator_ids: List[str] = [], **kwargs) -> DataFrame:
        data = await self.__get_indicators_data(['PRE_PROD'], country_ids, indicator_ids, periodicity, **kwargs)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data, periodicity)

    ###############################################################################################
    async def get_country_table_df(self, country_ids: List[str], **kwargs) -> DataFrame:
        data = await self.__get_country_table_data(country_ids, **kwargs)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_dfm_fdms_measures(self, country_ids: List[str]) -> DataFrame:
        options = {
            'countryIds': country_ids
        }
        data = await self.__request.post(dfmService, '/reports/fdms/measures', options)
        return await self.__loop.run_in_executor(self.executor, format_indicators_data, data)

    ###############################################################################################
    async def get_cty_group_countries(self, cty_group_id: str) -> List[str]:
        if cty_group_id not in self.__cty_groups:
            options = {
                'params': [
                    { 'name': 'p_country_group_id', 'type': STRING, 'value': cty_group_id },
                    { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
                ],
                'arrayFormat': True,
            }

            result = await self.__da.exec_stored_procedure('core_getters.getGeoAreasByCountryGroup', options)
            self.__cty_groups[cty_group_id] = [cty[0] for cty in result['o_cur']]

        return self.__cty_groups.get(cty_group_id)

    ###############################################################################################
    async def get_last_accepted_storage(
            self, country_id: str, app_id: str = 'fdms', only_full_storage: bool = True, only_full_round: bool = True,
    ):
        query_params = []
        if only_full_storage:
            query_params.append('onlyFullStorage=true')
        if only_full_round:
            query_params.append('onlyFullRound=true')

        query = f'?{"&".join(query_params)}' if len(query_params) > 0 else ''
        result = await self.__request.get(csService, f'/{app_id}/accepted/{country_id}{query}')
        return result[0]

    ###############################################################################################
    async def set_country_status(self, country_id: str, set_status: SetCountryStatus, app_id: str = 'fdms') -> int:
        result = await self.__request.post(csService, f'/{app_id}/{country_id}', set_status.dict())
        return result.get('result')

    ###############################################################################################
    async def zip_future_with_name(self, name: str, future: Future):
        return name, await future

    ###############################################################################################
    async def accept_storage(self, country_id: str) -> int:
        result = await self.__request.post(fdmsService, f'/dashboard/action/accept/{country_id}', {})
        return result.get('result')

    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################
    async def __get_ameco_ph_data(self,
        country_ids: List[str] = [],
        indicator_ids: List[str] = [],
        round_sid: int = None,
    ):
        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
                { 'name': 'p_country_ids', 'type': STRING, 'value': country_ids },
                { 'name': 'p_indicator_ids', 'type': STRING, 'value': indicator_ids },
                { 'name': 'p_round_sid', 'type': NUMBER, 'value': round_sid },
            ],
            'arrayFormat': True,
        }

        result = await self.__da.exec_stored_procedure('fdms_indicator.getAmecoPhData', options)
        return result['o_cur']

    ###############################################################################################
    async def __get_cyclical_adjustments(self,
        country_ids: List[str],
        round_sid: int = None,
    ):
        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
                { 'name': 'p_country_ids', 'type': STRING, 'value': country_ids },
            ],
            'arrayFormat': True,
        }
        if None != round_sid:
            options['params'].append({ 'name': 'o_round_sid', 'type': NUMBER, 'value': round_sid })

        result = await self.__da.exec_stored_procedure('idr_getters.getCyclicalAdjustments', options)
        return result['o_cur']

    ###############################################################################################
    async def __get_indicators_data(self,
        provider_ids: List[str],
        country_ids: List[str] = [],
        indicator_ids: List[str] = [],
        periodicity: str = 'A',
        **kwargs: Dict,
    ):
        params = [{ 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT }]
        round_params = []
        if kwargs.get('use_latest'):
            stored_proc = 'fdms_indicator.getProvidersLatestData'
        elif kwargs.get('forecast'):
            stored_proc = 'fdms_indicator.getProvidersForecastData'
            params.append({ 'name': 'p_forecast_id', 'type': STRING, 'value': kwargs.get('forecast') })
        else:
            stored_proc = 'fdms_indicator.getProvidersIndicatorData'
            if 'app_id' in kwargs:
                params.append({ 'name': 'p_app_id', 'type': STRING, 'value': kwargs.get('app_id') })
            elif 'round_keys' in kwargs:
                round_keys: RoundKeys = kwargs.get('round_keys')
                round_params = [
                    { 'name': 'p_round_sid', 'type': NUMBER, 'value': round_keys.roundSid },
                    { 'name': 'p_storage_sid', 'type': NUMBER, 'value': round_keys.storageSid },
                    { 'name': 'p_cust_text_sid', 'type': NUMBER, 'value': round_keys.custTextSid },
                ]

        options = {
            'params': [
                *params,
                { 'name': 'p_provider_ids', 'type': STRING, 'value': provider_ids },
                { 'name': 'p_country_ids', 'type': STRING, 'value': country_ids },
                { 'name': 'p_indicator_ids', 'type': STRING, 'value': indicator_ids },
                { 'name': 'p_og_full', 'type': NUMBER, 'value': None },
                { 'name': 'p_periodicity_id', 'type': STRING, 'value': periodicity },
            ] + round_params,
            'arrayFormat': True,
        }

        result = await self.__da.exec_stored_procedure(stored_proc, options)
        return result['o_cur']

    ###############################################################################################
    async def __get_latest_indicators_data(self,
        provider_ids: List[str],
        country_ids: List[str],
        periodicity: str = 'A'
    ):
        providers_data = await gather(
            *[self.__get_indicators_data(
                [provider], country_ids, periodicity = periodicity, use_latest = True
                ) for provider in provider_ids
            ]
        )
        return list(itertools.chain(*providers_data))

    ###############################################################################################
    async def __get_country_table_data(self,
        country_ids: List[str] = [],
        **kwargs: Dict,
    ):
        round_params = []
        if 'round_keys' in kwargs:
            round_keys: RoundKeys = kwargs.get('round_keys')
            round_params = [
                { 'name': 'p_round_sid', 'type': NUMBER, 'value': round_keys.roundSid },
                { 'name': 'p_storage_sid', 'type': NUMBER, 'value': round_keys.storageSid },
                { 'name': 'p_cust_text_sid', 'type': NUMBER, 'value': round_keys.custTextSid },
            ]

        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
                { 'name': 'p_country_ids', 'type': STRING, 'value': country_ids },
                { 'name': 'p_og_full', 'type': NUMBER, 'value': None },
            ] + round_params,
            'arrayFormat': True,
        }

        result = await self.__da.exec_stored_procedure('fdms_indicator.getCountryTableData', options)
        return result['o_cur']
