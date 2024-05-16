import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, BaseRouter, MongoDbService } from '../../../lib/dist'
import { EApps } from 'config'
import { ReportController } from './report.controller'
import { ReportService } from './report.service'

export class ReportRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of DashboardRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps, db: MongoDbService): Router {
        return new ReportRouter(appId, db).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: ReportController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(appId: EApps, db: MongoDbService) {
        super(appId)
        this.controller = new ReportController(new ReportService(db))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for DashboardRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/countries',
                AuthzLibService.checkAuthorisation('ADMIN', 'READ_ONLY', 'CTY_DESK'),
                this.getCountriesHandler)
            .get('/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'READ_ONLY', 'CTY_DESK'),
                this.getCountryReportHandler)
            .post('/text/:countryId/:id',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                AuthzLibService.checkCountryAuthorisation(),
                this.updateTextHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction)  =>
        this.controller.getCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryReportHandler
     *********************************************************************************************/
    private getCountryReportHandler = (req: Request, res: Response, next: NextFunction)  =>
        this.controller.getReport(req.params.countryId.toUpperCase()).then(res.json.bind(res), next)


    /**********************************************************************************************
     * @method updateTextHandler
     *********************************************************************************************/
    private updateTextHandler = (req: Request, res: Response, next: NextFunction)  =>
        this.controller.updateText(
            req.params.countryId.toUpperCase(), req.params.id, req.body.text
        ).then(res.json.bind(res), next)

}
