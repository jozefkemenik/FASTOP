import { BaseServer, LoggingService } from '../../lib/dist'

import { ConfigRouter } from './config/config.router'
import { StatusRouter } from './status/status.router'
import { TemplateRouter } from './template/template.router'

export class WebServer extends BaseServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(logs: LoggingService): WebServer {
        return new WebServer(logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        this.app
            .use('/config', ConfigRouter.createRouter())
            .use('/statuses', StatusRouter.createRouter())
            .use('/templates', TemplateRouter.createRouter())
    }
}
