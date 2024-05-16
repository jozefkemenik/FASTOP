import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

import { LibLineIndicatorController } from './line-indicator.controller'
import { LibLineIndicatorService } from './line-indicator.service'

export class LibLineIndicatorRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of LibIndicatorRouter
     *********************************************************************************************/
    public static createRouter(): Router {
        return new LibLineIndicatorRouter(new LibLineIndicatorController(new LibLineIndicatorService())).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(private readonly controller: LibLineIndicatorController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/line/:lineSid', AuthzLibService.checkAuthorisation('ADMIN'), this.getLineIndicatorHandler.bind(this))
            .put(
                '/line/:lineSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.updateLineIndicatorHandler.bind(this),
            )
            .delete(
                '/line/:lineSid/datatype/:dataTypeSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.deleteLineIndicatorHandler.bind(this),
            )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getLineIndicatorHandler
     *********************************************************************************************/
    private getLineIndicatorHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getLineIndicators(Number(req.params.lineSid)).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method updateLineIndicatorHandler
     *********************************************************************************************/
    private updateLineIndicatorHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.updateLineIndicator(Number(req.params.lineSid), req.body).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method deleteLineIndicatorHandler
     *********************************************************************************************/
    private deleteLineIndicatorHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .deleteLineIndicator(Number(req.params.lineSid), Number(req.params.dataTypeSid))
            .then(res.json.bind(res), next)
    }
}
