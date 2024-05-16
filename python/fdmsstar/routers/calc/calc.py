from fastapi import APIRouter
from pydantic import BaseModel
from typing import Dict, List

from . import AggregateCountry, Vector
from .calc_controller import CalcController

router = APIRouter()
controller = CalcController()


class AggregationBody(BaseModel):
    variables: List[AggregateCountry]
    countryGroups: Dict[str, List[str]]
    startYear: int
    endYear: int

class BaseTransformationBody(BaseModel):
    vectors: List[Vector]
    startYear: int
    inputFrequency: str

class ConvertBody(BaseTransformationBody):
    outputFrequency: str


class BaseCalcEngine(BaseModel):
    expression: str

@router.post('/aggregate')
def aggregate(body: AggregationBody):
    return controller.aggregate(body.startYear, body.endYear, body.countryGroups, body.variables)

@router.post('/convert')
def convert(body: ConvertBody):
    return controller.convert_frequency(body.vectors, body.startYear, body.inputFrequency, body.outputFrequency)

@router.post('/pct')
def pct(body: BaseTransformationBody):
    return controller.calculate_pct(body.vectors, body.startYear, body.inputFrequency)

@router.post('/sum')
def pct(body: BaseTransformationBody):
    return controller.calculate_sum(body.vectors, body.startYear, body.inputFrequency)

@router.post('/engine')
def engine(body: BaseCalcEngine):
    return controller.calculate_engine(body.expression)


