import { NextFunction, Request, Response, Router } from 'express'

import { Level, LoggingService } from '../../lib/dist/logging.service'
import { EApps } from 'config'
import { IAccessInfo } from 'stats'
import { IUser } from './interfaces'
import { IUserAuthz } from 'users'
import { StatsApi } from '../../lib/dist/api/stats.api'
import { config } from '../../config/config'


export abstract class BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        protected readonly logs: LoggingService,
        protected readonly forIntragate?: boolean,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method config
     *********************************************************************************************/
    protected config(): Router {
        const router = Router()
        router.use(this.checkAuth.bind(this))
        router.use(this.stats.bind(this))

        return router
    }

    /**********************************************************************************************
     * @method checkAuth checks authentication
     *********************************************************************************************/
    protected abstract checkAuth(req: Request, res: Response, next: NextFunction): void

    /**********************************************************************************************
     * @method addAuthHeaders adds authorisation headers
     *********************************************************************************************/
    protected addAuthHeaders(app: string) {
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        return (proxyReqOpts: any, srcReq: Request) => {
            proxyReqOpts.headers.apiKey = config.apiKey

            if (this.forIntragate) proxyReqOpts.headers.onIntragate = 'true'
            else delete proxyReqOpts.headers.onIntragate

            if (srcReq.session) {
                const user: IUser = srcReq.session.user
                const authzs: IUserAuthz[] = user.impersonated[app] || user.authzs[app]

                proxyReqOpts.headers.authLogin = user.ecas.userId
                proxyReqOpts.headers.authDept = user.ecas.departmentNumber ?? ''
                proxyReqOpts.headers.authzs = ''

                if (authzs) {
                    for (const authz of authzs) {
                        proxyReqOpts.headers.authzs += `${authz.groupId},${authz.countries ?? ''}|`
                    }
                }
                // for addin and secunda pass full list of applications and access rights
                if ([EApps.ADDIN.toUpperCase(), EApps.SECUNDA.toUpperCase()].includes(app)) {
                    proxyReqOpts.headers.allAuthz = JSON.stringify(user.authzs)
                }
            } else {
                // delete auth headers if they have been set in the request by the caller
                delete proxyReqOpts.headers.authLogin
                delete proxyReqOpts.headers.authDept
                delete proxyReqOpts.headers.authzs
            }
            return proxyReqOpts
        }
    }

    /**********************************************************************************************
     * @method stats
     *********************************************************************************************/
    protected stats(req: Request, res: Response, next: NextFunction) {
        if (!this.skipStats(req.url, req.method)) {
            const user = req.session?.user
            const stats: IAccessInfo = {
                user: user?.ecas.userId,
                agent: req.headers['user-agent'],
                ip: req.headers['x-forwarded-for'] as string || req.socket.remoteAddress,
                url: req.originalUrl,
                intragate: this.forIntragate === true,
            }
            
            StatsApi.logStats(stats).catch(ex => {
                this.logs.log(`Stats service error: ${ex}`, Level.ERROR)
            })
        }
        next()
    }

    /**********************************************************************************************
     * @method skipStats
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected skipStats(url: string, method: string): boolean {
        return false
    }
}
