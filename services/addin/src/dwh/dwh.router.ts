import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { DwhController } from './dwh.controller'
import { DwhService } from './dwh.service'
import { EApps } from 'config'


export class DwhRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new DwhRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: DwhController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new DwhController(new DwhService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/data/:providers/:periodicity',
                this.getDwhDataHandler)
            .get('/indicators/:providers',
                this.getDwhIndicatorsHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDwhDataHandler
     *********************************************************************************************/
    private getDwhDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorData(
            this.getArrayQueryParam(req.params.providers),
            req.params.periodicity as string,
            req.body.indicatorIds
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDwhIndicatorsHandler
     *********************************************************************************************/
    private getDwhIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicators(this.getArrayQueryParam(req.params.providers)).then(res.json.bind(res), next)
}
