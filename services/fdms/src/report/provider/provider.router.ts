import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../../lib/dist'
import { BaseRouter } from '../../../../lib/dist/base-router'
import { EApps } from 'config'
import { ProviderController } from './provider.controller'
import { ProviderService } from './provider.service'
import { SharedService } from '../../shared/shared.service'


export class ProviderRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new ProviderRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: ProviderController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService) {
        super(appId)
        this.controller = new ProviderController(new ProviderService(), sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .post('/data/keys/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getProviderDataByKeysHandler)
            .post('/data/:periodicityId/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getProviderDataHandler)
            .get('/countries',
                this.getProviderCountriesHandler)
            .get('/indicators',
                this.getProviderIndicatorsHandler)
            .get('/indicatorsMappings',
                this.getProviderIndicatorsMappingsHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviderDataHandler
     *********************************************************************************************/
    private getProviderDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderData(
            req.params.periodicityId,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
            req.body.providerIds,
            req.body.countryIds,
            req.body.indicatorIds,
            req.query.compress === 'true'
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderDataByKeysHandler
     *********************************************************************************************/
    private getProviderDataByKeysHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderDataByKeys(
            req.body.providerIds,
            req.body.keys,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
            req.query.compress === 'true'
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderCountriesHandler
     *********************************************************************************************/
    private getProviderCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderCountries(
            this.getArrayQueryParam(req.query.providerIds)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderIndicatorsHandler
     *********************************************************************************************/
    private getProviderIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderIndicators(
            this.getArrayQueryParam(req.query.providerIds),
            req.query.periodicity as string
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderIndicatorsMappingsHandler
     *********************************************************************************************/
    private getProviderIndicatorsMappingsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderIndicatorsMappings(
            this.getArrayQueryParam(req.query.providerIds),
            req.query.periodicity as string
        ).then(res.json.bind(res), next)

}
