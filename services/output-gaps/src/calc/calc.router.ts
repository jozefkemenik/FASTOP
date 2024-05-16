import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { BaseRouter } from '../../../lib/dist/base-router'
import { CalcController } from './calc.controller'
import { CalcService } from './calc.service'


export class CalcRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new CalcRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: CalcController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new CalcController(new CalcService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .put('/structuralBalance/:appId/:user/:countryId/:roundSid?',
                this.calcStructuralBalanceHandler)
            // .post('/params/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     AuthzLibService.checkCountryAuthorisation((req: Request) => req.body.countryIds),
            //     this.getCalculationParametersHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calcStructuralBalanceHandler
     *********************************************************************************************/
    private calcStructuralBalanceHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calcStructuralBalance(
            req.params.appId?.toUpperCase() as EApps, req.params.user, req.params.countryId, Number(req.params.roundSid)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCalculationParametersHandler
     *********************************************************************************************/
    private getCalculationParametersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCalculationParameters(
            Number(req.params.roundSid), req.body.countryIds,
        ).then(res.json.bind(res), next)
}
