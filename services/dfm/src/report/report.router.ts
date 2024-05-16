import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, BaseRouter } from '../../../lib/dist'
import { IReportFilter } from '../../../shared-lib/dist/prelib/report'

import { IAdditionalImpactParams, IImpactParams } from '.'
import { ReportController } from './report.controller'
import { ReportService } from './report.service'
import { SharedService } from '../shared/shared.service'

export class ReportRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of MeasureRouter
     *********************************************************************************************/
    public static createRouter(
        sharedService: SharedService,
    ): Router {
        return new ReportRouter(new ReportController(new ReportService(sharedService), sharedService)).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly controller: ReportController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/additionalImpact',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'READ_ONLY'),
                (req: Request, res: Response, next: NextFunction) => {
                    const params: IAdditionalImpactParams = this.getQueryParams(req)

                    const excelHorizontalView = req.query.exportToExcel === 'true' && !params.countryId
                    this.controller.getAdditionalImpact(params, excelHorizontalView).then(res.json.bind(res), next)
                }
            )
            .get('/totalImpact',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'READ_ONLY'),
                (req: Request, res: Response, next: NextFunction) => {
                    const params: IAdditionalImpactParams = this.getQueryParams(req)

                    const excelHorizontalView = req.query.exportToExcel === 'true' && !params.countryId
                    this.controller.getTotalImpact(params, excelHorizontalView).then(res.json.bind(res), next)
                }
            )
            .get('/transferMatrix',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'READ_ONLY'),
                AuthzLibService.checkCountryAuthorisation(req => req.query.countryId as string),
                this.getCountryTransferMatrixHandler)
            .get('/measures',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'READ_ONLY'),
                AuthzLibService.checkCountryAuthorisation(req => req.query.countryId as string),
                this.getReportMeasuresHandler.bind(this))
    }

    /**********************************************************************************************
     * @method configInternalRoutes internal routes configuration for this router
     *********************************************************************************************/
    protected configInternalRoutes(router: Router): Router {
        return router
            .post('/fdms/measures',
                this.getFdmsMeasuresHandler)
            .get('/wqTransferMatrix',
                this.getCountryWqTransferMatrixHandler)
            .get('/wqAdditionalImpact',
                this.getCountryWqAdditionalImpactHandler)
            .get('/wqImpact', 
                this.getWqImpactHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getQueryParams
     *********************************************************************************************/
    private getQueryParams(req: Request): IAdditionalImpactParams {
        return {
            gdp: req.query.gdp === 'true',
            countryId: (req.query.countryId as string)?.toUpperCase(),
            archive: SharedService.getReqArchiveParams(req.query),
            filter: this.getFilterCriteria(req.query)
        }
    }

    /**********************************************************************************************
     * @method getQueryParamsImpact get query params for impact
     *********************************************************************************************/
    private getQueryParamsImpact(req: Request): IImpactParams {
        return { 
            ...this.getQueryParams(req), 
            groupBy: (req.query?.groupBy as string),
            isTotalImpact: (parseInt(req.query?.totalImpact as string) > 0),
            baseYear: (parseInt(req.query?.baseYear as string)),
        }
    }

    /**********************************************************************************************
     * @method getFilterCriteria
     *********************************************************************************************/
    private getFilterCriteria(query: Request['query']): IReportFilter {
        return {
            yearAdoption: (query?.fAdoptionYear as string)?.split(',')?.map(Number),
            monthAdoption: (query?.fAdoptionMonth as string)?.split(',')?.map(Number),
            labels: (query?.fLabel as string)?.split(',')?.map(Number),
            isEuFunded: (query?.fIsEuFunded as string)?.split(',')?.map(Number),
            oneOff: (query?.oneOff as string)?.split(',')?.map(Number),   
        }
    }

    /**********************************************************************************************
     * @method getFdmsMeasuresHandler
     *********************************************************************************************/
    private getFdmsMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getFdmsMeasures(
            req.body.countryIds?.map(id => id.toUpperCase()), this.getQueryParams(req)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryTransferMatrixHandler
     *********************************************************************************************/
    private getCountryTransferMatrixHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryTransferMatrix(this.getQueryParams(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryWqTransferMatrixHandler
     *********************************************************************************************/
    private getCountryWqTransferMatrixHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryWqTransferMatrix(this.getQueryParams(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryWqAdditionalImpactHandler
     *********************************************************************************************/
    private getCountryWqAdditionalImpactHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryWqAdditionalImpact(this.getQueryParams(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getWqImpactHandler
     *********************************************************************************************/
    private getWqImpactHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getWqImpact(this.getQueryParamsImpact(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getReportMeasuresHandler
     *********************************************************************************************/
    private getReportMeasuresHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getReportMeasures(this.getQueryParams(req)).then(res.json.bind(res), next)
    }
}
