import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../authzLib.service'
import { BaseRouter } from '../base-router'
import { ComputationServiceType } from '.'
import { EApps } from 'config'
import { ETasks } from 'task'
import { LibTaskController } from './task.controller'


export class LibTaskRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, computationService: ComputationServiceType = EApps.FDMSSTAR): Router {
        return new LibTaskRouter(appId, computationService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: LibTaskController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, computationService: ComputationServiceType) {
        super()
        this.controller = new LibTaskController(appId, computationService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/runs/:taskRunSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getTaskLogsHandler.bind(this))
            .delete('/runs/:taskRunSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.abortTaskHandler.bind(this))

        router.route('/:taskId')
            .all(AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'))
            .put(this.checkCountryAuthorisation(req => req.body.countryIds),
                this.runTaskHandler.bind(this))
            .get(this.checkCountryAuthorisation(req => req.query.countryId as string, ['OGCLC']),
                this.getTaskRunHandler.bind(this))

        router
            .get('/countries/:taskId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getCountriesTasksRunHandler.bind(this))

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkCountryAuthorisation
     *********************************************************************************************/
    private checkCountryAuthorisation(countryGetter: (req: Request) => string, excludedCountries?: string[]) {
        return (req: Request, res: Response, next: NextFunction): void => {
            if (
                ['TCE', 'AGGREGATION'].includes(req.params.taskId.toUpperCase()) ||
                AuthzLibService.isAdmin(req) ||
                excludedCountries?.includes(countryGetter(req))
            ) {
                next()
            } else {
                AuthzLibService.checkCountryAuthorisation(countryGetter)(req, res, next)
            }
        }
    }

    /**********************************************************************************************
     * @method abortTaskHandler
     *********************************************************************************************/
    private abortTaskHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.abortTask(Number(req.params.taskRunSid))
            .then(res.json.bind(res), next)
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
            req.params.taskId as ETasks,
            req.query.countryId as string,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method runTaskHandler
     *********************************************************************************************/
    private runTaskHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.runTask(
            req.params.taskId as ETasks,
            req.body.countryIds,
            this.getUserId(req),
            req.body.runAllSteps,
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCountriesTasksRunHandler
     *********************************************************************************************/
    private getCountriesTasksRunHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.getCountriesTasks(
            req.params.taskId as ETasks,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)
    }

}
