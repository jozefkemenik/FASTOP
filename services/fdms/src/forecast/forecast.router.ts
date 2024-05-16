import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { ForecastController } from './forecast.controller'
import { ForecastType } from '../../../fdms/src/forecast/shared-interfaces'
import { SharedService } from '../shared/shared.service'


export class ForecastRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new ForecastRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    controller: ForecastController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService) {
        super(appId)
        this.controller = new ForecastController(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router.get('/:forecastType',
            this.getForecastRoundAndStorageHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getForecastRoundAndStorageHandler
     *********************************************************************************************/
    private getForecastRoundAndStorageHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getForecastRoundAndStorage(
            req.params.forecastType as ForecastType
        ).then(res.json.bind(res), next)
}
