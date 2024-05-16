import { BaseAppServer, LoggingService } from '../../lib/dist'

import { version } from '../version'

import { FMRRouter } from './fmr/fmr.router'
import { UploadRouter } from './upload/upload.router'

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
        this.app.use('/fmr', FMRRouter.createRouter(this.appId, this._logs))
        this.app.use('/upload', UploadRouter.createRouter(this.appId))
    }
}
