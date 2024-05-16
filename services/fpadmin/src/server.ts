import { BaseAppServer, LoggingService } from '../../lib/dist'
import { AddinRouter } from './addin/addin.router'
import { IndicatorsRouter } from './indicators/indicators.router'
import { LogRouter } from './log/log.router'
import { NotificationRouter } from './notification/notification.router'
import { TasksRouter } from './tasks/tasks.router'
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
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/logs', LogRouter.createRouter(this.appId))
            .use('/notification', NotificationRouter.createRouter(this.appId))
            .use('/addin', AddinRouter.createRouter(this.appId))
            .use('/tasks', TasksRouter.createRouter(this.appId))
            .use('/indicators', IndicatorsRouter.createRouter(this.appId))
    }
}
