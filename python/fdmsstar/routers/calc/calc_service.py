from itertools import chain
from pandas import DataFrame, MultiIndex, period_range
from typing import Dict, List
import numpy as np

from fastoplib.indicator_utils import fix_NA
from fpcalc_lib.operations import Operation

from . import AggregateCountry, Vector

from fdms.calclib.FDMSEngineExecutor import PandasOperationsExecutor

class CalcService:

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    @staticmethod
    def aggregate(startYear: int, endYear: int, countryGroups: Dict[str, List[str]], variables: List[AggregateCountry]):

        rate_of_change_vars = []
        level_vars = []
        for l in variables:
            aggCtry = AggregateCountry()
            aggCtry.countryId = l.countryId
            aggCtry.variables = list(filter(lambda v: v.isLevel == False, l.variables))
            rate_of_change_vars.append(aggCtry)

            aggCtry = AggregateCountry()
            aggCtry.countryId = l.countryId
            aggCtry.variables = list(filter(lambda v: v.isLevel == True, l.variables))
            level_vars.append(aggCtry)

        columns = list(range(startYear, endYear + 1))
        rate_of_change_df = CalcService.__get_aggregate_df(columns, rate_of_change_vars)
        level_df = CalcService.__get_aggregate_df(columns, level_vars)
        level_weights_df = CalcService.__get_aggregate_weights_df(columns, level_vars)
        rate_weights_df = CalcService.__get_aggregate_weights_df(columns, rate_of_change_vars)

        result = {}
        for cg in countryGroups.keys():
            dict = {cg: countryGroups[cg]}

            rate_of_change_agg_df = Operation().rate_of_change_aggregation(rate_of_change_df, rate_weights_df, dict)
            level_agg_df = Operation().level_aggregation(level_df, level_weights_df, startYear, dict)

            values = rate_of_change_agg_df.values.tolist() + level_agg_df.values.tolist()
            result[cg] = {l[1]: ','.join(str(e) for e in l[2:]) for l in values}

        return result

    ###############################################################################################
    @staticmethod
    def convert_frequency(
            vectors: List[Vector], start_year: int, input_frequency: str, output_frequency: str
    ) -> List[Vector]:
        df = CalcService.__to_df(vectors, start_year, input_frequency)
        df = Operation().collapse(df, input_frequency=input_frequency, output_frequency=output_frequency)
        return CalcService.__to_vectors(df)

    ###############################################################################################
    @staticmethod
    def calculate_pct(vectors: List[Vector], start_year, input_frequency: str) -> List[Vector]:
        df = CalcService.__to_df(vectors, start_year, input_frequency)
        df = Operation().pch(df)
        return CalcService.__to_vectors(df)

    ###############################################################################################
    @staticmethod
    def calculate_sum(vectors: List[Vector], start_year, input_frequency: str) -> List[Vector]:
        df = CalcService.__to_df(vectors, start_year, input_frequency)
        df = df.groupby(level='country').sum(min_count=1)

        result = []
        for country_id in df.index:
            data: List[str] = [str(v) if not np.isnan(v) else '' for v in df.loc[country_id]]
            result.append(Vector(data=data, countryId=country_id, indicatorId=''))

        return result

    ###############################################################################################
    @staticmethod
    def execute_engine(expression : str) :
        executor = PandasOperationsExecutor()
        return executor.run_expr(expression).to_json(orient = 'split')


    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################
    @staticmethod
    def __get_aggregate_df(columns: List[int], variables: List[AggregateCountry]):
        index_tuples = list(
            chain.from_iterable(
                map(lambda c: list(map(lambda v: (c.countryId, v.variableCode), c.variables)), variables)
            )
        )
        index = MultiIndex.from_tuples(index_tuples, names=['Country AMECO', 'Variable Code'])

        data = list(
            chain.from_iterable(
                map(lambda c: list(map(lambda v: tuple(v.vector), c.variables)), variables)
            )
        )

        variables_df = DataFrame(data, index=index, columns=columns)
        variables_df = fix_NA(variables_df)

        return variables_df

    ###############################################################################################
    @staticmethod
    def __get_aggregate_weights_df(columns: List[int], variables: List[AggregateCountry]):
        index_tuples = list(
            chain.from_iterable(
                map(lambda c: list(map(lambda v: (c.countryId, v.variableCode), c.variables)), variables)
            )
        )
        index = MultiIndex.from_tuples(index_tuples, names=['Country AMECO', 'Variable Code'])

        weights = list(
            chain.from_iterable(
                map(lambda c: list(map(lambda v: tuple(v.weights), c.variables)), variables)
            )
        )
        weights_df = DataFrame(weights, index=index, columns=columns)
        weights_df = fix_NA(weights_df)

        return weights_df

    ###############################################################################################
    @staticmethod
    def __to_df(vectors: List[Vector], start_year: int, frequency: str) -> DataFrame:
        indexes, data = [], []
        for v in vectors:
            indexes.append((v.countryId, v.indicatorId))
            data.append([CalcService.__to_float(v) for v in v.data])

        df = DataFrame(
            np.array(data).T,
            index=period_range(f'{start_year}-01-01', freq=frequency, periods=len(data[0])),
            columns=MultiIndex.from_tuples(indexes, names=['country', 'indicator_id'])
        ).T
        return df

    ###############################################################################################
    @staticmethod
    def __to_vectors(df: DataFrame) -> List[Vector]:
        vectors = []
        for (country_id, indicator_id) in df.index:
            data: List[str] = [str(v) if not np.isnan(v) else '' for v in df.loc[country_id, indicator_id]]
            vectors.append(Vector(data=data, countryId=country_id, indicatorId=indicator_id))

        return vectors

    ###############################################################################################
    @staticmethod
    def __to_float(value: str) -> float:
        try:
            return float(value)
        except:
            return np.nan

