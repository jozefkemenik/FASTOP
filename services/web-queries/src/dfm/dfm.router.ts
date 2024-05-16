import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'
import { Query } from 'express-serve-static-core'

import { AuthzLibService } from '../../../lib/dist'
import { AuthzService } from '../shared/authz.service'
import { DfmController } from './dfm.controller'
import { EApps } from 'config'
import { IWQImpactParams } from '../shared/shared-interfaces'
import { MeasureRouter } from '../common/measure/measure.router'
import { ParamsService } from '../shared/params.service'
import { SharedService } from '../shared/shared.service'


export class DfmRouter extends MeasureRouter<DfmController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new DfmRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super(new DfmController(sharedService, EApps.DFM))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return super.configFpapiRoutes(router)
            .get('/transferMatrix/:countryId', this.getCountryTransferMatrixHandler)
            .get('/additionalImpact/:countryId', this.getCountryAdditionalImpactHandler)
            .get(
                '/impact',
                AuthzService.checkWqAuthentication(this.controller.notAuthenticatedMessage),
                AuthzService.checkWqAuthorisation('ADMIN', 'CTY_DESK', 'READ_ONLY'),
                this.checkOneCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getImpactHandler,
            )
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'DFM API',
                    description: 'DFM',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/dfm'), }]
            },
            apis: [
                this.getSwaggerFilePath('/shared/measures.parameters.yaml'),
                this.getSwaggerFilePath('/shared/archive.parameters.yaml'),
                this.getSwaggerFilePath('/shared/security.schemas.yaml'),
                this.getSwaggerFilePath('/dfm.yaml')
            ],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryTransferMatrixHandler
     *********************************************************************************************/
    private getCountryTransferMatrixHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getCountryTransferMatrix(req.params.countryId).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCountryAdditionalImpactHandler
     *********************************************************************************************/
    private getCountryAdditionalImpactHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getCountryAdditionalImpact(req.params.countryId).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method checkOneCountryAuthorisation
     * Check country authorisation when one country defined
     * Filtering countries when no countryId defined is done in getImpact (when getting results)
     *********************************************************************************************/
    private checkOneCountryAuthorisation(countryGetter?: (req: Request) => string) {
        return (req: Request, res: Response, next: NextFunction) => {
            const countryReq = countryGetter(req)
            if (countryReq?.length) {
                return AuthzService.checkWqCountryAuthorisation(countryGetter)(req, res, next)
            } else {
                next()
            }
        }
    }

    /**********************************************************************************************
     * @method getImpactHandler
     * Return template results filtered by user countries
     *********************************************************************************************/
    private getImpactHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller
            .getImpact(this.getInputImpactParams(req.query), AuthzLibService.getUserCountries(req))
            .then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getInputImpactParams
     *********************************************************************************************/
    private getInputImpactParams(query: Query): IWQImpactParams {
        this.normalizeParams(query)
        return {
            aggregationType: ParamsService.stringParamUpper(query.aggregationtype, 'ESA'),
            countryId: ParamsService.stringParam(query.countryid, null),
            oneOff: ParamsService.numericParam(query.oneoff, null),
            isEuFunded: ParamsService.boolParam(query.iseufunded, true),
            euFundedIds: ParamsService.arrayParam(query.eufundedids)?.map(Number),
            totalImpact: ParamsService.numericParam(query.totalimpact),
            baseYear: ParamsService.numericParam(query.baseyear),
            isLight: ParamsService.boolParam(query.isLight, false),
        }
    }
}
