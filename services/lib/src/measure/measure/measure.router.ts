import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import {
    ILibMeasureDetails,
    LibMeasureController,
    LibMeasureService,
    MeasureSharedService,
    MeasureUploadService,
} from '..'
import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

export const UPD_GROUPS = ['ADMIN', 'CTY_DESK', 'MS']

export abstract class LibMeasureRouter<
    D extends ILibMeasureDetails,
    U extends MeasureUploadService<D>,
    M extends LibMeasureService,
    C extends LibMeasureController<D, U, M>,
> extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(appId: EApps, protected controller: C) {
        super(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get(
                '/enter',
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getEnterMeasuresHandler,
            )
            .post(
                '/enter/excel',
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getEnterMeasuresExcelHandler,
            )
            .get('/columns/:page/:year', this.getMeasureColumnsHandler)
            .get(
                '/template/:countryId/:roundSid',
                AuthzLibService.checkCountryAuthorisation(),
                this.getUploadTemplateHandler,
            )
            .get(
                '/wizard/:countryId/:roundSid',
                AuthzLibService.checkCountryAuthorisation(),
                this.getWizardDefinitionHandler,
            )
            .get('/scales', this.getScalesHandler)
            .put(
                '/scales/:countryId',
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation(),
                this.checkEditable(this.areMeasuresEditable),
                this.updateScaleHandler,
            )
            .post(
                '/upload/:countryId/:roundSid',
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation(),
                this.checkEditable(this.areMeasuresEditable),
                this.uploadMeasuresHandler,
            )
            .post(
                '/',
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.body.measure.COUNTRY_ID),
                this.checkEditable(this.areMeasuresEditable, (req: Request) => req.body.measure.COUNTRY_ID),
                this.saveMeasureHandler,
            )
            .put(
                '/:measureSid/values',
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.body.countryId),
                this.checkEditable(this.areMeasuresEditable, (req: Request) => req.body.countryId),
                this.setMeasureValuesHandler,
            )
            .get('/denormalised', AuthzLibService.checkAuthorisation(), this.getDenormalisedHandler)

        router
            .route('/:measureSid')
            .get(
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getMeasureDetailsHandler,
            )
            .put(
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.body.measure.COUNTRY_ID),
                this.checkEditable(this.areMeasuresEditable, (req: Request) => req.body.measure.COUNTRY_ID),
                this.saveMeasureHandler,
            )
            .delete(
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.checkEditable(this.areMeasuresEditable, (req: Request) => req.query.countryId as string),
                this.deleteMeasureHandler,
            )

        return router
    }

    /**********************************************************************************************
     * @method areMeasuresEditable
     *********************************************************************************************/
    protected areMeasuresEditable = (ctyStatusId: EStatusRepo, appStatusId: EStatusRepo) =>
        ctyStatusId === EStatusRepo.ACTIVE && appStatusId !== EStatusRepo.CLOSED

    /**********************************************************************************************
     * @method getEnterMeasuresHandler
     *********************************************************************************************/
    protected getEnterMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getEnterMeasures(
                req.query.countryId as string,
                req.query.gdp === 'true',
                req.query.raw === 'true',
                MeasureSharedService.getReqArchiveParams(req.query),
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getEnterMeasuresExcelHandler
     *********************************************************************************************/
    protected getEnterMeasuresExcelHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getEnterMeasuresExcel(
                req.query.countryId as string,
                req.query.gdp === 'true',
                MeasureSharedService.getReqArchiveParams(req.query),
                req.body.columns,
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMeasureDetailsHandler
     *********************************************************************************************/
    protected getMeasureDetailsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getMeasureDetails(
                Number(req.params.measureSid),
                req.query.countryId as string,
                MeasureSharedService.getReqArchiveParams(req.query),
            )
            .then(res.json.bind(res), next)

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method deleteMeasureHandler
     *********************************************************************************************/
    private deleteMeasureHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .deleteMeasure(Number(req.params.measureSid), req.query.countryId as string)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDenormalisedHandler
     *********************************************************************************************/
    private getDenormalisedHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getMeasuresDenormalised(
                req.query.countryId as string,
                req.query.gdp === 'true',
                MeasureSharedService.getReqArchiveParams(req.query),
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMeasureColumnsHandler
     *********************************************************************************************/
    private getMeasureColumnsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getMeasureColumns(req.params.page, Number(req.params.year)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getUploadTemplateHandler
     *********************************************************************************************/
    private getUploadTemplateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getWizardTemplate(
                req.params.countryId,
                Number(req.params.roundSid),
                req.query.withData === 'true',
                Number(req.query.dataHistoryOffset) || 0,
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method saveMeasureHandler
     *********************************************************************************************/
    private saveMeasureHandler = (req: Request, res: Response, next: NextFunction) => {
        if (!req.params.measureSid || Number(req.params.measureSid) === req.body.measure.MEASURE_SID) {
            this.controller.saveMeasure(req.body.measure).then(res.json.bind(res), next)
        } else {
            res.json(-1)
        }
    }

    /**********************************************************************************************
     * @method setMeasureValuesHandler
     *********************************************************************************************/
    private setMeasureValuesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .setMeasureValues(
                Number(req.params.measureSid),
                req.body.countryId,
                Number(req.body.year),
                Number(req.body.startYear),
                req.body.values,
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method uploadMeasuresHandler
     *********************************************************************************************/
    private uploadMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .uploadWizardMeasures(req.params.countryId, Number(req.params.roundSid), req.body)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getWizardDefinitionHandler
     *********************************************************************************************/
    private getWizardDefinitionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getWizardDefinition(req.params.countryId, Number(req.params.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getScalesHandler
     *********************************************************************************************/
    private getScalesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getScales().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method updateScaleHandler
     *********************************************************************************************/
    private updateScaleHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .updateMeasureScale(req.params.countryId, Number(req.body.scaleSid))
            .then(res.json.bind(res), next)
}
