import * as proxy from 'express-http-proxy'
import { NextFunction, Request, Response, Router } from 'express'
import { Redis } from 'ioredis'

import { AccessTokenClient } from './accessTokenClient'
import { BaseRouter } from './baseRouter'
import { EApps } from 'config'
import { LoggingService } from '../../lib/dist'
import { config } from '../../config/config'

export class FpapiRouter extends BaseRouter {
    private static readonly FPAPI_APPS = [
        'ameco'
    ]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, redis: Redis, forIntragate: boolean): Router {
        return new FpapiRouter(logs, redis, forIntragate).config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(
        logs: LoggingService, private readonly redis: Redis, forIntragate: boolean
    ) {
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
        FpapiRouter.FPAPI_APPS.forEach(app => {
            router.use(
                `/json/${app}`,
                proxy(`${config.apps[EApps.FPAPI].host}:${config.apps[EApps.FPAPI].port}`, {
                    proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
                    proxyReqPathResolver: (req: Request) => `/json/${app}${req.url}`,
                }),
            )
        })

        router.use(
            `/data/:provider`,
            proxy(`${config.apps[EApps.FPAPI].host}:${config.apps[EApps.FPAPI].port}`, {
                proxyReqOptDecorator: (proxyReqOpts: unknown, srcReq: Request) =>
                    this.addAuthHeaders(srcReq.params.provider.toUpperCase())(proxyReqOpts, srcReq),
                proxyReqPathResolver: (req: Request) => `/data/${req.params.provider.toLowerCase()}${req.url}`,
            })
        )

        return router
    }

    /**********************************************************************************************
     * @method checkAuth saves session in the request
     * Authentication and authorisation to be done in the FPAPI service
     * based on the presence of the auth headers in the request
     *********************************************************************************************/
    protected checkAuth(req: Request, res: Response, next: NextFunction): void {
        AccessTokenClient.getUserSessionFromToken(req, this.redis).then(session => {
            req.session = session
            next()
        }, next)
    }
}
