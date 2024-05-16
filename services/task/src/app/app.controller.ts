import { EApps } from 'config'
import { IError } from '../../../lib/dist/error.service'

import {
    ETasks,
    IAddConcurrentSteps,
    IFinishTask,
    ILogStep,
    ILogStepValidations,
    IPrepareTask,
    ISetTaskRunAllSteps
} from '.'
import { AppService } from './app.service'

export class AppController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appService: AppService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method addConcurrentSteps
     *********************************************************************************************/
    public addConcurrentSteps(taskRunSid: number, addConcurrentSteps: IAddConcurrentSteps) {
        return this.appService.addConcurrentSteps(taskRunSid, addConcurrentSteps).catch(
            (err: IError) => {
                err.method = `${__filename}:addConcurrentSteps`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method addPrepStep
     *********************************************************************************************/
    public addPrepStep(taskRunSid: number) {
        return this.appService.addPrepStep(taskRunSid).catch(
            (err: IError) => {
                err.method = `${__filename}:addPrepStep`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method finishTask
     *********************************************************************************************/
    public finishTask(taskRunSid: number, finishTask: IFinishTask) {
        return this.appService.finishTask(taskRunSid, finishTask).catch(
            (err: IError) => {
                err.method = `${__filename}:finishTask`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getCtyTaskExceptions
     *********************************************************************************************/
    public getCtyTaskExceptions(taskId: ETasks, countryId: string, roundSid: number, storageSid: number) {
        return this.appService.getCtyTaskExceptions(taskId, countryId, roundSid, storageSid).catch(
            (err: IError) => {
                err.method = `${__filename}:getCtyTaskExceptions`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getTaskLogs
     *********************************************************************************************/
    public getTaskLogs(taskRunSid: number) {
        return this.appService.getTaskLogs(taskRunSid).catch(
            (err: IError) => {
                err.method = `${__filename}:getTaskLogs`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getTaskRun
     *********************************************************************************************/
    public getTaskRun(appId: EApps, taskId: ETasks, countryId: string, roundSid: number, storageSid: number) {
        return this.appService.getCountryTask(appId, taskId, countryId, roundSid, storageSid).catch(
            (err: IError) => {
                err.method = `${__filename}:getTaskRun`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getValidationStep
     *********************************************************************************************/
    public getValidationStep(step: number, countryId: string, roundSid: number, storageSid: number) {
        return this.appService.getValidationStepDetails(countryId, step, roundSid, storageSid).catch(
            (err: IError) => {
                err.method = `${__filename}:getValidationStep`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method logStep
     *********************************************************************************************/
    public logStep(taskRunSid: number, step: number, logStep: ILogStep) {
        return this.appService.logStep(taskRunSid, step, logStep).catch(
            (err: IError) => {
                err.method = `${__filename}:logStep`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method logStepValidations
     *********************************************************************************************/
    public logStepValidations(taskLogSid: number, logStepValidations: ILogStepValidations) {
        return this.appService.logStepValidations(taskLogSid, logStepValidations).catch(
            (err: IError) => {
                err.method = `${__filename}:logStepValidations`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method prepareTask
     *********************************************************************************************/
    public prepareTask(appId: EApps, prepareTask: IPrepareTask) {
        return this.appService.prepareTask(appId, prepareTask).catch(
            (err: IError) => {
                err.method = `${__filename}:prepareTask`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setTaskRunAllSteps
     *********************************************************************************************/
     public setTaskRunAllSteps(taskRunSid: number, setTaskRunAllSteps: ISetTaskRunAllSteps) {
        return this.appService.setTaskRunAllSteps(taskRunSid, setTaskRunAllSteps).catch(
            (err: IError) => {
                err.method = `${__filename}:setTaskRunAllSteps`
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getCountriesTasks
     *********************************************************************************************/
    public getCountriesTasks(appId: EApps, taskId: ETasks, roundSid: number, storageSid: number) {
        return this.appService.getCountriesTasks(appId, taskId, roundSid, storageSid).catch(
            (err: IError) => {
                err.method = `${__filename}:getCountriesTasks`
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
