import * as proxy from 'express-http-proxy'
import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from './baseRouter'
import { IUser } from './interfaces'
import { LoggingService } from '../../lib/dist/logging.service'
import { config } from '../../config/config'


export class DocRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, forIntragate: boolean): Router {
        return new DocRouter(logs, forIntragate).config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method config
     *********************************************************************************************/
    protected config(): Router {
        const router = super.config()
        config.appServices[this.forIntragate ? 'intragate' : 'webgate'].forEach(app => {
            router.use(`/${app}`, proxy(`${config.apps[app].host}:${config.apps[app].port}`, {
                proxyReqPathResolver: (req: Request) => `/doc${req.url}`,
                proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
            }))
        })

        return router
    }

    /**********************************************************************************************
     * @method checkAuth checks authentication
     *********************************************************************************************/
    protected checkAuth(req: Request, res: Response, next: NextFunction): void {
        const user: IUser = req.session.user
        if (!req.get('internal') && user?.authenticated) {
            next()
        } else {
            // Not authenticated
            res.status(401).send('Not authenticated')
        }
    }
}
