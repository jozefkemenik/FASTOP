from asyncio import gather, get_running_loop
import pandas as pd
import numpy as np
from typing import List, Tuple, Set, Dict
import sys

from logging import getLogger

from fpcalc_lib.operations import Operation

from fastoplib import TaskParams, TaskAbortError
from fastoplib.base_task_estat_service import BaseTaskEstatService
from fastoplib.indicator_utils import normalize_vector, str_to_float

from ..shared.shared_service import SharedService
from .task_db_service import TaskDbService
from . import IndicatorData, EstatIndicator


class TaskEstatService(BaseTaskEstatService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self._logger = getLogger(__name__)
        self.__force_json = False
        self.__db = TaskDbService.get_service()
        self.__shared = SharedService.get_service()
        self.__task_configs = {
            'ESTAT-A-LOAD': {
                'function': self.__run_estat_a_load, 'provider': 'ESTAT_A', 'periodicity': 'A'
            },
            'ESTAT-M-LOAD': {
                'function': self.__run_estat_m_load, 'provider': 'ESTAT_M', 'periodicity': 'M'
            },
            'ESTAT-Q-LOAD': {
                'function': self.__run_estat_q_load, 'provider': 'ESTAT_Q', 'periodicity': 'Q'
            },
        }
        self.__config = None
        self.__input = None
        super().__init__()

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def prepare_task(self, app_id: str, task_id: str, country_ids: List[str], user: str) -> int:
        self.__config = self.__task_configs[task_id]
        indicators = await self.__db.get_provider_indicators(self.__config.get('provider'))
        countries = await self.__shared.get_cty_group_countries(country_ids[0])
        self.__input = (indicators, countries)
        steps = len(indicators)
        return await self._task.prepare_task(app_id, task_id, country_ids, steps, user)

    ###############################################################################################
    async def run_task(self, task_run_sid: int, params: TaskParams):
        service_function = self.__config.get('function')
        await service_function(task_run_sid, params)

    ###############################################################################################
    #################################### Private Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def __run_estat_a_load(self, task_run_sid: int, params: TaskParams):
        provider_id = self.__config.get('provider')
        periodicity = self.__config.get('periodicity')
        indicators, countries = self.__input

        try:
            sdmx_tasks = [self.__fetch_sdmx_data(params.appId, task_run_sid, i.indicator_id, i.eurostat_code)
                          for i in indicators]
            sdmx_data_tuples = await gather(*sdmx_tasks)

            result = await self.__process_annual_data(sdmx_data_tuples, set(countries), periodicity)
            await self.__finish_task(task_run_sid, 1, result, provider_id, params)
        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise (e)

    ###############################################################################################
    async def __run_estat_q_load(self, task_run_sid: int, params: TaskParams):
        provider_id = self.__config.get('provider')
        periodicity = self.__config.get('periodicity')
        indicators, countries = self.__input

        try:
            sdmx_tasks = [self.__fetch_sdmx_data(params.appId, task_run_sid, i.indicator_id, i.eurostat_code)
                          for i in indicators]

            sdmx_data_tuples = await gather(*sdmx_tasks)

            result = await self.__process_quarterly_data(sdmx_data_tuples, indicators, set(countries), periodicity)
            await self.__finish_task(task_run_sid, 1, result, provider_id, params)
        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise (e)

    ###############################################################################################
    async def __run_estat_m_load(self, task_run_sid: int, params: TaskParams):
        provider_id = self.__config.get('provider')
        periodicity = self.__config.get('periodicity')
        indicators, countries = self.__input

        try:
            sdmx_tasks = [self.__fetch_sdmx_data(params.appId, task_run_sid, i.indicator_id, i.eurostat_code)
                          for i in indicators]
            sdmx_data_tuples = await gather(*sdmx_tasks)

            result = await self.__process_monthly_data(sdmx_data_tuples, indicators, set(countries), periodicity)
            await self.__finish_task(task_run_sid, 1, result, provider_id, params)
        except Exception as e:
            await self._task.error_task(params.appId, task_run_sid, e)
            raise (e)

    ###############################################################################################
    async def __finish_task(
            self, task_run_sid: int, total_steps: int, result: List[IndicatorData],
            provider_id: str, params: TaskParams
    ):
        await self.__save_result(task_run_sid, total_steps, result, provider_id, params)
        await self._task.finish_task(params.appId, task_run_sid, total_steps, 'DONE')

    ###############################################################################################
    async def __process_annual_data(
            self, sdmx_data_tuples: List[Tuple[str, Dict]], countries: Set[str], periodicity: str
    ) -> List[IndicatorData]:
        vat_indicator, bop_indicators, other_indicators = None, [], []
        for indicator_id, sdmx_data in sdmx_data_tuples:
            if indicator_id == 'UD76PAYS13.1.0.0.0':
                vat_indicator = (indicator_id, sdmx_data)
            elif indicator_id == 'UBCA.1.0.99.0' or indicator_id == 'UBGN.1.0.99.0':
                bop_indicators.append((indicator_id, sdmx_data))
            else:
                other_indicators.append((indicator_id, sdmx_data))

        result = await self.__process_annual_vat(vat_indicator, countries, periodicity)
        result.extend(self.__process_annual_balance_of_payments(bop_indicators, periodicity))
        result.extend(self.__process_sdmx_tuples(other_indicators, set(), periodicity, 'UNIT'))

        return result

    ###############################################################################################
    async def __process_annual_vat(
            self, sdmx_data_tuple: Tuple[str, Dict], countries: Set[str], periodicity: str
    ) -> List[IndicatorData]:
        gov_indicators = self.__process_sdmx_tuples([sdmx_data_tuple], countries, periodicity)
        # sdmx returns empty vectors but json api returns 'na'
        missing_countries = set(
            [i.country_id for i in gov_indicators if len(i.time_serie.replace(',', '').replace('na', '')) == 0]
        )
        result = [i for i in gov_indicators if i.country_id not in missing_countries]
        result_countries = set([r.country_id for r in result])
        missing_countries = missing_countries.union(countries - result_countries)

        if 'EU' in missing_countries or 'EU28EXUK' in missing_countries:
            missing_countries.discard('EU')
            missing_countries.discard('EU28EXUK')
            missing_countries.add('EU27_2020')

        # Government data is not available for all countries, get missing from national accounts
        nasa_sdmx_data = await self._call_sdmx('nasa_10_nf_tr',
                                               f'A.CP_MNAC.PAID.D76.S13.', self.__force_json)
        result.extend(
            self.__process_sdmx_tuples([('UD76PAYS13.1.0.0.0', nasa_sdmx_data)], missing_countries, periodicity)
        )

        return result

    ###############################################################################################
    def __process_annual_balance_of_payments(
            self, sdmx_data_tuples: List[Tuple[str, Dict]], periodicity: str
    ) -> List[IndicatorData]:
        result = []
        for indicator_id, sdmx_data in sdmx_data_tuples:
            geo_index, partner_index = sdmx_data['names'].index('GEO'), sdmx_data['names'].index('PARTNER')


            ea20_data, eu27_data = None, None
            for country_data in sdmx_data['data']:
                geo, partner = country_data['index'][geo_index], country_data['index'][partner_index]

                if ea20_data is None and geo == 'EA20' and partner == 'EXT_EA20':
                    ea20_data = country_data
                    result.append(
                        IndicatorData(
                            country_id='EA_ADJ',
                            indicator_id=indicator_id,
                            periodicity_id=periodicity,
                            scale_id='MILLION',
                            start_year=self.__get_start_year(ea20_data['item']),
                            time_serie=','.join([str(v) for v in ea20_data['item'].values()]))
                    )
                elif eu27_data is None and geo == 'EU27_2020' and partner == 'EXT_EU27_2020':
                    eu27_data = country_data
                    result.append(
                        IndicatorData(
                            country_id='EU_ADJ',
                            indicator_id=indicator_id,
                            periodicity_id=periodicity,
                            scale_id='MILLION',
                            start_year=self.__get_start_year(eu27_data['item']),
                            time_serie=','.join([str(v) for v in eu27_data['item'].values()]))
                    )

                if ea20_data is not None and eu27_data is not None:
                    break

        return result

    ###############################################################################################
    async def __process_monthly_data(
            self, sdmx_data_tuples: List[Tuple[str, Dict]], indicators: List[EstatIndicator],
            countries: Set[str], periodicity: str
    ) -> List[IndicatorData]:
        indicators_dict = {ind.indicator_id: ind for ind in indicators}
        trans_indicators, other_indicators = [], []

        for indicator_id, sdmx_data in sdmx_data_tuples:
            ind = indicators_dict.get(indicator_id)
            if ind.transf_id is not None:
                trans_indicators.append((ind.indicator_id, ind.transf_id, sdmx_data))
            else:
                other_indicators.append((ind.indicator_id, sdmx_data))

        result = await self.__transform_indicators(trans_indicators, periodicity, countries)
        result.extend(self.__process_sdmx_tuples(other_indicators, countries, periodicity))

        return result

    ###############################################################################################
    async def __process_quarterly_data(
            self, sdmx_data_tuples: List[Tuple[str, Dict]], indicators: List[EstatIndicator],
            countries: Set[str], periodicity: str
    ) -> List[IndicatorData]:
        indicators_dict = {ind.indicator_id: ind for ind in indicators}
        xne_indicators, trans_indicators, other_indicators = [], [], []

        for indicator_id, sdmx_data in sdmx_data_tuples:
            ind = indicators_dict.get(indicator_id)
            if ind.indicator_id == 'XNE.1.0.99.0':
                xne_indicators.append((ind.indicator_id, sdmx_data))
            elif ind.transf_id is not None:
                trans_indicators.append((ind.indicator_id, ind.transf_id, sdmx_data))
            else:
                other_indicators.append((ind.indicator_id, sdmx_data))

        result = await self.__transform_indicators(trans_indicators, periodicity, countries)
        result.extend(self.__process_xne_usd_quarterly(xne_indicators, periodicity))
        result.extend(self.__process_sdmx_tuples(other_indicators, countries, periodicity))

        return result

    ###############################################################################################
    def __process_xne_usd_quarterly(
            self, tuples: List[Tuple[str, Dict]], periodicity_id: str
    ) -> List[IndicatorData]:
        result = []

        for (indicator_id, sdmx_data) in tuples:
            currency_index = sdmx_data['names'].index('CURRENCY')
            for country_data in sdmx_data['data']:
                currency = country_data['index'][currency_index].upper()
                if currency == 'USD':
                    result.append(
                        IndicatorData(
                            country_id='US',
                            indicator_id=indicator_id,
                            periodicity_id=periodicity_id,
                            scale_id='UNIT',
                            start_year=self.__get_start_year(country_data['item']),
                            time_serie=','.join([str(v) for v in country_data['item'].values()]))
                    )

        return result

    ###############################################################################################
    def __process_sdmx_tuples(
            self, tuples: List[Tuple[str, Dict]], countries: Set[str], periodicity_id: str, scale: str = None
    ) -> List[IndicatorData]:
        result = []
        for (indicator_id, sdmx_data) in tuples:
            geo_index = sdmx_data['names'].index('GEO')
            unit_index = sdmx_data['names'].index('UNIT') if scale is None else None

            for country_data in sdmx_data['data']:
                country_id = country_data['index'][geo_index].upper()

                if len(countries) == 0 or country_id in countries or country_id == 'EU27_2020':
                    indicator_data = IndicatorData(
                        country_id=country_id,
                        indicator_id=indicator_id,
                        periodicity_id=periodicity_id,
                        scale_id=self.__get_scale(country_data['index'][unit_index]) if scale is None else scale,
                        start_year=self.__get_start_year(country_data['item']),
                        time_serie=','.join([str(v) for v in country_data['item'].values()])
                    )
                    # EU27_2020 is stored as EU and EU28EXUK
                    if country_id == 'EU27_2020':
                        indicator_data.country_id = 'EU'
                        eu28_exuk = indicator_data.copy()
                        eu28_exuk.country_id = 'EU28EXUK'
                        result.append(eu28_exuk)

                    result.append(indicator_data)
        return result

    ###############################################################################################
    async def __save_result(
            self, task_run_sid: int, step: int, results: List[IndicatorData], provider_id: str, params: TaskParams
    ) -> int:
        self._logger.debug(f'Save eurostat {len(results)} indicators')

        status = 'DONE'
        message = ''
        try:
            saved = 0
            await self._task.log_step(params.appId, task_run_sid, step, 0, 'SAVING')
            for ind in results:
                res = await self.__db.save_provider_indicator_data(
                    params.appId, ind.country_id, [ind.indicator_id], provider_id,
                    ind.periodicity_id, ind.scale_id, ind.start_year, [ind.time_serie], params.user
                )
                if res < 0:
                    self._logger.error(
                        f'Error saving eurostat indicator: {ind.indicator_id} for {ind.country_id}: {res}!')
                    raise Exception(f'Error saving eurostat indicator: {ind.indicator_id}!')
                saved += res

            message = 'Fetched and saved indicators:\n' + '\n'.join([i.indicator_id for i in self.__input[0]])
            self._logger.debug(f'Saved eurostat indicators: {saved}')
            await self.__db.save_indicator_data_upload(params.roundSid, params.storageSid, provider_id, params.user)
        except TaskAbortError:
            status = 'ABORT'
        except:
            self._logger.error(f'Error saving eurostat indicators for provider {provider_id}, results: {saved}')
            message = f'ERROR: Saving eurostat indicators in the database has failed!\n'
            status = 'ERROR'
        finally:
            await self._task.log_step(params.appId, task_run_sid, step, 0, status, '', 'SAVED EUROSTAT INDICATORS', message)

    ###############################################################################################
    def __get_scale(self, unit: str) -> str:
        return 'MILLION' if unit.upper() in ['CLV15_MNAC', 'MIO_NAC', 'CP_MNAC'] else 'UNIT'

    ###############################################################################################
    def __get_start_year(self, sdmx_data_item: dict) -> int:
        return min([int(period.split('-')[0]) for period in list(sdmx_data_item)])

    ###############################################################################################
    async def __transform_indicators(
            self, data_tuples: List[Tuple[str, str, Dict]], periodicity: str, countries: Set[str]
    ) -> List[IndicatorData]:
        return await self._loop.run_in_executor(
            None, self.__run_transformations, data_tuples, periodicity, countries
        )

    ###############################################################################################
    def __run_transformations(
            self, data_tuples: List[Tuple[str, str, Dict]], periodicity: str, countries: Set[str]
    ):
        result = []
        agg_tuple = [(indicator_id, sdmx_data) for indicator_id, transf_id, sdmx_data in data_tuples if
                     transf_id == 'AGG_Q']

        if len(agg_tuple) > 0:
            result.extend(
                self.__aggregate_to_quarterly(
                    self.__process_sdmx_tuples(agg_tuple, countries, periodicity)
                )
            )
        return result

    ###############################################################################################
    def __aggregate_to_quarterly(
            self, indicators_data: List[IndicatorData]
    ) -> List[IndicatorData]:
        if len(indicators_data) == 0:
            return []

        result, indexes = [], []
        start_year = sys.maxsize
        vector_length = 0
        for data in indicators_data:
            indexes.append((data.country_id, data.indicator_id))
            start_year = min(start_year, data.start_year)
            vector_length = max(vector_length, len(data.time_serie.split(',')))

        freq = 'M'
        vectors = [normalize_vector(
            data.start_year, [str_to_float(v) for v in data.time_serie.split(',')], start_year, vector_length, freq,
        ) for data in indicators_data]

        df = pd.DataFrame(
            np.array(vectors).T,
            index=pd.period_range(f'{start_year}-01-01', freq=freq, periods=vector_length),
            columns=pd.MultiIndex.from_tuples(indexes, names=['country', 'indicator_id'])
        ).T
        df.columns = df.columns.astype('str')
        df = Operation().collapse(df, input_frequency=freq, output_frequency='Q')

        for data in indicators_data:
            data.start_year = start_year
            data.time_serie = ','.join(
                [str(v) if not np.isnan(v) else '' for v in df.loc[(data.country_id, data.indicator_id)]]
            )
            result.append(data)

        return result

    ###############################################################################################
    async def __fetch_sdmx_data(
            self, app_id: str, task_run_sid: int, indicator: any, eurostat_code: str
    ) -> Tuple[str, Dict]:
        ds, key = eurostat_code.split('|')
        sdmx_data = await self._call_sdmx(ds, key, self.__force_json)
        await self._task.add_prep_step(app_id, task_run_sid)

        return indicator, sdmx_data
