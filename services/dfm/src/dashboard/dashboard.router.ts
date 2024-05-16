import { Router } from 'express'

import { EApps } from 'config'

import { LibDashboardRouter } from '../../../lib/dist/dashboard/lib-dashboard.router'
import { LoggingService } from '../../../lib/dist'

import { DashboardController } from './dashboard.controller'
import { DashboardService } from './dashboard.service'

export class DashboardRouter extends LibDashboardRouter<DashboardController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of DashboardRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService): Router {
        return new DashboardRouter(appId, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, logs: LoggingService) {
        super(new DashboardController(appId, logs, new DashboardService()))
    }
}
