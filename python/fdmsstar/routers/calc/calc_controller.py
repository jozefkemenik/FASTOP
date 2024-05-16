from typing import Dict
from typing import List

from . import AggregateCountry, Vector
from .calc_service import CalcService

class CalcController():

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    def aggregate(
            self, start_year: int, end_year: int,
            country_groups: Dict[str, List[str]], variables: List[AggregateCountry]
    ):
        return CalcService.aggregate(start_year, end_year, country_groups, variables)

    ###############################################################################################
    def convert_frequency(
            self, vectors: List[Vector], start_year: int,
            input_frequency: str, output_frequency: str
    ):
        return CalcService.convert_frequency(vectors, start_year, input_frequency, output_frequency)

    ###############################################################################################
    def calculate_pct(self, vectors: List[Vector], start_year: int, input_frequency: str):
        return CalcService.calculate_pct(vectors, start_year, input_frequency)

    ###############################################################################################
    def calculate_sum(self, vectors: List[Vector], start_year: int, input_frequency: str):
        return CalcService.calculate_sum(vectors, start_year, input_frequency)


    ###############################################################################################
    def calculate_engine(self, expression : str) :
        return CalcService.execute_engine(expression)