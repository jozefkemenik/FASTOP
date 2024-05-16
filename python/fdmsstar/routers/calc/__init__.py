from typing import List
from pydantic import BaseModel

class AggregateVariable(BaseModel):
    variableCode: str
    vector: List[str]
    isLevel: bool
    weights: List[str]

class AggregateCountry(BaseModel):
    countryId: str = ''
    variables: List[AggregateVariable] = []

class Vector(BaseModel):
    data: List[str]
    countryId: str
    indicatorId: str
