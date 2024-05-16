import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'
import { Query } from 'express-serve-static-core'

import { AuthzError, LoggingService } from '../../../lib/dist'
import { IAmecoInternalLegacyInputParams, IAmecoLegacyInputParams } from '.'
import { AmecoController } from './ameco.controller'
import { AmecoService } from './ameco.service'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { IWQInputParams } from '../shared/shared-interfaces'
import { ParamsService } from '../shared/params.service'
import { RequestService } from '../../../lib/dist/request.service'
import { SharedService } from '../shared/shared.service'
import { WqRouter } from '../shared/wq.router'
import { config } from '../../../config/config'


export class AmecoRouter extends WqRouter {

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        intragate: boolean, sharedService: SharedService, logs: LoggingService
    ): Router {
        return new AmecoRouter(intragate, sharedService, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: AmecoController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private intragate: boolean, sharedService: SharedService, private logs: LoggingService
    ) {
        super()
        this.controller = new AmecoController(new AmecoService(), sharedService, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router
            // routes for backward compatibility - replacement of php wq service
            .get('/', this.checkIntragate(), this.getAmecoDataHandler(AmecoType.CURRENT))
            .get('/series', this.checkIntragate(), this.getAmecoDataHandler(AmecoType.CURRENT))
            .get('/annex_series', this.checkIntragate(), this.getAmecoDataHandler(AmecoType.PUBLIC))
            .get('/restricted_series',
                this.checkIntragate(),
                this.checkAmecoRestrictedAccess(true,'ADMIN', 'FORECAST'),
                this.getAmecoRestrictedLegacyDataHandler
            )
            // new routes
            .get('/public', this.checkIntragate(), this.getAmecoDataHandler(AmecoType.PUBLIC))
            .get('/public/iqy', this.checkIntragate(), this.getAmecoIqyFileHandler(AmecoType.PUBLIC))
            .get('/online', this.getAmecoDataHandler(AmecoType.ONLINE))
            .get('/online/iqy', this.getAmecoIqyFileHandler(AmecoType.ONLINE))
            .get('/current', this.checkIntragate(), this.getAmecoDataHandler(AmecoType.CURRENT))
            .get('/current/iqy', this.checkIntragate(), this.getAmecoIqyFileHandler(AmecoType.CURRENT))
            .get('/restricted',
                this.checkIntragate(),
                this.checkAmecoRestrictedAccess(false,'ADMIN', 'FORECAST'),
                this.getAmecoRestrictedDataHandler
            )
            .get('/restricted/iqy',
                this.checkIntragate(),
                this.getAmecoIqyFileHandler(AmecoType.RESTRICTED)
            )
            .get('/metadata', this.getAmecoInternalMetadataHandler)
    }

    /**********************************************************************************************
     * @method customizeParams
     *********************************************************************************************/
    protected customizeParams(params: IWQInputParams): IWQInputParams {
        // workaround for ameco db invalid country iso3 for Romania
        params.countries = params.countries?.map(cty => cty === 'ROM' ? 'ROU' : cty)

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
                    title: 'Ameco API',
                    description: 'Ameco',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/ameco'), }]
            },
            apis: [
                this.getSwaggerFilePath('/shared/fpapi.components.yaml'),
                this.getSwaggerFilePath('/shared/security.schemas.yaml'),
                this.getSwaggerFilePath('/ameco.yaml')
            ],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoRestrictedLegacyDataHandler
     *********************************************************************************************/
    private getAmecoRestrictedLegacyDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoLegacyData(
            res.locals.amecoType, this.getLegacyInputParams(res.locals.amecoType, req.query)
        ).then(res.send.bind(res), next)

    /**********************************************************************************************
     * @method getAmecoDataHandler
     *********************************************************************************************/
    private getAmecoDataHandler(amecoType: AmecoType) {
        return (req: Request, res: Response, next: NextFunction) => this.processAmeco(amecoType, req, res, next)
    }

    /**********************************************************************************************
     * @method getAmecoRestrictedDataHandler
     *********************************************************************************************/
    private getAmecoRestrictedDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.processAmeco(res.locals.amecoType, req, res, next)

    /**********************************************************************************************
     * @method processAmeco
     *********************************************************************************************/
    private processAmeco(amecoType: AmecoType, req: Request, res: Response, next: NextFunction) {
        return (this.hasLegacyParams(req.query) ?
                this.controller.getAmecoLegacyData(amecoType, this.getLegacyInputParams(amecoType, req.query)) :
                this.controller.getAmecoData(amecoType, this.getInputParams(req.query))
        ).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method checkAmecoRestrictedAccess
     * This is for backward compatibility with php endpoint.
     * Outside forecast period when asking for 'restricted' data we're returning the 'current' data for legacyEndpoint,
     * and for "new" endpoint only if the "FOLLOW_FORECAST" query params is set.
     * For the "new" endpoint access can be also granted with the API-GATEWAY token.
     *********************************************************************************************/
    private checkAmecoRestrictedAccess(legacyEndpoint: boolean, ...authzGroups: string[]) {
        return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
            res.locals.amecoType = AmecoType.RESTRICTED
            if (legacyEndpoint || this.followForecast(req.query)) {
                return this.controller.isAmecoInternalForecastPeriod().then((isForecastPeriod) => {
                    if (!isForecastPeriod) res.locals.amecoType = AmecoType.CURRENT
                    return !isForecastPeriod ? next() :
                                               this.checkAmecoRestrictedExternalAccess(req, res, next, ...authzGroups)
                }, next)
            } else {
                return this.checkAmecoRestrictedExternalAccess(req, res, next, ...authzGroups)
            }
        }
    }

    /**********************************************************************************************
     * @method checkAmecoRestrictedExternalAccess
     *********************************************************************************************/
    private async checkAmecoRestrictedExternalAccess(
        req: Request, res: Response, next: NextFunction, ...authzGroups: string[]
    ): Promise<void> {
        if (this.hasExternalAuthorisation(req)) {
            this.logs.log('Received api-gateway request')
            const token = await this.getApiGtwToken()
            if (req.get('authorization') === `Bearer ${token.access_token}`) next()
            else next(new AuthzError())
        } else {
            return this.checkSecurity(...authzGroups)(req, res, next)
        }
    }

    /**********************************************************************************************
     * @method hasExternalAuthorisation
     *********************************************************************************************/
    private hasExternalAuthorisation(req: Request): boolean {
        return Boolean(req.get('authorization'))
    }

    /**********************************************************************************************
     * @method followForecast
     *********************************************************************************************/
    private followForecast(query: Query): boolean {
        const followForecast = Object.keys(query).find(key => key.toUpperCase() === 'FOLLOW_FORECAST')
        return ParamsService.boolParam(query[followForecast])
    }

    /**********************************************************************************************
     * @method getAmecoIqyFileHandler
     *********************************************************************************************/
    private getAmecoIqyFileHandler(amecoType: AmecoType) {
        return (req: Request, res: Response, next: NextFunction) =>
            this.controller.getAmecoIqyFile(amecoType, req.query).then(
                content => res.status(200)
                    .attachment(`ameco_${amecoType}_wq.iqy`)
                    .type('txt')
                    .send(content)
                , next
            )
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataHandler
     *********************************************************************************************/
    private getAmecoInternalMetadataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoInternalMetadata().then(res.send.bind(res), next)

    /**********************************************************************************************
     * @method hasLegacyParams
     *********************************************************************************************/
    private hasLegacyParams(query: Query): boolean {
        return Object.keys(query).find(key => key.toUpperCase() === 'FULLVARIABLE') !== undefined
    }

    /**********************************************************************************************
     * @method getLegacyInputParams
     *********************************************************************************************/
    private getLegacyInputParams(amecoType: AmecoType, query: Query): IAmecoLegacyInputParams {
        this.normalizeParams(query)

        const years = ParamsService.arrayParamUpper(query.years)
        return {
            countries: ParamsService.arrayParamUpper(query.countries),
            indicators: ParamsService.arrayParamUpper(query.fullvariable),
            defaultCountries: ParamsService.boolParam(query.defaultcountries),
            years: years ? years.map(Number) : undefined,
            lastYear: ParamsService.boolParam(query.lastyear),
            orderDesc: ParamsService.boolParamMatchValue(query.yearorder, 'DESC'),
            internal: amecoType !== AmecoType.ONLINE ? this.getLegacyInternalInputParams(query) : undefined
        }
    }

    /**********************************************************************************************
     * @method getLegacyInternalInputParams
     *********************************************************************************************/
    private getLegacyInternalInputParams(query: Query): IAmecoInternalLegacyInputParams {
        return {
            transpose: !ParamsService.boolParam(query.yearonxaxis, true),
            showVariable: ParamsService.boolParam(query.showvariable, true),
            useIso3: Number(query.countryiso) === 3,
            showFullVariable: ParamsService.boolParam(query.showfullvariable, true),
            showFullCode: ParamsService.boolParam(query.showfullcode, true),
            showLabel: ParamsService.boolParam(query.showlabel, true),
        }
    }

    /**********************************************************************************************
     * @method checkIntragate
     *********************************************************************************************/
    private checkIntragate() {
        return (req: Request, res: Response, next: NextFunction): Promise<void> => {
            if (!this.intragate) {
                res.status(404)
                res.send('Invalid request!')
                return
            }
            next()
        }
    }

    /**********************************************************************************************
     * @method getApiGtwToken call the API-GATEWAY to get the token
     *********************************************************************************************/
    private getApiGtwToken(): Promise<IToken> {
        const authString = Buffer.from(
            `${config.amecoToken.consumerKey}:${config.amecoToken.consumerSecret}`
        ).toString('base64')

        return RequestService.requestUri(
            config.amecoToken.apiGatewayEndpoint,
            'post', 'grant_type=client_credentials',
            {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': `Basic ${authString}`
            }, {}, false, false
        )
    }

}

interface IToken {
    access_token: string
    scope: string
    token_type: string
    expires_is: number
}
