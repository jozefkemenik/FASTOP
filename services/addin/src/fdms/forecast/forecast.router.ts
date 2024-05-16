import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'
import { FdmsRouter } from '../shared/fdms.router'
import { ForecastController } from './forecast.controller'

export class ForecastRouter extends FdmsRouter<ForecastController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, providers: Array<string> = null): Router {
        return new ForecastRouter(appId, providers).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(appId: EApps, providers: Array<string> = null, ) {
        super(appId, new ForecastController(), providers, )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        super.configRoutes(router)
             .get('/tree', this.getIndicatorsTreeHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorsTreeHandler
     *********************************************************************************************/
    private getIndicatorsTreeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorsTree().then(res.json.bind(res), next)
}
