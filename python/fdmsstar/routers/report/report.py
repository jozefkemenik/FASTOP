from fastapi import APIRouter

from fastoplib import RoundKeys
from .report_controller import ReportController

router = APIRouter()
controller = ReportController()

@router.get('/countryTable/{country_id}/{round_sid}/{storage_sid}')
async def getCountryTable(country_id: str, round_sid: int, storage_sid: int, ie: bool = False):
    return await controller.get_country_table(country_id, RoundKeys(roundSid = round_sid, storageSid = storage_sid), ie)

@router.get('/validationTable')
async def getValidationTable():
    return await controller.get_validation_table()
