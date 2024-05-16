import os
from logging import getLogger
from typing import Dict, List, Tuple , Any

import oracledb

from .db_service import DbService


class OracleDBService(DbService):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################

    def __init__(self  ):

        self.conn = oracledb.connect(user ='FASTOP',
                                    password =os.getenv('FASTOP_DB_PASSWORD'),
                                    dsn= os.getenv('FASTOP_DB'))


    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################

    async def exec_stored_procedure(self , proc : str , options : Dict[Any ,str]) :

        params_proc = []
        for param in options['params']:
            if 'value' in param :
                params_proc.append(param['value'])

        with self.conn.cursor() as cursor:
            with self.conn.cursor() as ref_cursor:
                p = [ref_cursor ]
                p.extend(params_proc)

                cursor.callproc(proc , p)
                res = ref_cursor.fetchall()

        results= {}
        results['o_cur'] = res

        return results        