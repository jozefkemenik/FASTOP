import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'

import {
    ETasks,
    IAddConcurrentSteps,
    IDBCountryTask,
    IDBCountryTaskRun,
    IDBTaskException,
    IDBTaskLogs,
    IDBValidationStepDetail,
    IFinishTask,
    ILogStep,
    ILogStepValidations,
    IPrepareTask,
    ISetTaskRunAllSteps
} from '.'

export class AppService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method addConcurrentSteps
     *********************************************************************************************/
    public async addConcurrentSteps(taskRunSid: number, { steps }: IAddConcurrentSteps) {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_run_sid', type: NUMBER, value: taskRunSid },
                { name: 'p_steps', type: NUMBER, value: steps },
            ],
        }
        await DataAccessApi.execSP('task_commands.addConcurrentSteps', options)
    }

    /**********************************************************************************************
     * @method addPrepStep
     *********************************************************************************************/
    public async addPrepStep(taskRunSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_run_sid', type: NUMBER, value: taskRunSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await DataAccessApi.execSP('task_commands.addTaskRunPrepStep', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method finishTask
     *********************************************************************************************/
    public async finishTask(taskRunSid: number, { statusId, steps }: IFinishTask): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_run_sid', type: NUMBER, value: taskRunSid },
                { name: 'p_task_status_id', type: STRING, value: statusId },
                { name: 'p_num_steps', type: NUMBER, value: steps ?? null },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await DataAccessApi.execSP('task_commands.finishTask', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountryTask
     *********************************************************************************************/
    public async getCountryTask(
        appId: EApps, taskId: ETasks, countryId: string, roundSid: number, storageSid: number
    ): Promise<IDBCountryTask> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_task_id', type: STRING, value: taskId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid || null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid || null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('task_getters.getCountryTask', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getCtyTaskExceptions
     *********************************************************************************************/
    public async getCtyTaskExceptions(
        taskId: string, countryId: string, roundSid: number, storageSid: number
    ): Promise<IDBTaskException[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_id', type: STRING, value: taskId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('task_getters.getCtyTaskExceptions', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTaskLogs
     *********************************************************************************************/
    public async getTaskLogs(taskRunSid: number): Promise<IDBTaskLogs> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_run_sid', type: NUMBER, value: taskRunSid },
                { name: 'o_task_status_id', type: STRING, dir: BIND_OUT },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('task_getters.getTaskLogs', options)
        return { taskStatusId: dbResult.o_task_status_id, taskLogs: dbResult.o_cur }
    }

    /**********************************************************************************************
     * @method getValidationStepDetails
     *********************************************************************************************/
    public async getValidationStepDetails(
        countryId: string, step: number, roundSid: number, storageSid: number,
    ): Promise<IDBValidationStepDetail[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_step', type: NUMBER, value: step },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('task_getters.getTaskLogValidations', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method logStep
     *********************************************************************************************/
    public async logStep(
        taskRunSid: number,
        step: number,
        { exceptions, statusId, stepTypeId, description, message }: ILogStep,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_run_sid', type: NUMBER, value: taskRunSid },
                { name: 'p_step_number', type: NUMBER, value: step },
                { name: 'p_step_descr', type: STRING, value: description || null },
                { name: 'p_step_status_id', type: STRING, value: statusId },
                { name: 'p_step_exceptions', type: NUMBER, value: exceptions },
                { name: 'p_step_message', type: STRING, value: message?.slice(0, 3996) || null },
                { name: 'p_step_type_id', type: STRING, value: stepTypeId || null },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await DataAccessApi.execSP('task_commands.logStep', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method logStepValidations
     *********************************************************************************************/
    public async logStepValidations(
        taskLogSid: number,
        { labels, indicators, actual, validation1, validation2, failed }: ILogStepValidations,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_log_sid', type: NUMBER, value: taskLogSid },
                { name: 'p_labels', type: STRING, value: labels },
                { name: 'p_indicator_codes', type: STRING, value: indicators },
                { name: 'p_actual', type: STRING, value: actual },
                { name: 'p_validation1', type: STRING, value: validation1 },
                { name: 'p_validation2', type: STRING, value: validation2 },
                { name: 'p_failed', type: STRING, value: failed },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('task_commands.logStepValidations', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method prepareTask
     *********************************************************************************************/
    public async prepareTask(
        appId: EApps, { taskId, countryIds, prepSteps, user, concurrency }: IPrepareTask,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_task_id', type: STRING, value: taskId },
                { name: 'p_country_ids', type: STRING, value: countryIds },
                { name: 'p_prep_steps', type: NUMBER, value: prepSteps },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_concurrency', type: NUMBER, value: concurrency || 1},
            ]
        }
        const dbResult = await DataAccessApi.execSP('task_commands.prepareTask', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setTaskRunAllSteps
     *********************************************************************************************/
    public async setTaskRunAllSteps(taskRunSid: number, { steps }: ISetTaskRunAllSteps): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_task_run_sid', type: NUMBER, value: taskRunSid },
                { name: 'p_num_steps', type: NUMBER, value: steps },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await DataAccessApi.execSP('task_commands.setTaskRunAllSteps', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountriesTasks
     *********************************************************************************************/
    public async getCountriesTasks(
        appId: EApps, taskId: ETasks, roundSid: number, storageSid: number
    ): Promise<IDBCountryTaskRun[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_task_id', type: STRING, value: taskId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid || null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid || null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('task_getters.getCountriesTasks', options)
        return dbResult.o_cur
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
