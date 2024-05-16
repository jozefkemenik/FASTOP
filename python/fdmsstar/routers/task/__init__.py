from pandas import DataFrame
from pydantic import BaseModel
from typing import Tuple, Optional
from enum import Enum

Save = Enum('Save', 'CALCULATION VALIDATION AGGREGATION TCE OIL_PRICE CYCLICAL_ADJUSTMENTS')

StepOutcome = Tuple[int, bool, DataFrame, Tuple[int, str], str, float, str]

class EstatIndicator(BaseModel):
    indicator_id: str
    eurostat_code: str
    transf_id: Optional[str]

class IndicatorData(BaseModel):
    country_id: str
    indicator_id: str
    periodicity_id: str
    scale_id: str
    start_year: int
    time_serie: str
