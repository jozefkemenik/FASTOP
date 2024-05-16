import * as proxy from 'express-http-proxy'
import { NextFunction, Request, Response, Router } from 'express'
import { Redis } from 'ioredis'

import { AccessTokenClient } from './accessTokenClient'
import { BaseRouter } from './baseRouter'
import { EApps } from 'config'
import { IUser } from './interfaces'
import { LoggingService } from '../../lib/dist'
import { config } from '../../config/config'

export class WqRouter extends BaseRouter {
    private static readonly INTRAGATE_WQ_APPS = [
        'dbp',
        'dfm',
        'drm',
        'fdms',
        'fdmsie',
        'scp',
        'sdmx',
        'imf',
        'spi',
        'nsi',
    ]

    private static readonly WQ_APPS = [
        'ameco',
    ]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method wqLoginHandler
     *********************************************************************************************/
    public static wqLoginHandler(redis: Redis, logs: LoggingService, ipBased = false) {
        return (req: Request, res: Response, next: NextFunction) =>
            AccessTokenClient.generateToken(req, redis, logs, ipBased).then(accessToken =>
                res.send(
                    '<h3 style="text-align: center; font-family: Arial, Helvetica, sans-serif;">' +
                    'You have successfully logged in to the FASTOP WebQuery services.<br>Your ' +
                    (ipBased ? 'IP address' : 'personal access code') +
                    ` will be valid for the next ${accessToken.timeout / (60 * 1000)} minutes.<br>` +
                    (ipBased
                        ? ''
                        : 'Please use it together with your EU Login username ' +
                        'when making calls to the WebServices.<br>') +
                    '<table cellspacing="1" cellpadding="0" style="border: none;margin: auto;padding-top: 20px;">' +
                    '<tr><td>username: </td>' +
                    `<td><span style="color: blue">${req.session.user.ecas.userId}</span></td>` +
                    (ipBased
                        ? ''
                        : '<td><button style="width: 120px;" onclick="location.reload();">Reload</button></td><tr>' +
                        '<tr><td>access code: </td><td>' +
                        '<input id="accessCode" maxlength="10" size="10" ' +
                        'readonly style="color: blue;border: none;" ' +
                        `value="${accessToken.token}"></input></td>` +
                        '<td><button style="width: 120px;" ' +
                        "onclick=\"document.getElementById('accessCode').select();" +
                        "document.execCommand('copy');\">Copy to clipboard</button></td></tr>") +
                    '</table></h3>',
                ),
                next,
            )
    }

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, redis: Redis, forIntragate: boolean): Router {
        return new WqRouter(logs, redis, forIntragate).config()
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
        const router = super.config().get('/test', this.getTestHandler.bind(this))
        const apps = WqRouter.WQ_APPS.concat(this.forIntragate ? WqRouter.INTRAGATE_WQ_APPS : [])
        apps.forEach(app => {
            router.use(
                `/${app}`,
                proxy(`${config.apps[EApps.WQ].host}:${config.apps[EApps.WQ].port}`, {
                    proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
                    proxyReqPathResolver: (req: Request) => `/${app}${req.url}`,
                }),
            )
        })

        return router
    }

    /**********************************************************************************************
     * @method checkAuth saves session in the request
     * Authentication and authorisation to be done in the WQ service
     * based on the presence of the auth headers in the request
     *********************************************************************************************/
    protected checkAuth(req: Request, res: Response, next: NextFunction): void {
        if (this.forIntragate) {
            AccessTokenClient.getUserSessionFromToken(req, this.redis).then(session => {
                req.session = session
                next()
            }, next)
        } else {
            next()
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTestHandler
     *********************************************************************************************/
    private getTestHandler(req: Request, res: Response) {
        const user: IUser = req.session?.user

        if (user?.authenticated) res.send(`<p>user ${user.ecas.userId} authentication succeeded</p>`)
        else res.status(401).send('Not authenticated')
    }
}
