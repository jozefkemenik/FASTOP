import { NextFunction, Request, Response, Router } from 'express'


import { AuthzLibService, BaseRouter } from '../../../lib/dist'
import { DashboardController } from './dashboard.controller'
import { DashboardService } from './dashboard.service'
import { EApps } from 'config'

export class DashboardRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new DashboardRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: DashboardController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new DashboardController(new DashboardService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/public',
                this.getDashboardPublicAppsHandler)
            .get('/restricted',
                this.getDashboardRestrictedAppsHandler)
            .get('/tree',
                this.getDashboardTreeActiveAppsHandler)
            .post('/tree',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.setDashboardTreeAppsHandler.bind(this)
            )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDashboardPublicAppsHandler
     *********************************************************************************************/
    private getDashboardPublicAppsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDashboardPublicApps().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDashboardRestrictedAppsHandler
     *********************************************************************************************/
    private getDashboardRestrictedAppsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDashboardRestrictedApps(
            this.getAllUserAuthorizations(req),
            AuthzLibService.isInternalCall(req)
        ).then(res.json.bind(res), next)

     /**********************************************************************************************
     * @method getDashboardRestrictedAppsHandler
     *********************************************************************************************/
     private getDashboardTreeActiveAppsHandler = (req: Request, res: Response, next: NextFunction) =>
     this.controller.getDashboardTreeActiveApps(
         this.getAllUserAuthorizations(req),
         AuthzLibService.isInternalCall(req)
     ).then(res.json.bind(res), next)


    /**********************************************************************************************
     * @method setDashboardTreeAppsHandler
     *********************************************************************************************/
     private setDashboardTreeAppsHandler = (req: Request, res: Response, next: NextFunction) => 
            this.controller.setDashboardTreeApps(req.body).then(res.json.bind(res), next)
}
