import { BaseAppServer, LoggingService } from '../../lib/dist'
import { DashboardRouter } from './dashboard/dashboard.router'
import { DocRouter } from './doc/doc.router'
import { ForecastRouter } from './forecast/forecast.router'
import { LibSdmxRouter } from '../../lib/dist/sdmx/sdmx.router'
import { LibTaskRouter } from '../../lib/dist/task/task.router'
import { ReportRouter } from './report/report.router'
import { RoundRouter } from './round/round.router'
import { SharedService } from './shared/shared.service'
import { TemplateRouter } from '../../lib/dist/template/template.router'
import { UploadRouter } from './upload/upload.router'
import { WebQueryRouter } from './web-query/web-query.router'
import { WorkflowRouter } from './workflow/workflow.router'
import { version } from '../version'


export class WebServer extends BaseAppServer {

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
        this.sharedService = new SharedService(this._logs)
    }

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/dashboard', DashboardRouter.createRouter(this.appId, this._logs, this.sharedService))
            .use('/reports', ReportRouter.createRouter(this.appId, this._logs, this.sharedService))
            .use('/round', RoundRouter.createRouter())
            .use('/tasks', LibTaskRouter.createRouter(this.appId))
            .use('/templates', TemplateRouter.createRouter(this.appId))
            .use('/uploads', UploadRouter.createRouter(this.appId, this.sharedService))
            .use('/workflow', WorkflowRouter.createRouter(this.appId))
            .use('/wq', WebQueryRouter.createRouter(this.appId, this.sharedService))
            .use('/doc', DocRouter.createRouter(this.appId))
            .use('/sdmx', LibSdmxRouter.createRouter(this.appId))
            .use('/forecast', ForecastRouter.createRouter(this.appId, this.sharedService))
    }
}
