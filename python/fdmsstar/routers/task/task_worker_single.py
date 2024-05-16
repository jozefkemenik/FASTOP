from asyncio import get_running_loop, run_coroutine_threadsafe, get_event_loop, AbstractEventLoop
from logging import getLogger
from typing import Any, Callable, List, Tuple

from fastoplib import TaskParams, TaskAbortError

from . import Save
from .task_base_worker import __TaskBaseWorker

logger = getLogger(__name__)

class __TaskWorker(__TaskBaseWorker):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, task_run_sid: int, params: TaskParams, task_element: str, task, loop, save, **kwargs):
        super().__init__(task_run_sid, params, task_element, task, save, **kwargs)

        self.loop = loop

    ###############################################################################################
    def async_run(self):
        run_coroutine_threadsafe(self.task_client.add_concurrent_steps(self.params.appId, self.task_run_sid, self.task.steps), self.loop)
        self.task_observable()

###################################################################################################
def run_worker_task(
    task_run_sid: int,
    params: TaskParams,
    task_element: str,
    task_program,
    geo_areas: List[str],
    task_input: Tuple,
    loop: AbstractEventLoop,
    save: Save,
    **kwargs: Any,
):
    logger.debug(f'Starting worker task for {task_element}')
    task = task_program(geo_areas, *task_input)
    worker = __TaskWorker(task_run_sid, params, task_element, task, loop, save, **kwargs)
    worker.async_run()
