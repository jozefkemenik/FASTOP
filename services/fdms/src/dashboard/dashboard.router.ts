import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, LoggingService } from '../../../lib/dist'
import { DashboardController } from './dashboard.controller'
import { DashboardService } from './dashboard.service'
import { EApps } from 'config'
import { EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { LibDashboardRouter } from '../../../lib/dist/dashboard/lib-dashboard.router'
import { SharedService } from '../shared/shared.service'


export class DashboardRouter extends LibDashboardRouter<DashboardController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService, sharedService: SharedService): Router {
        return new DashboardRouter(
            new DashboardController(appId, logs, new DashboardService(), sharedService)
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return super.configRoutes(router)
            .post('/multiAction/:action',
                AuthzLibService.checkAuthorisation('ADMIN'),
                AuthzLibService.checkCountryAuthorisation(req => req.body.countryIds),
                this.performMultiActionHandler)
            .get('/lastAcceptedStorage/:countryId',
                AuthzLibService.checkCountryAuthorisation(),
                this.getLastAcceptedStorageHandler)
            .put('/transferToScopax/:roundSid/:storageSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.transferToScopaxHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getLastAcceptedStorageHandler
     *********************************************************************************************/
    private getLastAcceptedStorageHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryLastAccepted(
            EApps.FDMS, [req.params.countryId],
            req.query.onlyFullStorage === 'true',
            req.query.onlyFullRound === 'true',
        ).then(
            cty => res.json(cty.get(req.params.countryId)),
            next
        )

    /**********************************************************************************************
     * @method performMultiActionHandler
     *********************************************************************************************/
    private performMultiActionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.performMultiAction(
            req.params.action as EDashboardActions,
            req.body.countryIds,
            req.body.roundKeys,
            req.body.comment,
            this.getUserId(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method transferToScopaxHandler
     *********************************************************************************************/
    private transferToScopaxHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.transferToScopax(
            Number(req.params.roundSid), Number(req.params.storageSid)
        ).then(res.json.bind(res), next)
}
