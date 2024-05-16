from typing import List

from fastoplib.data_access_service import BIND_OUT, DataAccessService, CURSOR, NUMBER, STRING

from . import EstatIndicator


class TaskDbService():

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service() -> 'TaskDbService':
        if TaskDbService.__instance == None:
            TaskDbService()
        return TaskDbService.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        if TaskDbService.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            self.__da = DataAccessService.get_service()
            TaskDbService.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def get_indicator_codes(self):
        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
            ],
            'arrayFormat': True,
        }
        result = await self.__da.exec_stored_procedure('fdms_indicator.getIndicatorCodes', options)
        return result['o_cur']

    ###############################################################################################
    async def get_forecast_indicator_codes(self):
        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
            ],
            'arrayFormat': True,
        }
        result = await self.__da.exec_stored_procedure('fdms_indicator.getForecastIndicatorCodes', options)
        return result['o_cur']

    ###############################################################################################
    async def get_tce_matrix_data(self, provider_id: str):
        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
                { 'name': 'p_provider_id', 'type': STRING, 'value': provider_id },
            ],
            'arrayFormat': True,
        }
        result = await self.__da.exec_stored_procedure('fdms_tce.getTceMatrixData', options)
        return result['o_cur']

    ###############################################################################################
    def save_indicator_data(self,
        app_id: str,
        data: List[List],
        start_year: int,
        periodicity: str,
        user: str,
        og_full: bool = None,
    ) -> int:
        return self.save_provider_indicator_data(
            app_id,
            data[0][0],
            [d[1] for d in data],
            'PRE_PROD',
            periodicity,
            'UNIT',
            start_year,
            [','.join(map(str, d[3:])) for d in data],
            user,
            True,
            og_full,
        )

    ###############################################################################################
    async def save_provider_indicator_data(self,
        app_id: str,
        country_id: str,
        indicator_ids: List[str],
        provider_id: str,
        periodicity_id: str,
        scale_id: str,
        start_year: int,
        time_series: List[str],
        user: str,
        add_missing: bool = None,
        og_full: bool = None,
    ) -> int:
        options = {
            'params': [
                { 'name': 'o_res', 'type': NUMBER, 'dir': BIND_OUT },
                { 'name': 'p_app_id', 'type': STRING, 'value': app_id },
                { 'name': 'p_country_id', 'type': STRING, 'value': country_id },
                { 'name': 'p_indicator_ids', 'type': STRING, 'value': indicator_ids },
                { 'name': 'p_provider_id', 'type': STRING, 'value': provider_id },
                { 'name': 'p_periodicity_id', 'type': STRING, 'value': periodicity_id },
                { 'name': 'p_scale_id', 'type': STRING, 'value': scale_id },
                { 'name': 'p_start_year', 'type': NUMBER, 'value': start_year },
                { 'name': 'p_time_series', 'type': STRING, 'value': time_series },
                { 'name': 'p_user', 'type': STRING, 'value': user },
                { 'name': 'p_add_missing', 'type': NUMBER, 'value': 1 if add_missing else None },
                { 'name': 'p_round_sid', 'type': NUMBER },
                { 'name': 'p_storage_sid', 'type': NUMBER },
                { 'name': 'p_og_full', 'type': NUMBER, 'value': 1 if og_full else None }
            ],
        }

        result = await self.__da.exec_stored_procedure('fdms_indicator.setIndicatorData', options)
        return result['o_res']

    ###############################################################################################
    async def save_tce_data(self, data: List[List], start_year: int, user: str) -> int:
        dict =  { 'TOTAL': 'T', 'WORLD': 'W', 'EU': 'EU', 'NONEU': 'WE'}
        options = {
            'params': [
                { 'name': 'o_res', 'type': NUMBER, 'dir': BIND_OUT },
                { 'name': 'p_country_id', 'type': STRING, 'value': data[0][0] },
                { 'name': 'p_indicator_ids', 'type': STRING, 'value': list(map(lambda d: d[2], data)) },
                { 'name': 'p_data_types', 'type': STRING,
                  'value': list(map(lambda d: dict.get(d[1].upper()) if d[1].upper() in dict else d[1].upper(), data))
                 },
                { 'name': 'p_start_year', 'type': NUMBER, 'value': start_year },
                { 'name': 'p_time_series', 'type': STRING, 'value': list(map(lambda d: ','.join(map(str, d[3:])), data)) },
                { 'name': 'p_user', 'type': STRING, 'value': user },
            ],
        }
        result = await self.__da.exec_stored_procedure('fdms_tce.setTceResults', options)
        return result['o_res']

    ###############################################################################################
    async def get_provider_indicators(self, provider_id) -> List[EstatIndicator]:
        options = {
            'params': [
                { 'name': 'p_provider_id', 'type': STRING, 'value': provider_id },
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
            ],
            'arrayFormat': True,
        }

        result = await self.__da.exec_stored_procedure('fdms_indicator.getProviderIndicators', options)
        return [EstatIndicator(indicator_id=row[0], eurostat_code=row[1], transf_id=row[2]) for row in result['o_cur']]

    ###############################################################################################
    async def save_indicator_data_upload(
            self, round_sid: int, storage_sid: int, provider_id: str, user: str
    ):
        options = {
            'params': [
                { 'name': 'p_round_sid', 'type': NUMBER, 'value': round_sid },
                { 'name': 'p_storage_sid', 'type': NUMBER, 'value': storage_sid },
                { 'name': 'p_provider_id', 'type': STRING, 'value': provider_id },
                { 'name': 'p_user', 'type': STRING, 'value': user },
                { 'name': 'o_res', 'type': NUMBER, 'dir': BIND_OUT },
            ]
        }
        result = await self.__da.exec_stored_procedure('fdms_upload.setIndicatorDataUpload', options)
        return result['o_res']

    ###############################################################################################
    async def save_ameco_indicator_data(
            self, provider_id: str, indicator_id: str, periodicity_id: str, start_year: int, country_ids: List[str],
            time_series: List[str], hst_time_series: List[str],
            src_time_series: List[str], level_time_series: List[str], user: str
    ) -> int:

        options = {
            'params': [
                { 'name': 'o_res',               'type': NUMBER, 'dir':   BIND_OUT },
                { 'name': 'p_provider_id',       'type': STRING, 'value': provider_id },
                { 'name': 'p_indicator_id',      'type': STRING, 'value': indicator_id },
                { 'name': 'p_periodicity_id',    'type': STRING, 'value': periodicity_id },
                { 'name': 'p_start_year',        'type': NUMBER, 'value': start_year },
                { 'name': 'p_country_ids',       'type': STRING, 'value': country_ids },
                { 'name': 'p_time_series',       'type': STRING, 'value': time_series },
                { 'name': 'p_hst_time_series',   'type': STRING, 'value': hst_time_series },
                { 'name': 'p_src_time_series',   'type': STRING, 'value': src_time_series },
                { 'name': 'p_level_time_series', 'type': STRING, 'value': level_time_series },
                { 'name': 'p_user',              'type': STRING, 'value': user },
            ],
        }
        result = await self.__da.exec_stored_procedure('ameco_indicator.setIndicatorData', options)
        return result['o_res']

    ###############################################################################################
    async def get_ameco_indicator_data(
            self, provider_id: str, periodicity_id: str = 'A', indicator_ids: List[str] = []
    ):
        options = {
            'params': [
                { 'name': 'o_cur', 'type': CURSOR, 'dir': BIND_OUT },
                { 'name': 'p_provider_id', 'type': STRING, 'value': provider_id },
                { 'name': 'p_periodicity_id', 'type': STRING, 'value': periodicity_id },
                { 'name': 'p_indicator_ids', 'type': STRING, 'value': indicator_ids },
            ],
            'arrayFormat': True,
        }
        result = await self.__da.exec_stored_procedure('ameco_indicator.getIndicatorData', options)
        return result['o_cur']

    ###############################################################################################
    async def save_ameco_input_source(
            self, source_sids: List[int], source_codes: List[str]
    ):
        options = {
            'params': [
                { 'name': 'o_res', 'type': NUMBER, 'dir': BIND_OUT },
                { 'name': 'p_source_ids', 'type': NUMBER, 'value': source_sids },
                { 'name': 'p_source_codes', 'type': STRING, 'value': source_codes },
            ],
        }
        result = await self.__da.exec_stored_procedure('ameco_indicator.setIndicatorInputSource', options)
        return result['o_res']

    ###############################################################################################
    async def save_ameco_nsi_indicator_data(
            self, nsi_indicator_id: str, country_id: str, table_type: str, periodicity_id: str,
            start_year: int, time_series: List[str], orders: List[int], user: str
    ) -> int:

        options = {
            'params': [
                { 'name': 'o_res',               'type': NUMBER, 'dir':   BIND_OUT },
                { 'name': 'p_nsi_indicator_id',  'type': STRING, 'value': nsi_indicator_id },
                { 'name': 'p_country_id',        'type': STRING, 'value': country_id },
                { 'name': 'p_type',              'type': STRING, 'value': table_type },
                { 'name': 'p_periodicity_id',    'type': STRING, 'value': periodicity_id },
                { 'name': 'p_start_year',        'type': NUMBER, 'value': start_year },
                { 'name': 'p_time_series',       'type': STRING, 'value': time_series },
                { 'name': 'p_orders',            'type': NUMBER, 'value': orders },
                { 'name': 'p_user',              'type': STRING, 'value': user },
            ],
        }
        result = await self.__da.exec_stored_procedure('ameco_nsi.setNSIData', options)
        return result['o_res']

    ###############################################################################################
    async def mark_forecast(self, forecast_id: str, user: str) -> int:

        options = {
            'params': [
                { 'name': 'p_forecast_id',       'type': STRING, 'value': forecast_id },
                { 'name': 'p_user',              'type': STRING, 'value': user },
                { 'name': 'o_res',               'type': NUMBER, 'dir':   BIND_OUT },
            ],
        }
        result = await self.__da.exec_stored_procedure('fdms_forecast.setRoundAndStorage', options)
        return result['o_res']
