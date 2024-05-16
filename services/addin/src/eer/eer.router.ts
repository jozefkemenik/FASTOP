import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist/authzLib.service'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { EerController } from './eer.controller'


export class EerRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new EerRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: EerController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new EerController()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for EerRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/geo/groups', this.getGeoGroupsHandler)
            .get(
                '/indicator/data/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getIndicatorDataHandler
            )
            .get('/countries', this.getCountriesHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorDataHandler
     *********************************************************************************************/
    private getIndicatorDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getIndicatorData(req.params.providerId, req.query.group as string, req.query.periodicity as string)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGeoGroupsHandler
     *********************************************************************************************/
    private getGeoGroupsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGeoGroups().then(res.json.bind(res), next)
}
