import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../../lib/dist'
import { BaseRouter } from '../../../../lib/dist/base-router'
import { DashboardApi } from '../../../../lib/dist/api/dashboard.api'
import { EApps } from 'config'
import { FdmsController } from './fdms.controller'

export class FdmsRouter<C extends FdmsController> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createFdmsRouter(
        appId: EApps, providers: Array<string> = null
    ): Router {
        return new FdmsRouter(appId, new FdmsController(), providers).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected readonly controller: C
    protected  providers: Array<string>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    protected constructor(appId: EApps, controller: C, providers: Array<string> = null) {
        super(appId)
        this.controller = controller
        this.providers = providers
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post(
                '/data/series',
                this.checkRoundAccess('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getFdmsDataByKeysHandler,
            )
            .post(
                '/data',
                this.checkRoundAccess('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getFdmsDataHandler,
            )
            .get('/countries', this.getFdmsCountriesHandler)
            .get('/indicators', this.getFdmsIndicatorsHandler)
            .get('/indicatorsMappings', this.getFdmsIndicatorsMappingsHandler)

        return router
    }

     ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkRoundAccess
     *********************************************************************************************/
    protected checkRoundAccess(...authzGroups: string[]) {
        return (req: Request, res: Response, next: NextFunction) => Promise.all([
                DashboardApi.getCurrentRoundInfo(EApps.FDMS),
                DashboardApi.getApplicationStatus(EApps.FDMS),
            ]).then(([currentRoundInfo, appStatus]) => {
                if (!this.isForecastPublished(appStatus, Number(req.query.roundSid), currentRoundInfo.roundSid)) {
                    AuthzLibService.checkAuthorisation(...authzGroups)(req, res, next)
                } else next()
            }, next)
    }

    /**********************************************************************************************
     * @method getFdmsCountriesHandler
     *********************************************************************************************/
    protected getFdmsCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderCountries(this.providers).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getFdmsIndicatorsHandler
     *********************************************************************************************/
    protected getFdmsIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderIndicators(
            this.providers, req.query.periodicity as string
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getFdmsIndicatorsMappingsHandler
     *********************************************************************************************/
    protected getFdmsIndicatorsMappingsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getFdmsIndicatorsMappings(
            this.providers, req.query.periodicity as string
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getFdmsDataHandler
     *********************************************************************************************/
    protected getFdmsDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderData(
            this.providers,
            req.body.countryIds,
            req.body.indicatorIds,
            req.query.periodicity as string,
            req.query.startPeriod as string,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.textSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getFdmsDataByKeysHandler
     *********************************************************************************************/
    protected getFdmsDataByKeysHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderDataByKeys(
            this.providers,
            req.body.keys,
            req.query.startPeriod as string,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.textSid),
        ).then(res.json.bind(res), next)
}
