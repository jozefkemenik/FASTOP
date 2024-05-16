from asyncio import get_running_loop, run_coroutine_threadsafe, get_event_loop
from logging import getLogger
from typing import Any, List, Tuple

from fastoplib import TaskParams, TaskAbortError

from .task_base_worker import __TaskBaseWorker

logger = getLogger(__name__)

class __TaskWorker(__TaskBaseWorker):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, task_run_sid: int, params: TaskParams, task_element: str, task, save, **kwargs):
        super().__init__(task_run_sid, params, task_element, task, save, **kwargs)

        self.saving = 0
        self.finished = False

    ###############################################################################################
    async def async_run(self):
        self.loop = get_running_loop()
        await self.task_client.add_concurrent_steps(self.params.appId, self.task_run_sid, self.task.steps)
        await self.loop.run_in_executor(None, self.task_observable)

    ###############################################################################################
    async def finish_task(self, status: str):
        await super().finish_task(status)

        if self.saving > 0:
            self.finished = True
        else:
            logger.debug(f'Stopping loop {self.loop} in finish_task')
            self.loop.stop()

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################

    ###############################################################################################
    def _saving(self):
        self.saving += 1

    ###############################################################################################
    def _saving_finished(self, step: int):
        self.saving -= 1
        if self.finished and self.saving <= 0:
            logger.debug(f'Stopping loop {self.loop} after step {step} is done')
            self.loop.stop()


###################################################################################################
def run_worker_task(
    task_run_sid: int,
    params: TaskParams,
    task_element: str,
    task_program,
    geo_areas: List[str],
    task_input: Tuple,
    **kwargs: Any,
):
    logger.debug(f'Starting worker task for {task_element}')
    task = task_program(geo_areas, *task_input)
    worker = __TaskWorker(task_run_sid, params, task_element, task, **kwargs)

    loop = get_event_loop()
    loop.create_task(worker.async_run())
    try:
        logger.debug(f'Starting loop {loop}')
        loop.run_forever()
    finally:
        logger.debug(f'Finished worker task for {task_element}')
        # loop.close()
