import os
import cx_Oracle
import oracledb

from typing import Dict, List, Tuple , Any

from fastoplib.indicator_utils import format_indicators_data

class DbService:

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self ):
        self.__user = os.getenv('USERNAME')


        self.conn = cx_Oracle.connect('FASTOP',
                                        os.getenv('FASTOP_DB_PASSWORD'),
                                        os.getenv('FASTOP_DB'))

        self.__country_map: Dict[str, str] = {}
        self.__scale_exponent_map: Dict[str, int] = {}
        self.__storage_map: Dict[str, int] = {}
        self.__round_map: Dict[str, int] = {}

    ###############################################################################################
    ##################################### Destructor ##############################################
    ###############################################################################################
    def __del__(self):
        self.conn.close()

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    def clean_indicator_data(self, round_sid: int, provider: str, frequency: str) -> None:
        with self.conn.cursor() as cursor:
            sql = """
                delete from FDMS_INDICATOR_DATA
                where ROUND_SID = :round
                and STORAGE_SID = (select STORAGE_SID from STORAGES where STORAGE_ID = 'FINAL')
                and INDICATOR_SID in (select INDICATOR_SID from VW_FDMS_INDICATORS where PROVIDER_ID = :provider and PERIODICITY_ID = :periodicity)
            """
            cursor.execute(sql, round = round_sid, provider = provider, periodicity = frequency)

    ###############################################################################################
    def commit(self):
        self.conn.commit()

    ###############################################################################################
    def fetch_records(self, sql: str, **kwargs: Dict) -> List[Tuple]:
        with self.conn.cursor() as cursor:
            cursor.execute(sql, **kwargs)
            res = cursor.fetchall()
        return res

    ###############################################################################################
    def fetch_one_record(self, sql: str, **kwargs: Dict) -> Tuple:
        with self.conn.cursor() as cursor:
            cursor.execute(sql, **kwargs)
            res = cursor.fetchone()
        return res

    ###############################################################################################
    def get_country_id(self, country: str) -> str:
        return self.__country_map.get(country, self.__get_country_id(country))

    ###############################################################################################
    def get_scale_exponent(self, scale: str) -> int:
        return self.__scale_exponent_map.get(scale, self.__get_scale_exponent(scale))

    ###############################################################################################
    def get_storage_sid(self, storage: str) -> int:
        return self.__storage_map.get(storage, self.__get_storage_sid(storage))

    ###############################################################################################
    def get_round_sid(self, year: str, period: str) -> int:
        key = f'{year}_{period}'
        return self.__round_map.get(key, self.__get_round_sid(year, period))

    ###############################################################################################
    def get_indicators_data(self,
        provider_ids: List[str],
        country_ids: List[str] = [],
        indicator_ids: List[str] = [],
        periodicity: str = 'A',
        round_sid: int = None,
        storage_sid: int = None,
        cust_text_sid: int = None,
    ):
        with self.conn.cursor() as cursor:
            with self.conn.cursor() as ref_cursor:
                cursor.callproc('fdms_indicator.getProvidersIndicatorData', [
                    ref_cursor, provider_ids, country_ids, indicator_ids, None, periodicity, round_sid, storage_sid, cust_text_sid
                ])
                res = ref_cursor.fetchall()
        return res

    ###############################################################################################
    def get_indicators_data_df(self, *args, **kwargs):
        db_data = self.get_indicators_data(*args, **kwargs)
        periodicity = args[3] if len(args) > 3 else kwargs.get('periodicity', 'A')
        return format_indicators_data(db_data, periodicity)

    ###############################################################################################
    def get_round_info(self, round_sid: int) -> Tuple[int, str]:
        with self.conn.cursor() as cursor:
            o_round_sid = cursor.var(int)
            o_year = cursor.var(int)
            o_descr = cursor.var(str)
            o_period = cursor.var(str)
            o_period_id = cursor.var(str)
            o_version = cursor.var(int)
            cursor.callproc('core_getters.getRoundInfo', [o_round_sid, o_year, o_descr, o_period, o_period_id, o_version, 'FDMS', round_sid])
        return o_year.getvalue(), o_period.getvalue()

    ###############################################################################################
    def set_indicator_data(self, indicator_data: Dict) -> int:
        with self.conn.cursor() as cursor:
            o_res = cursor.var(int)
            cursor.callproc('fdms_indicator.setIndicatorData', [
                indicator_data['app_id'],
                indicator_data['country_id'],
                indicator_data['indicator_id'],
                indicator_data['provider_id'],
                indicator_data['periodicity_id'],
                indicator_data['scale_id'],
                indicator_data['start_year'],
                indicator_data['time_serie'],
                self.__user,
                o_res,
                indicator_data['round_sid'],
                indicator_data['storage_sid'],
                indicator_data['p_archive_data'],
            ])
        return o_res.getvalue()



    ###############################################################################################
    ##################################### Private Methods #########################################
    ###############################################################################################
    def __get_country_id(self, country: str) -> str:
        country_uppercase = country.upper()
        with self.conn.cursor() as cursor:
            sql = "select count(*) from geo_areas where geo_area_id = :country"
            row = self.fetch_one_record(sql, country = country_uppercase)
        if row[0] == 1:
            self.__country_map[country] = country_uppercase
        else:
            with self.conn.cursor() as cursor:
                sql = "select geo_area_id from geo_area_mappings where source_descr in (:source, upper(:source)) order by source_descr desc"
                row = self.fetch_one_record(sql, source = country)
            if row != None:
                self.__country_map[country] = row[0]

        return self.__country_map.get(country)

    ###############################################################################################
    def __get_scale_exponent(self, scale: str) -> int:
        with self.conn.cursor() as cursor:
            sql = "select exponent from fdms_scales where scale_id = :scale"
            row = self.fetch_one_record(sql, scale = scale)
        if row != None:
            self.__scale_exponent_map[scale] = row[0]

        return self.__scale_exponent_map.get(scale)

    ###############################################################################################
    def __get_storage_sid(self, storage: str) -> int:
        with self.conn.cursor() as cursor:
            res = cursor.callfunc("core_getters.getStorageSid", int, [storage])
        self.__storage_map[storage] = res
        return res

    ###############################################################################################
    def __get_round_sid(self, year: str, period: str) -> int:
        with self.conn.cursor() as cursor:
            o_res = cursor.var(int)
            cursor.callproc("core_getters.getRoundSid", [year, period, o_res])
        round_sid = o_res.getvalue()
        self.__round_map[f"{year}_{period}"] = round_sid
        return round_sid
