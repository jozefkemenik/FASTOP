import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, LoggingService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { ETasks } from 'task'
import { ProviderRouter } from './provider/provider.router'
import { ReportController } from './report.controller'
import { ReportService } from './report.service'
import { SharedService } from '../shared/shared.service'
import { TceRouter } from './tce/tce.router'
import { TceService } from './tce/tce.service'


export class ReportRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService, sharedService: SharedService): Router {
        return new ReportRouter(appId, logs, sharedService).buildRouter({ mergeParams: true })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: ReportController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, private logs: LoggingService, private sharedService: SharedService) {
        super(appId)
        this.controller = new ReportController(
            appId, new ReportService(appId, sharedService), new TceService(appId, sharedService), logs, sharedService
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .use('/provider', ProviderRouter.createRouter(this.appId, this.sharedService))
            .use('/tce', TceRouter.createRouter(this.appId, this.sharedService))
            .get('/countryTableData/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getCountryTableDataHandler)
            .get('/countryTableExcel/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getCountryTableExcelHandler)
            .get('/countryTables/:countryId/:taskId?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getCountryTableHandler)
            .get('/detailedTables/:tableSid/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getDetailedTableHandler)
            .get('/detailedTables',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getDetailedTablesHandler)
            .get('/detailedTablesData/:countryId/:periodicityId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getDetailedTablesDataHandler)
            .get('/detailedTablesExcel/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getDetailedTablesExcelHandler)
            .get('/validationTables/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getValidationTableHandler)
            .get('/validationTables/:countryId/steps/:step',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getValidationStepDetailsHandler)
            .get('/indicators/:providerId/:periodicityId/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getProviderDataHandler)
            .post('/indicators/:providerId/:periodicityId/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getProviderDataPostHandler)
            .get('/providers',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getProvidersHandler)
            .get('/reportIndicators/:reportId',
                AuthzLibService.checkAuthorisation('ADMIN', 'AMECO'),
                this.getReportIndicatorsHandler)
            .get('/baseYear/:roundSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'AMECO'),
                this.getBaseYearHandler)
            .post('/indicatorScales/:providerId/:periodicityId',
                AuthzLibService.checkAuthorisation('ADMIN', 'AMECO'),
                this.getIndicatorScalesHandler)
            .get('/indicatorCountries',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getIndicatorCountriesHandler)
            .get('/indicatorsTree',
                this.getIndicatorsTreeHandler)
            .get('/xferAmecoFile/:ctyGroup',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getXferAmecoFileHandler)
            .get('/budg/:convertUnits?',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getBudgetReportHandler)
            .get('/sendXferAmecoFiles',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.sendXferAmecoFilesHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryTableDataHandler
     *********************************************************************************************/
    private getCountryTableDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryTableData(
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.custTextSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryTableExcelHandler
     *********************************************************************************************/
    private getCountryTableExcelHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryTableExcel(
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.custTextSid),
        ).then(file => this.sendFile(file, res), next)

    /**********************************************************************************************
     * @method getCountryTableHandler
     *********************************************************************************************/
    private getCountryTableHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryTable(
            req.params.taskId?.toUpperCase() as ETasks,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            req.params.countryId,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDetailedTableHandler
     *********************************************************************************************/
    private getDetailedTableHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDetailedTable(
            Number(req.params.tableSid),
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDetailedTablesDataHandler
     *********************************************************************************************/
    private getDetailedTablesDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDetailedTablesData(
            req.params.countryId,
            req.params.periodicityId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.custTextSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDetailedTablesDataHandler
     *********************************************************************************************/
    private getDetailedTablesExcelHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDetailedTablesExcel(
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.custTextSid),
        ).then(file => this.sendFile(file, res), next)

    /**********************************************************************************************
     * @method getDetailedTablesHandler
     *********************************************************************************************/
    private getDetailedTablesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDetailedTables().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getValidationStepDetailsHandler
     *********************************************************************************************/
    private getValidationStepDetailsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getValidationStepDetails(
            req.params.countryId,
            Number(req.params.step),
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getValidationTableHandler
     *********************************************************************************************/
    private getValidationTableHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getValidationTable(
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderDataHandler
     *********************************************************************************************/
    private getProviderDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderData(
            req.params.providerId,
            req.params.periodicityId,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
            this.getArrayQueryParam(req.query.countries),
            this.getArrayQueryParam(req.query.indicators),
            req.query.compress === 'true'
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderDataPostHandler
     *********************************************************************************************/
    private getProviderDataPostHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderData(
            req.params.providerId,
            req.params.periodicityId,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
            req.body.countryIds,
            req.body.indicatorIds,
            req.query.compress === 'true'
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProvidersHandler
     *********************************************************************************************/
    private getProvidersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviders().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getReportIndicatorsHandler
     *********************************************************************************************/
    private getReportIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getReportIndicators(req.params.reportId.toUpperCase()).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getBaseYearHandler
     *********************************************************************************************/
    private getBaseYearHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getBaseYear(Number(req.params.roundSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorScalesHandler
     *********************************************************************************************/
    private getIndicatorScalesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorScales(
            req.params.providerId,
            req.params.periodicityId,
            req.body.countryIds,
            req.body.indicatorIds,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorCountriesHandler
     *********************************************************************************************/
    private getIndicatorCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsTreeHandler
     *********************************************************************************************/
    private getIndicatorsTreeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorsTree().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getXferAmecoFileHandler
     *********************************************************************************************/
    private getXferAmecoFileHandler = (req: Request, res: Response, next: NextFunction) => {
        const ctyGroup: string = req.params.ctyGroup.toUpperCase()
        return this.controller.getXferAmecoFile(ctyGroup).then(file => {
                res.setHeader('Content-Disposition', `attachment;filename="${file.filename}"`)
                res.setHeader('Content-Type', file.contentType)
                res.write(file.raw)
                res.end()
            }, next)
    }

    /**********************************************************************************************
     * @method getBudgetReportHandler
     *********************************************************************************************/
    private getBudgetReportHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getBudgetReport('true' === req.params.convertUnits).then(res.json.bind(res), next)


    /**********************************************************************************************
     * @method sendXferAmecoFilesHandler
     *********************************************************************************************/
    private sendXferAmecoFilesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.sendXferAmecoFiles(this.getUserId(req)).then(res.json.bind(res), next)


}
