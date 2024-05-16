import * as proxy from 'express-http-proxy'
import { Request, Router } from 'express'
import { BaseApiRouter } from './baseApiRouter'

import { EApps } from 'config'
import { LoggingService } from '../../lib/dist'
import { config } from '../../config/config'

export class AddinRouter extends BaseApiRouter {

    private static readonly ADDIN_APPS = ['fdms', 'ameco', 'auxtools']

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of ApiRouter
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, forIntragate: boolean, skipAppId = false): Router {
        return new AddinRouter(logs, forIntragate, skipAppId).config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        logs: LoggingService,
        forIntragate?: boolean,
        private readonly skipAppId?: boolean,
    ) {
        super(logs, forIntragate)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configAppServices
     *********************************************************************************************/
    protected configAppServices(router: Router) {
        AddinRouter.ADDIN_APPS.forEach(app => {
            router.use(`/${app}`, proxy(`${config.apps[EApps.ADDIN].host}:${config.apps[EApps.ADDIN].port}`, {
                limit: `${config.JSONLimit}kb`,
                proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
                proxyReqPathResolver: (req: Request) => `${this.skipAppId ? '' : '/' + app}${req.url}`
            }))
        })
    }
}
