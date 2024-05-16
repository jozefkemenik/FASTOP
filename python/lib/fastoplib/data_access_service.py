from .config import daService
from .request_service import RequestService

class DataAccessService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service() -> 'DataAccessService':
        if DataAccessService.__instance == None:
            DataAccessService()
        return DataAccessService.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        if DataAccessService.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            self.__request = RequestService.get_service()
            DataAccessService.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    def get_file(self, name: str):
        return self.__request.get(daService, '/files/' + name)

    ###############################################################################################
    def exec_stored_procedure(self, name: str, options):
        return self.__request.post(daService, '/exec/' + name, options)


###################################################################################################
##################################### oracledb constants ##########################################
###################################################################################################
 
STRING = 2001
NUMBER = 2010
CURSOR = 2021
CLOB_LIST = 'CLOBLIST'

BIND_IN = 3001
BIND_INOUT = 3002
BIND_OUT = 3003
