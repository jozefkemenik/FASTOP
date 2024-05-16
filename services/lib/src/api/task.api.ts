import {
    ETaskStatuses,
    ETasks,
    ICountryTask,
    ICountryTaskRun,
    IFinishTask,
    ILogStep,
    IPrepareTask,
    ITaskException,
    ITaskLogs,
    IValidationStepDetail
} from 'task'
import { EApps } from 'config'

import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'
import { RequestService } from '../request.service'

export class TaskApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method abortTask
     *********************************************************************************************/
    public static abortTask(appId: EApps, taskRunSid: number) {
        return this.finishTask(appId, taskRunSid, {statusId: ETaskStatuses.ABORT})
    }

    /**********************************************************************************************
     * @method addPrepStep
     *********************************************************************************************/
     public static addPrepStep(appId: EApps, taskRunSid: number): Promise<void> {
        return RequestService.request(EApps.TASK, `/${appId}/runs/${taskRunSid}/prepStep`, 'post')
    }

    /**********************************************************************************************
     * @method finishTask
     *********************************************************************************************/
     public static finishTask(appId: EApps, taskRunSid: number, finishTask: IFinishTask): Promise<number> {
        return RequestService.request(EApps.TASK, `/${appId}/runs/${taskRunSid}/finish`, 'post', finishTask)
    }

    /**********************************************************************************************
     * @method getTaskLogs
     *********************************************************************************************/
    public static getTaskLogs(appId: EApps, taskRunSid: number): Promise<ITaskLogs> {
        return RequestService.request(EApps.TASK, `/${appId}/runs/${taskRunSid}`)
    }

    /**********************************************************************************************
     * @method getCtyTaskExceptions
     *********************************************************************************************/
    public static getCtyTaskExceptions(
        appId: EApps, taskId: ETasks, countryId: string, {roundSid, storageSid}: IRoundKeys
    ): Promise<ITaskException[]> {
        let query = `?countryId=${countryId}`
        if (roundSid) query += `&roundSid=${roundSid}`
        if (storageSid) query += `&storageSid=${storageSid}`

        return RequestService.request(EApps.TASK, `/${appId}/${taskId}/exceptions${query}`)
    }

    /**********************************************************************************************
     * @method getTaskRun
     *********************************************************************************************/
    public static getTaskRun(
        appId: EApps, taskId: ETasks, countryId: string, {roundSid, storageSid}: IRoundKeys
    ): Promise<ICountryTask> {
        let query = `?countryId=${countryId}`
        if (roundSid) query += `&roundSid=${roundSid}`
        if (storageSid) query += `&storageSid=${storageSid}`

        return RequestService.request(EApps.TASK, `/${appId}/${taskId}${query}`)
    }

    /**********************************************************************************************
     * @method getValidationStep
     *********************************************************************************************/
    public static getValidationStep(
        appId: EApps, step: number, countryId: string, {roundSid, storageSid}: IRoundKeys
    ): Promise<IValidationStepDetail[]> {
        let query = `?countryId=${countryId}`
        if (roundSid) query += `&roundSid=${roundSid}`
        if (storageSid) query += `&storageSid=${storageSid}`

        return RequestService.request(EApps.TASK, `/${appId}/validationSteps/${step}${query}`)
    }

    /**********************************************************************************************
     * @method logStep
     *********************************************************************************************/
     public static logStep(appId: EApps, taskRunSid: number, step: number, logStep: ILogStep): Promise<number> {
        return RequestService.request(EApps.TASK, `/${appId}/runs/${taskRunSid}/steps/${step}`, 'post', logStep)
    }

    /**********************************************************************************************
     * @method prepareTask
     *********************************************************************************************/
     public static prepareTask(appId: EApps, prepareTask: IPrepareTask): Promise<number> {
        return RequestService.request(EApps.TASK, `/${appId}`, 'post', prepareTask)
    }

    /**********************************************************************************************
     * @method getCountriesTasks
     *********************************************************************************************/
    public static getCountriesTasks(
        appId: EApps, taskId: ETasks, {roundSid, storageSid}: IRoundKeys
    ): Promise<ICountryTaskRun[]> {
        const params = []
        if (roundSid) params.push(`roundSid=${roundSid}`)
        if (storageSid) params.push(`storageSid=${storageSid}`)
        const query = params.length ? `?${params.join('&')}` : ''

        return RequestService.request(EApps.TASK, `/${appId}/countries/${taskId}${query}`)
    }
}
