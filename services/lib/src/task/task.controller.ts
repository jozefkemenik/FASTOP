import { EApps } from 'config'
import { EStatusRepo } from 'country-status'
import { ETasks } from 'task'

import { ComputationService, ComputationServiceType } from '.'
import { CountryStatusApi } from '../api/country-status.api'
import { DashboardApi } from '../api/dashboard.api'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IError } from '../error.service'
import { RequestService } from '../request.service'
import { TaskApi } from '../api/task.api'


export class LibTaskController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly computationService: ComputationServiceType,
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method abortTask
     *********************************************************************************************/
    public abortTask(taskRunSid: number) {
        return TaskApi.abortTask(this.appId, taskRunSid)
    }

    /**********************************************************************************************
     * @method getTaskLogs
     *********************************************************************************************/
    public getTaskLogs(taskRunSid: number) {
        return TaskApi.getTaskLogs(this.appId, taskRunSid)
    }

    /**********************************************************************************************
     * @method getTaskRun
     *********************************************************************************************/
    public getTaskRun(taskId: ETasks, countryId: string, roundSid: number, storageSid: number) {
        return TaskApi.getTaskRun(this.appId, taskId, countryId, {roundSid, storageSid})
    }

    /**********************************************************************************************
     * @method runTask
     *********************************************************************************************/
    public async runTask(taskId: ETasks, countryIds: string[], user: string, runAllSteps = true): Promise<number> {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        const statuses = await CountryStatusApi.getCountryStatuses(this.appId, countryIds, roundInfo)

        if (!statuses.every(status => [EStatusRepo.ACTIVE, EStatusRepo.REJECTED].includes(status.statusId))) {
            return EErrors.CTY_STATUS
        }

        const body = {
            appId: this.appId,
            countryIds,
            user,
            year: roundInfo.year,
            period: roundInfo.periodDescr,
            roundSid: roundInfo.roundSid,
            storageSid: roundInfo.storageSid,
            runAllSteps,
        }

        const computationService: ComputationService = (
            this.computationService[taskId.toUpperCase()] || this.computationService
        ) as ComputationService

        return RequestService.request(computationService, `/tasks/${taskId}`, 'post', body).catch(
            (err: IError) => {
                err.method = 'LibTaskController.runTask'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getCountriesTasks
     *********************************************************************************************/
    public getCountriesTasks(taskId: ETasks, roundSid: number, storageSid: number) {
        return TaskApi.getCountriesTasks(this.appId, taskId, {roundSid, storageSid})
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
