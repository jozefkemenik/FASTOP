import { BaseAppServer, LoggingService } from '../../lib/dist'
import { LibTaskRouter } from '../../lib/dist/task/task.router'
import { ReportRouter } from './report/report.router'
import { SeriesRouter } from './series/series.router'
import { UploadRouter } from './upload/upload.router'
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

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/reports', ReportRouter.createRouter(this.appId))
            .use('/tasks', LibTaskRouter.createRouter(this.appId))
            .use('/uploads', UploadRouter.createRouter(this.appId))
            .use('/series', SeriesRouter.createRouter(this.appId))
    }
}
