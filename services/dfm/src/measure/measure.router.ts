import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import { AuthzLibService } from '../../../lib/dist'
import { LibMeasureRouter } from '../../../lib/dist/measure'

import { IMeasureDetails } from '.'
import { MeasureController } from './measure.controller'
import { MeasureService } from './measure.service'
import { SharedService } from '../shared/shared.service'
import { UploadService } from './upload.service'

export class MeasureRouter extends LibMeasureRouter<IMeasureDetails, UploadService, MeasureService, MeasureController> {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of MeasureRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new MeasureRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService) {
        super(appId, new MeasureController(appId, sharedService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this router
     * @overrides
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get(
                '/country',
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getCountryMeasuresHandler,
            )
            .get(
                '/valueWithGDP/:countryId/:year',
                AuthzLibService.checkCountryAuthorisation(),
                this.getValueWithGDPHandler,
            )
            .get('/', AuthzLibService.checkAuthorisation('ADMIN'), this.getAllMeasuresHandler)
            .get(
                '/tr/:countryId/:gdp',
                AuthzLibService.checkCountryAuthorisation(),
                this.getTransparencyReportMeasuresHandler,
            )
            .put(
                '/tr/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                AuthzLibService.checkCountryAuthorisation(),
                this.checkEditable(this.isTrEditable),
                this.saveTransparencyReportHandler,
            )
            .post(
                '/tr/excel/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                AuthzLibService.checkCountryAuthorisation(),
                this.getTransparencyReportHandler,
            )

        return super.configRoutes(router)
    }

    /**********************************************************************************************
     * @method areMeasuresEditable
     *********************************************************************************************/
    protected areMeasuresEditable = (ctyStatusId: EStatusRepo, appStatusId: EStatusRepo) =>
        ctyStatusId !== EStatusRepo.SUBMITTED && appStatusId !== EStatusRepo.CLOSED

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isTrEditable
     *********************************************************************************************/
    private isTrEditable(ctyStatusId: EStatusRepo, appStatusId: EStatusRepo) {
        return ctyStatusId !== EStatusRepo.TR_SUBMITTED && appStatusId === EStatusRepo.TR_OPENED
    }

    /**********************************************************************************************
     * @method getAllMeasuresHandler
     *********************************************************************************************/
    private getAllMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAllMeasures().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryMeasuresHandler
     *********************************************************************************************/
    private getCountryMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getCountryMeasures(
                req.query.countryId as string,
                req.query.gdp === 'true',
                SharedService.getReqArchiveParams(req.query),
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTransparencyReportHandler
     *********************************************************************************************/
    private getTransparencyReportHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getTransparencyReport(req.params.countryId, req.body, Number(req.query.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTransparencyReportMeasuresHandler
     *********************************************************************************************/
    private getTransparencyReportMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getTransparencyReportMeasures(req.params.countryId, req.params.gdp === 'true', Number(req.query.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getValueWithGDPHandler
     *********************************************************************************************/
    private getValueWithGDPHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getValueWithGDP(req.params.countryId, Number(req.params.year), Number(req.query.value))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method saveTransparencyReportHandler
     *********************************************************************************************/
    private saveTransparencyReportHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .saveTransparencyReport(req.params.countryId, req.body.measureSids)
            .then(res.json.bind(res), next)
}
