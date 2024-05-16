from typing import List

from . import TaskAbortError
from .request_service import RequestService
from .config import taskService


class TaskClient:

    ###############################################################################################
    ##################################### Class Members ###########################################
    ###############################################################################################
    __instance = None

    @staticmethod
    def get_service() -> 'TaskClient':
        if TaskClient.__instance is None: TaskClient()
        return TaskClient.__instance

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self):
        if TaskClient.__instance is not None:
            raise Exception("This class is a singleton!")
        else:
            self.__request = RequestService.get_service()
            TaskClient.__instance = self

    ###############################################################################################
    ##################################### Public Methods ##########################################
    ###############################################################################################
    def add_concurrent_steps(self, app_id: str, task_run_sid: int, steps: int) -> int:
        payload = {'steps': steps}
        return self.__request.put(taskService, f'/{app_id}/runs/{task_run_sid}/steps', payload)

    ###############################################################################################
    async def add_prep_step(self, app_id: str, task_run_sid: int) -> int:
        payload = {}
        result = await self.__request.post(taskService, f'/{app_id}/runs/{task_run_sid}/prepStep', payload)
        if result < 0: raise TaskAbortError()
        return result

    ###############################################################################################
    def error_task(self, app_id: str, task_run_sid: int, exception: Exception) -> int:
        status = 'ABORT' if isinstance(exception, TaskAbortError) else 'ERROR'
        return self.finish_task(app_id, task_run_sid, 0, status)

    ###############################################################################################
    def finish_task(self, app_id: str, task_run_sid: int, steps: int, status: str) -> int:
        payload = {'statusId': status, 'steps': steps}
        return self.__request.post(taskService, f'/{app_id}/runs/{task_run_sid}/finish', payload)

    ###############################################################################################
    async def log_step(self,
        app_id: str,
        task_run_sid: int,
        step: int,
        exceptions: int,
        status: str,
        step_type: str = '',
        description: str = '',
        message: str = ''
    ) -> int:
        payload = {
            'exceptions': exceptions,
            'statusId': status,
            'stepTypeId': step_type,
            'description': description,
            'message': message,
        }
        result = await self.__request.post(taskService, f'/{app_id}/runs/{task_run_sid}/steps/{step}', payload)
        if result < 0: raise TaskAbortError()
        return result

    ###############################################################################################
    def log_step_validations(self,
        app_id: str,
        task_log_sid: int,
        labels: str,
        indicators: List[str],
        actual: List[str],
        validation1: List[str],
        validation2: List[str],
        failed: List[str],
    ) -> int:
        payload = {
            'labels': labels,
            'indicators': indicators,
            'actual': actual,
            'validation1': validation1,
            'validation2': validation2,
            'failed': failed,
        }
        return self.__request.post(taskService, f'/{app_id}/steps/{task_log_sid}', payload)

    ###############################################################################################
    def prepare_task(self,
        app_id: str,
        task_id: str,
        country_ids: List[str],
        prep_steps: int,
        user: str,
        concurrency: int = 1,
    ) -> int:
        payload = {
            'taskId': task_id,
            'countryIds': country_ids,
            'prepSteps': prep_steps,
            'user': user,
            'concurrency': concurrency,
        }
        return self.__request.post(taskService, f'/{app_id}', payload)

    ###############################################################################################
    def set_task_run_all_steps(self, app_id: str, task_run_sid: int, steps: int) -> int:
        payload = {'steps': steps}
        return self.__request.put(taskService, f'/{app_id}/runs/{task_run_sid}/steps', payload)
