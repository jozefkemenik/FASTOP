from concurrent.futures import Executor, ProcessPoolExecutor
from typing import Callable

class ExecutorService:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service(initializer: Callable = None, app: str = '') -> 'ExecutorService':
        if ExecutorService.__instance == None:
            ExecutorService(initializer, app)
        return ExecutorService.__instance

    @staticmethod
    def get_executor() -> Executor:
        if ExecutorService.__instance == None:
            raise Exception('Service not initialised!')
        return ExecutorService.get_service().__executor

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, initializer: Callable, app: str):
        if ExecutorService.__instance != None:
            raise Exception("This class is a singleton!")
        else:
            self.__executor: Executor = ProcessPoolExecutor(initializer = initializer, initargs = (app,))
            ExecutorService.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
