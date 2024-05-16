import { NextFunction, Request, Response, Router } from 'express'
import { AddinApi } from '../../../lib/dist/api/addin.api'
import { AuthzLibService } from '../../../lib/dist/authzLib.service'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'

export class AddinRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new AddinRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/public', this.getDashboardPublicAppsHandler)
            .get('/restricted', this.getDashboardRestrictedAppsHandler)
            .get('/tree', this.getDashboardTreeActiveAppsHandler)
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
        AddinApi.getDashboardPublicApps().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDashboardRestrictedAppsHandler
     *********************************************************************************************/
    private getDashboardRestrictedAppsHandler = (req: Request, res: Response, next: NextFunction) =>
        AddinApi.getDashboardRestrictedApps().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDashboardRestrictedAppsHandler
     *********************************************************************************************/
    private getDashboardTreeActiveAppsHandler = (req: Request, res: Response, next: NextFunction) =>
        AddinApi.getDashboardTreeApps().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method setDashboardTreeAppsHandler
     *********************************************************************************************/
    private setDashboardTreeAppsHandler = (req: Request, res: Response, next: NextFunction) =>
        AddinApi.setDashboardTreeApps(req.body).then(res.json.bind(res), next)
}
