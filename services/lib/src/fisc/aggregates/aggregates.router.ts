import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'
import { LoggingService } from '../../logging.service'

import { AggregatesController } from './aggregates.controller'
import { AggregatesService } from './aggregates.service'
import { IAggregateParameters } from '.'

export class AggregatesRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, params: IAggregateParameters, logs: LoggingService): Router {
        return new AggregatesRouter(appId, params, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: AggregatesController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(appId: EApps, params: IAggregateParameters, logs: LoggingService) {
        super()
        this.controller = new AggregatesController(appId, logs, new AggregatesService(appId, params))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'C1', 'READ_ONLY'),
                this.getAggregatesVariablesHandler)
            .post('/excel/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'C1', 'READ_ONLY'),
                this.getAggregatesExcelHandler)
            .post('/calc/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'C1'),
                this.calculateAggregatesHandler)
            .post('/lineData/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'MS', 'READ_ONLY', 'CTY_DESK', 'SU'),
                this.getLineDataHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAggregatesVariablesHandler
     *********************************************************************************************/
    private getAggregatesVariablesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getVariables(
            Number(req.params.roundSid)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAggregatesExcelHandler
     *********************************************************************************************/
    private getAggregatesExcelHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.exportAggregatesToExcel(
            Number(req.params.roundSid),
            req.body
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateAggregatesHandler
     *********************************************************************************************/
    private calculateAggregatesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateAggregates(
            Number(req.params.roundSid),
            req.body,
            this.getUserId(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLineDataHandler
     *********************************************************************************************/
    private getLineDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGridCellValues(
            Number(req.params.roundSid),
            req.body
        ).then(res.json.bind(res), next)
}
