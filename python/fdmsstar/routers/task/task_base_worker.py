from abc import ABC, abstractmethod
from asyncio import get_running_loop, run_coroutine_threadsafe, get_event_loop, AbstractEventLoop
from logging import getLogger
from pandas import DataFrame
from rx import create

from fastoplib import TaskParams, TaskAbortError
from fastoplib.task_client import TaskClient

from . import StepOutcome, Save
from .task_db_service import TaskDbService

logger = getLogger(__name__)

class __TaskBaseWorker(ABC):

    ###############################################################################################
    ##################################### Constructor #############################################
    ###############################################################################################
    def __init__(self, task_run_sid: int, params: TaskParams, task_element: str, task, save, **kwargs):
        self.task_run_sid = task_run_sid
        self.params = params
        self.task = task
        self.task_element = task_element
        self.og_full = kwargs.get('og_full')
        self.db = TaskDbService.get_service()
        self.task_client = TaskClient.get_service()
        self.save = save

    ###############################################################################################
    @abstractmethod
    def async_run(self): pass

    ###############################################################################################
    async def finish_task(self, status: str):
        await self.task_client.finish_task(self.params.appId, self.task_run_sid, None, status)

    ###############################################################################################
    async def save_step_error(self, step_outcome: StepOutcome):
        await self.save_step_result(step_outcome)
        await self.finish_task('ERROR')

    ###############################################################################################
    async def save_step_result(self, step_outcome: StepOutcome):
        step = step_outcome[0]
        error = step_outcome[1]
        result_df = step_outcome[2]
        exceptions = step_outcome[3] or (0, list())
        description = step_outcome[4]

        status = 'DONE' if exceptions[0] == 0 else 'WARNING'
        step_type = exceptions[2] if len(exceptions) > 2 else ''
        message = ''
        saved = -99

        self._saving()
        try:
            if error:
                message = f'ERROR: exception in the {self.task_element} step process!\n'
            else:
                if self.save == Save.CALCULATION or self.save == Save.AGGREGATION or self.save == Save.OIL_PRICE:
                    saved = await self.__save_calculation_step_data(step, result_df, step_outcome[6])
                elif self.save == Save.CYCLICAL_ADJUSTMENTS:
                    saved = await self.__save_cyclical_adj_result(step, result_df, step_outcome[6])
                elif self.save == Save.TCE:
                    saved = await self.__save_tce_result(step, result_df, self.params.user)
                elif self.save == Save.VALIDATION:
                    saved = await self.__save_validation_step_result(step, result_df)
                logger.debug(f'step {step}: saved = {saved}')

            if saved < 0:
                status = 'ERROR'
                logger.error(f'Error saving {self.task_element} step {step} results: {saved}')
        except TaskAbortError:
            status = 'ABORT'
        except:
            logger.error(f'Exception during saving {self.task_element} step {step} results')
            message = f'ERROR: Saving step results in the database has failed!\n'
            status = 'ERROR'
        finally:
            message = message + (exceptions[1] if len(exceptions) > 1 and isinstance(exceptions[1], str) else '')
            await self.task_client.log_step(self.params.appId, self.task_run_sid, step, exceptions[0], status, step_type, description, message)
            self._saving_finished(step)

    ###############################################################################################
    def task_observable(self):
        def _next(step_outcome: StepOutcome):
            run_coroutine_threadsafe(self.save_step_result(step_outcome), self.loop)
            logger.debug(f"Finished step {step_outcome[0]}")

        def _error(step_outcome: StepOutcome):
            run_coroutine_threadsafe(self.save_step_error(step_outcome), self.loop)
            logger.debug(f"Error in step: {step_outcome[0]}")

        def _completed():
            run_coroutine_threadsafe(self.finish_task('DONE'), self.loop)
            logger.debug("Done!")

        create(self.task.perform_calculation).subscribe(
            on_next = _next,
            on_error = _error,
            on_completed = _completed,
        )

    ###############################################################################################
    ##################################### Protected Methods #######################################
    ###############################################################################################

    ###############################################################################################
    def _saving(self):
        pass

    ###############################################################################################
    def _saving_finished(self, step: int):
        pass

    ###############################################################################################
    #################################### Private Methods ##########################################
    ###############################################################################################

    ###############################################################################################
    async def __save_calculation_step_data(self, step: int, result_df: DataFrame, periodicity: str) -> int:
        await self.task_client.log_step(self.params.appId, self.task_run_sid, step, 0, 'SAVING')
        if result_df.empty: return 0

        result_df.set_index('Country AMECO', drop=False, inplace=True)
        countries = result_df.index.unique()

        start_year = result_df.columns[3]
        if isinstance(start_year, str):
            start_year = int(start_year[:4])

        saved = 0
        for country in countries:
            country_result = result_df.loc[country].values.tolist()
            if not isinstance(country_result[0], list):
                country_result = [country_result]
            res = await self.db.save_indicator_data(
                self.params.appId, country_result, start_year, periodicity, self.params.user, self.og_full
            )
            if res < 0:
                return res
            saved += res
        return saved

    ###############################################################################################
    async def __save_validation_step_result(self, step: int, result_df: DataFrame) -> int:
        labels = ','.join(map(str, result_df.columns.tolist()[3:]))
        result = result_df.values.tolist()

        actual_rows = [row for row in result if row[2] == 'actual' or row[2] == 'annual']
        indicators = [row[1] for row in actual_rows]
        logger.debug(f'step {step}: indicators = {indicators}')
        actual = [','.join(map(str, row[3:])) for row in actual_rows]
        logger.debug(f'step {step}: actual = {len(actual)}')
        validation1 = [','.join(map(str, row[3:])) for row in result if row[2] == 'expected' or row[2] == 'quarterly']
        logger.debug(f'step {step}: validation1 = {len(validation1)}')
        validation2 = [','.join(map(str, row[3:])) for row in result if row[2] == '% difference' or row[2] == 'difference']
        logger.debug(f'step {step}: validation2 = {len(validation2)}')
        failed = [','.join(map(str, map(int, row[3:]))) for row in result if row[2] == 'boolean']
        logger.debug(f'step {step}: failed = {len(failed)}')

        if not len(validation1):
            validation1 = ['' for el in actual]
        if not len(validation2):
            validation2 = ['' for el in actual]

        task_log_sid = await self.task_client.log_step(self.params.appId, self.task_run_sid, step, 0, 'SAVING')
        return await self.task_client.log_step_validations(
            self.params.appId, task_log_sid, labels, indicators, actual, validation1, validation2, failed
        )

    ###############################################################################################
    async def __save_tce_result(self, step: int, result_df: DataFrame, user: str) -> int:
        result_df.set_index('Country AMECO', drop=False, inplace=True)
        countries = result_df.index.unique()
        start_year = result_df.columns[3]
        saved = 0
        await self.task_client.log_step(self.params.appId, self.task_run_sid, step, 0, 'SAVING')
        for country in countries:
            country_result = result_df.loc[country].values.tolist()
            res = await self.db.save_tce_data(country_result, start_year, user)
            if res < 0:
                return res
            saved += res
        return saved

    ###############################################################################################
    async def __save_cyclical_adj_result(self, step: int, result_df: DataFrame, periodicity: str) -> int:
        saved = await self.__save_calculation_step_data(step, result_df, periodicity)

        # Set the fully fledged forecast only when the full output gap is executed (params.runAllSteps == False)
        if not self.params.runAllSteps and saved > 0:
            try:
                await self.db.mark_forecast('LATEST_FULLY_FLEDGED', self.params.user)
            except Exception as e:
                logger.error(f'Exception during marking FULLY FLEDGED forecast: {e}')

        return saved


