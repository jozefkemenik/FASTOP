import { BaseServer, LoggingService } from '../../lib/dist'
import { MenuRouter } from '../../lib/dist/menu/menu.router'

import { ConfigRouter } from './config/config.router'
import { DashboardRouter } from './dashboard/dashboard.router'
import { MeasureRouter } from './measure/measure.router'
import { ReportRouter } from './report/report.router'
import { SharedService } from './shared/shared.service'
import { WorkflowRouter } from './workflow/workflow.router'
import { version } from '../version'

export class WebServer extends BaseServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(logs: LoggingService): WebServer {
        return new WebServer(logs, version)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private sharedService: SharedService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method setup local setup function
     * @overrides
     *********************************************************************************************/
    protected setup(): void {
        this.sharedService = new SharedService(this.appId)
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/config', ConfigRouter.createRouter(this.sharedService))
            .use('/menus', MenuRouter.createRouter(this.sharedService.menuService))
            .use('/dashboard', DashboardRouter.createRouter(this.appId, this._logs))
            .use('/measures', MeasureRouter.createRouter(this.appId, this.sharedService))
            .use('/reports', ReportRouter.createRouter(this.sharedService))
            .use('/workflow', WorkflowRouter.createRouter(this.appId))
    }
}
