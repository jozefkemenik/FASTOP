import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'
import { IWQFdmsRequestParams } from '.'

import { AuthnRequiredError, AuthzLibService, LoggingService } from '../../../lib/dist'
import { AmecoController } from '../ameco/ameco.controller'
import { AmecoService } from '../ameco/ameco.service'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { EApps } from 'config'
import { FdmsApi } from '../../../lib/dist/api/fdms.api'
import { FdmsController } from './fdms.controller'
import { FdmsService } from './fdms.service'
import { ForecastType } from '../../../fdms/src/forecast/shared-interfaces'
import { IWQAmecoRequestParams } from '../ameco/shared-interfaces'
import { IWQInputParams } from '../shared/shared-interfaces'
import { IWQRenderData } from '../shared'
import { SharedService } from '../shared/shared.service'
import { WqRouter } from '../shared/wq.router'
import { WqService } from '../shared/wq.service'

export class FdmsRouter extends WqRouter {

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        appId: EApps.FDMS | EApps.FDMSIE, sharedService: SharedService, logs: LoggingService
    ): Router {
        return new FdmsRouter(appId, sharedService, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private fdmsController: FdmsController
    private amecoController: AmecoController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps.FDMS | EApps.FDMSIE, sharedService: SharedService, logs: LoggingService
    ) {
        super(appId)
        this.fdmsController = new FdmsController(appId, new FdmsService(appId), sharedService, logs)
        this.amecoController = new AmecoController(new AmecoService(), sharedService, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router
            .get('/amecoHistorical', this.getAmecoHistoricalHandler)
            .get('/b1',
                this.addRoundInfo,
                this.getB1Handler)
            .get('/estatAnnual', this.getEurostatAnnualHandler)
            .get('/estatQuarterly', this.getEurostatQuarterlyHandler)
            .get('/estatMonthly', this.getEurostatMonthlyHandler)
            .get('/forecast',
                this.addRoundInfo,
                this.addAppStatus,
                this.checkSecurity('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getForecastIndicatorHandler)
            .get('/forecast/latestAvailable',
                this.addLatestAvailableInfo,
                this.addAppStatus,
                this.checkSecurity('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getForecastIndicatorHandler)
            .get('/forecastAmeco',
                this.addRoundInfo,
                this.addAppStatus,
                this.checkSecurity('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getForecastAmecoIndicatorHandler)
            .get('/irates', this.getInterestRatesHandler)
            .get('/tce',
                this.addRoundInfo,
                this.getTceHandler)
    }

    /**********************************************************************************************
     * @method checkAuthentication
     *********************************************************************************************/
    protected async checkAuthentication(req: Request, res: Response): Promise<boolean> {
        if (!AuthzLibService.isInternalCall(req)) {
            const [roundSid, currentRoundSid, appStatus] = [
                Number(req.query.roundSid),
                Number(res.locals.currentRoundSid),
                res.locals.appStatus,
            ]

            if (this.isForecastPublished(appStatus, roundSid, currentRoundSid)) return true
            else if (!AuthzLibService.isAuthenticated(req)) throw new AuthnRequiredError()
        }

        return false
    }

    /**********************************************************************************************
     * @method customizeParams
     *********************************************************************************************/
    protected customizeParams(params: IWQInputParams): IWQInputParams {
        if (!params.yearRange[0]) params.yearRange[0] = WqService.MIN_YEAR
        if (!params.yearRange[1]) params.yearRange[1] = new Date().getFullYear() + 2

        return params
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'Fdms API',
                    description: 'Fdms forecast endpoints',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/fdms'), }]
            },
            apis: [
                this.getSwaggerFilePath('/shared/fpapi.components.yaml'),
                this.getSwaggerFilePath('/shared/archive.parameters.yaml'),
                this.getSwaggerFilePath('/shared/security.schemas.yaml'),
                this.getSwaggerFilePath('/fdms.yaml')
            ],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoHistoricalHandler
     *********************************************************************************************/
    private getAmecoHistoricalHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getFdmsData(
            this.getInputParams(req.query), 'AMECO_H', 'Ameco historical'
        ).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getInterestRatesHandler
     *********************************************************************************************/
    private getInterestRatesHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getFdmsData(
            this.getInputParams(req.query), 'IRATES', 'Interest rates'
        ).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getEurostatAnnualHandler
     *********************************************************************************************/
    private getEurostatAnnualHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getEurostatData('ESTAT_A', this.getInputParams(req.query))
            .then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getEurostatQuarterlyHandler
     *********************************************************************************************/
    private getEurostatQuarterlyHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getEurostatData('ESTAT_Q', this.getInputParams(req.query))
            .then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getEurostatMonthlyHandler
     *********************************************************************************************/
    private getEurostatMonthlyHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getEurostatData('ESTAT_M', this.getInputParams(req.query))
            .then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getTceHandler
     *********************************************************************************************/
    private getTceHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getTceData(this.getInputParams(req.query)).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getB1Handler
     *********************************************************************************************/
    private getB1Handler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getFdmsData(
            this.getInputParams(req.query), 'B1', 'B1'
        ).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getForecastIndicatorHandler
     *********************************************************************************************/
    private getForecastIndicatorHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.fdmsController.getForecastIndicators(this.getInputParams(req.query)).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getForecastAmecoIndicatorHandler
     *********************************************************************************************/
    private getForecastAmecoIndicatorHandler = async (req: Request, res: Response, next: NextFunction) => {
        try {
            const params = this.getInputParams(req.query)
            const getKey = (indicator: string, geoArea: string) => `${indicator}_${geoArea}`
            const forecastData: IWQRenderData<IWQFdmsRequestParams> = await
                this.fdmsController.getForecastRawIndicators(params)
            const indCtySet: Set<string> = new Set<string>()
            forecastData.indicators.data.forEach(tplData => {
                indCtySet.add(getKey(tplData.indicatorId, tplData.country))
            })

            const amecoIndicators: Set<string> = new Set<string>()
            const amecoCountries: Set<string> = new Set<string>()
            params.indicators.forEach(indicatorId =>
                forecastData.countries.forEach(countryId => {
                    if (!indCtySet.has(getKey(indicatorId, countryId))) {
                        amecoIndicators.add(indicatorId)
                        amecoCountries.add(countryId)
                    }
                })
            )

            if (amecoIndicators.size) {
                const amecoParams = Object.assign({}, params,
                    { indicators: Array.from(amecoIndicators), countries: Array.from(amecoCountries)}
                )
                const amecoData = await this.getAmecoInternalCurrentData( amecoParams)
                forecastData.indicators.data = forecastData.indicators.data.concat(amecoData.indicators.data)
            }

            res.send(this.fdmsController.getForecastAmecoCurrent(forecastData, params))
        } catch(ex) {
            next(ex)
        }
    }

    /**********************************************************************************************
     * @method getAmecoInternalCurrentData
     *********************************************************************************************/
    private async getAmecoInternalCurrentData(params: IWQInputParams): Promise<IWQRenderData<IWQAmecoRequestParams>> {
        return this.amecoController.getAmecoRawData(AmecoType.CURRENT, params)
    }

    /**********************************************************************************************
     * @method addLatestAvailableInfo
     *********************************************************************************************/
    private addLatestAvailableInfo = (req: Request, res: Response, next: NextFunction): Promise<void> =>
        Promise.all([
            DashboardApi.getCurrentRoundInfo(this.appId),
            FdmsApi.getForecastRoundAndStorage(ForecastType.LATEST_FULLY_FLEDGED),
            DashboardApi.getApplicationStatus(this.appId),
        ]).then(([roundInfo, latestAvailable, appStatus]) => {
            req.query.roundSid = String(latestAvailable.roundSid)
            req.query.storageSid = String(latestAvailable.storageSid)
            res.locals.currentRoundSid = String(roundInfo.roundSid)
            res.locals.appStatus = appStatus
            next()
        }, next)
}
