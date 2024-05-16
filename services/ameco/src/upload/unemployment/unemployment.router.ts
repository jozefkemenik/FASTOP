import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../../lib/dist'
import { BaseRouter } from '../../../../lib/dist/base-router'
import { EApps } from 'config'
import { UnemploymentController } from './unemployment.controller'
import { UnemploymentService } from './unemployment.service'


export class UnemploymentRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new UnemploymentRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: UnemploymentController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this.controller = new UnemploymentController(appId, new UnemploymentService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/indicators',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getIndicatorsHandler)
            .post('/rawInput',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.uploadAmecoRawInputHandler)
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method uploadAmecoRawInputHandler
     *********************************************************************************************/
    private uploadAmecoRawInputHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadAmecoRawInput(
            req.body,
            this.getUserId(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsHandler
     *********************************************************************************************/
    private getIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicators(req.query.providerId as string).then(res.json.bind(res), next)

}
