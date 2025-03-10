import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { CalcController } from './calc.controller'
import { EApps } from 'config'
import { LoggingService } from '../../../lib/dist'


export class CalcRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService): Router {
        return new CalcRouter(appId, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: CalcController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, private _logs: LoggingService) {
        super(appId)
        this.controller = new CalcController()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/expression',
                this.calculateExpressionHandler)
        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateExpressionHandler
     *********************************************************************************************/
    private calculateExpressionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateExpression(req.body.expression).then(res.json.bind(res), next)

}
