from asyncio import gather
from functools import reduce
from logging import getLogger
from typing import Dict, List

from fdms.generate_country_table import country_table
from fdms.utils.processing_tools import build_validation_report

from fastoplib import RoundKeys
from ..shared.shared_service import SharedService

class ReportController():

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        self.__shared = SharedService.get_service()
        self.__logger = getLogger(__name__)

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    async def get_country_table(self, country_id: str, round_keys: RoundKeys, international_environment: bool):

        def add_column(acc: List[List[Dict]], col: List[str]) -> List[List[Dict]]:
            if len(acc) == 0:
                return [[{'header': col[0], 'colSpan': 1}], []]
            elif col[0] == acc[0][-1].get('header'):
                acc[0][-1]['colSpan'] += 1
            else:
                acc[0].append({'header': col[0], 'colSpan': 1})
            acc[1].append({'header': col[1], 'colSpan': 1})
            return acc

        forecast_a, round_info = await gather(
            self.__shared.get_country_table_df([country_id], round_keys = round_keys),
            self.__shared.get_round_info(round_keys.roundSid),
        )

        table_df, table_number, title, footer = country_table(
            forecast_a,
            country_id,
            (round_info.get('year'), round_info.get('periodDescr')),
            self.__logger,
            international_environment,
        )
        header = reduce(add_column, table_df.columns.values.tolist(), [])

        return {
            'header': header,
            'data': [{'values': row} for row in table_df.values.tolist()],
            'dataColumnOffset': 1,
            'tableNumber': table_number,
            'title': title,
            'footer': footer,
        }

    ###############################################################################################
    async def get_validation_table(self):

        table_df = build_validation_report()
        table_df.insert(loc = 0, column = 'Type', value = table_df['Number of Exceptions'].tolist())
        
        return {
            'header': table_df.columns.values.tolist(),
            'data': table_df.values.tolist(),
        }

    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################
