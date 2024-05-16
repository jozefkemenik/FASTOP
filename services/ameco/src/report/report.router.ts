import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { ReportController } from './report.controller'
import { ReportService } from './report.service'


export class ReportRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new ReportRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: ReportController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new ReportController(appId, new ReportService(appId))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/indicators/:providerId/:periodicityId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getAmecoCalculatedDataHandler)
            .get('/countries',
                this.getAmecoCountryCodesHandler)
            .get('/inputSources',
                this.getAmecoInputSourcesHandler)
            .get('/nsi/indicators/:periodicityId/:countryId?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getAmecoNsiDataHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoCalculatedDataHandler
     *********************************************************************************************/
    private getAmecoCalculatedDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoCalculatedData(
            req.params.providerId,
            req.params.periodicityId,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoCountryCodesHandler
     *********************************************************************************************/
    private getAmecoCountryCodesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoDownloadCountryCodes().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoInputSourcesHandler
     *********************************************************************************************/
    private getAmecoInputSourcesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInputSources().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoNsiDataHandler
     *********************************************************************************************/
    private getAmecoNsiDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoNsiData(
            req.params.periodicityId,
            req.params.countryId,
        ).then(res.json.bind(res), next)
}
