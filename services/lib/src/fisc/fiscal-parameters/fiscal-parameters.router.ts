import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

import { FiscalParametersController } from './fiscal-parameters.controller'
import { FiscalParametersService } from './fiscal-parameters.service'

export class FiscalParametersRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new FiscalParametersRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: FiscalParametersController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(appId: EApps) {
        super()
        this.controller = new FiscalParametersController(new FiscalParametersService(appId))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configLocalRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/:worksheetSid/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getWorksheetIndicatorDataHandler)
            .get('/worksheets',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getWorksheetsHandler)
            .get('/template',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.templateDefinitionHandler)
            .post('/:roundSid/',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.fiscalParamsUploadHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method templateDefinitionHandler
     *********************************************************************************************/
    private templateDefinitionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTemplateDefinition(req.query.getData === 'true').then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getWorksheetsHandler
     *********************************************************************************************/
    private getWorksheetsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getWorksheets().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getWorksheetIndicatorData
     *********************************************************************************************/
    private getWorksheetIndicatorDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getWorksheetIndicatorData(
            Number(req.params.worksheetSid),
            Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method fiscalParamsUploadHandler
     *********************************************************************************************/
    private fiscalParamsUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.storeFiscalParams(
            Number(req.params.roundSid),
            this.getUserId(req),
            req.body
        ).then(res.json.bind(res), next)
}
