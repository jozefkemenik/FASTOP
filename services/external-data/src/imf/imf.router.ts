import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'

import { ImfController } from './imf.controller'
import { ImfService } from './imf.service'

export class ImfRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new ImfRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: ImfController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new ImfController(new ImfService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/', this.getImfDataHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getImfDataHandler
     *********************************************************************************************/
    private getImfDataHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getImfData(
            req.query.ds as string,
            req.query.key as string,
            Number(req.query.startPeriod),
            Number(req.query.endPeriod),
        ).then(res.json.bind(res), next)
    }
}
