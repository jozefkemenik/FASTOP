from pydantic import BaseModel
from typing import Dict, List
from enum import Enum

class RoundKeys(BaseModel):
    roundSid: int
    storageSid: int
    custTextSid: int = None

class SetCountryStatus(BaseModel):
    newStatusId: str
    userId: str
    roundKeys: RoundKeys

class TaskParams(BaseModel):
    appId: str
    countryIds: List[str]
    user: str
    year: int
    period: str
    roundSid: int
    storageSid: int
    runAllSteps: bool = True

class TaskAbortError(Exception):
    pass

class CountrySerie(BaseModel):
    country_id: str
    series: List[str]
    sources: List[str]
    levels: List[str]

    @staticmethod
    def from_dict(dict_data: Dict):
        return CountrySerie(
            country_id = dict_data.get('country_id')
          , series = dict_data.get('series')
          , sources = dict_data.get('sources')
          , levels = dict_data.get('levels')
        )

class AmecoIndicator(BaseModel):
    indicator_id: str
    periodicity: str
    start_year: int
    country_data: List[CountrySerie]

    @staticmethod
    def from_dict(dict_data: Dict):
        return AmecoIndicator(
            indicator_id = dict_data.get('indicator_id')
          , periodicity = dict_data.get('periodicity')
          , start_year = dict_data.get('start_year')
          , country_data = [CountrySerie.from_dict(d) for d in dict_data.get('country_data')]
        )

class UnemploymentData(BaseModel):
    indicators: List[AmecoIndicator]
    dictionary: Dict[str, int]

    @staticmethod
    def from_dict(dict_data: Dict):
        return UnemploymentData(
            indicators = [AmecoIndicator.from_dict(d) for d in dict_data.get('indicators')]
          , dictionary = dict_data.get('dictionary')
        )

class AmecoNsiIndicatorData(BaseModel):
    series: List[str]
    order: int

    @staticmethod
    def from_dict(dict_data: Dict):
        return AmecoNsiIndicatorData(
            series=dict_data.get('series')
          , order = dict_data.get('order')
        )

class AmecoNsiIndicator(BaseModel):
    nsi_id: str
    country_id: str
    table: str
    start_year: int
    data: List[AmecoNsiIndicatorData]

    @staticmethod
    def from_dict(dict_data: Dict):
        return AmecoNsiIndicator(
            nsi_id = dict_data.get('nsi_id')
          , country_id = dict_data.get('country_id')
          , table = dict_data.get('table')
          , start_year = dict_data.get('start_year')
          , data = [AmecoNsiIndicatorData.from_dict(d) for d in dict_data.get('data')]
        )

class Forecast(Enum):
    FULLY_FLEDGED = 'LATEST_FULLY_FLEDGED'
    LATEST_AGGREGATES = 'LATEST_AGGREGATES'
