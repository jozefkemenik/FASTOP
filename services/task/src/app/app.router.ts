import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { BaseRouter } from '../../../lib/dist/base-router'

import { AppController } from './app.controller'
import { AppService } from './app.service'
import { ETasks } from '.'

export class AppRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new AppRouter().buildRouter({mergeParams: true})
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: AppController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new AppController(new AppService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .post('/', this.prepareTaskHandler.bind(this))
            .post('/runs/:taskRunSid/prepStep', this.addPrepStepHandler.bind(this))
            .put('/runs/:taskRunSid/steps', this.setTaskRunAllStepsHandler.bind(this))
            .post('/runs/:taskRunSid/steps', this.addConcurrentStepsHandler.bind(this))
            .post('/runs/:taskRunSid/steps/:step', this.logStepHandler.bind(this))
            .post('/runs/:taskRunSid/finish', this.finishTaskHandler.bind(this))
            .get('/runs/:taskRunSid', this.getTaskLogsHandler.bind(this))
            .post('/steps/:taskLogSid', this.logStepValidationsHandler.bind(this))
            .get('/validationSteps/:step', this.getValidationStepHandler.bind(this))
            .get('/:taskId', this.getTaskRunHandler.bind(this))
            .get('/:taskId/exceptions', this.getCtyTaskExceptionsHandler.bind(this))
            .get('/countries/:taskId', this.getCountriesTasksRunHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method addConcurrentStepsHandler
     *********************************************************************************************/
    private addConcurrentStepsHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.addConcurrentSteps(Number(req.params.taskRunSid), req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method addPrepStepHandler
     *********************************************************************************************/
    private addPrepStepHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.addPrepStep(Number(req.params.taskRunSid))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method finishTaskHandler
     *********************************************************************************************/
    private finishTaskHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.finishTask(Number(req.params.taskRunSid), req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCtyTaskExceptionsHandler
     *********************************************************************************************/
    private getCtyTaskExceptionsHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.getCtyTaskExceptions(
            req.params.taskId.toUpperCase() as ETasks,
            req.query.countryId as string,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getTaskLogsHandler
     *********************************************************************************************/
    private getTaskLogsHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.getTaskLogs(Number(req.params.taskRunSid))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getTaskRunHandler
     *********************************************************************************************/
    private getTaskRunHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.getTaskRun(
            req.params.appId as EApps,
            req.params.taskId.toUpperCase() as ETasks,
            req.query.countryId as string,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getValidationStepHandler
     *********************************************************************************************/
    private getValidationStepHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.getValidationStep(
            Number(req.params.step),
            req.query.countryId as string,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method logStepHandler
     *********************************************************************************************/
    private logStepHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.logStep(Number(req.params.taskRunSid), Number(req.params.step), req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method logStepValidationsHandler
     *********************************************************************************************/
    private logStepValidationsHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.logStepValidations(Number(req.params.taskLogSid), req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method prepareTaskHandler
     *********************************************************************************************/
    private prepareTaskHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.prepareTask(req.params.appId as EApps, req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method addPrepStepHandler
     *********************************************************************************************/
    private setTaskRunAllStepsHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.setTaskRunAllSteps(Number(req.params.taskRunSid), req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCountriesTasksRunHandler
     *********************************************************************************************/
    private getCountriesTasksRunHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.getCountriesTasks(
            req.params.appId as EApps,
            req.params.taskId.toUpperCase() as ETasks,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)
    }
}
