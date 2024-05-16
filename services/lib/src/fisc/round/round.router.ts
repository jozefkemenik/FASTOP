import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

import { FiscRoundController } from './round.controller'
import { FiscRoundService } from './round.service'

export class FiscRoundRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new FiscRoundRouter(
            new FiscRoundController(new FiscRoundService(appId))
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(private controller: FiscRoundController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configLocalRoutes routes configuration for FiscGridsRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .put('/:roundSid/lines/:lineSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.updateLineHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method updateLineHandler
     *********************************************************************************************/
    private updateLineHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.updateLine(
            Number(req.params.roundSid), Number(req.params.lineSid), req.body
        ).then(res.json.bind(res), next)
    }
}
