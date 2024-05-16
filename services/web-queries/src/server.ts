import { urlencoded } from 'express'

import { BaseServer, LoggingService } from '../../lib/dist'
import { AmecoRouter } from './ameco/ameco.router'
import { DbpRouter } from './dbp/dbp.router'
import { DfmRouter } from './dfm/dfm.router'
import { DrmRouter } from './drm/drm.router'
import { EApps } from 'config'
import { FdmsRouter } from './fdms/fdms.router'
import { ImfRouter } from './imf/imf.router'
import { NsiRouter } from './nsi/nsi.router'
import { ScpRouter } from './scp/scp.router'
import { SdmxRouter } from './sdmx/sdmx.router'
import { SharedService } from './shared/shared.service'
import { SpiRouter } from './spi/spi.router'


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
        this.sharedService = new SharedService()
    }

    /**********************************************************************************************
     * @method middleware set up middleware
     *********************************************************************************************/
    protected middleware(): void {
        super.middleware()

        this.app
            .use(urlencoded({ extended: true }))
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        this.app
            .use('/ameco', AmecoRouter.createRouter(this._intragate, this.sharedService, this._logs))

        if (this._intragate) {
            this.app
                .use('/dbp', DbpRouter.createRouter(this.sharedService))
                .use('/dfm', DfmRouter.createRouter(this.sharedService))
                .use('/drm', DrmRouter.createRouter(this.sharedService))
                .use('/fdms', FdmsRouter.createRouter(EApps.FDMS, this.sharedService, this._logs))
                .use('/fdmsie', FdmsRouter.createRouter(EApps.FDMSIE, this.sharedService, this._logs))
                .use('/scp', ScpRouter.createRouter(this.sharedService))
                .use('/sdmx', SdmxRouter.createRouter(this.sharedService))
                .use('/imf', ImfRouter.createRouter(this.sharedService))
                .use('/spi', SpiRouter.createRouter(this.sharedService))
                .use('/nsi', NsiRouter.createRouter())
        }
    }
}
