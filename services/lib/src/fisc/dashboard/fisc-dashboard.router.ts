import { EApps } from 'config'
import { Router } from 'express'

import { LibDashboardRouter } from '../../dashboard/lib-dashboard.router'
import { LoggingService } from '../../logging.service'

import { FiscDashboardController } from './fisc-dashboard.controller'

export class FiscDashboardRouter extends LibDashboardRouter<FiscDashboardController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService): Router {
        return new FiscDashboardRouter(new FiscDashboardController(appId, logs)).buildRouter()
    }
}
