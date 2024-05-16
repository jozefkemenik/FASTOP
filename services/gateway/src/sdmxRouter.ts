import * as proxy from 'express-http-proxy'
import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'
import { LoggingService } from '../../lib/dist'
import { config } from '../../config/config'

import { BaseRouter } from './baseRouter'

export class SdmxRouter extends BaseRouter {

    private static readonly SDMX_APPS = ['bcs', 'ecfin']

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, forIntragate: boolean): Router {
        return new SdmxRouter(logs, forIntragate).config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(logs: LoggingService, forIntragate: boolean) {
        super(logs, forIntragate)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method config
     *********************************************************************************************/
    protected config(): Router {
        const router = super.config()
        SdmxRouter.SDMX_APPS.forEach(app => {
            router.use(`/${app}`, proxy(`${config.apps[EApps.SDMX].host}:${config.apps[EApps.SDMX].port}`, {
                proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
                proxyReqPathResolver: (req: Request) => `/dissemination/${app}${req.url}`,
            }))
        })

        return router
    }

    /**********************************************************************************************
     * @method checkAuth
     *********************************************************************************************/
    protected checkAuth(req: Request, res: Response, next: NextFunction): void {
        next()
    }
}
