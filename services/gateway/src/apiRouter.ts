import * as proxy from 'express-http-proxy'
import { NextFunction, Request, Response, Router, json } from 'express'
import { Redis } from 'ioredis'

import { IAccessToken, ITokens, IUserAuthz, IUserAuthzs, IUserInfo } from 'users'
import { Level, LoggingService } from '../../lib/dist/logging.service'
import { AccessTokenClient } from './accessTokenClient'
import { BaseApiRouter } from './baseApiRouter'
import { EApps } from 'config'
import { IUser } from './interfaces'
import { RequestService } from '../../lib/dist/request.service'
import { config } from '../../config/config'

export class ApiRouter extends BaseApiRouter {

    private static API_LOG_REGEXP = new RegExp('^(/fastop)?(/api)?/[A-Za-z0-9]*/log$')

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of ApiRouter
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, forIntragate: boolean, wqRedis: Redis): Router {
        return new ApiRouter(logs, wqRedis, forIntragate).config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    protected constructor(
        logs: LoggingService,
        private readonly wqRedis?: Redis,
        forIntragate?: boolean,
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

        router
            .get('/internal', this.isInternalHandler.bind(this))
            .get('/diag/:service?', this.getDiagnosticsHandler.bind(this))
            .post('/accessToken', this.getNewAccessTokenHandler.bind(this))
            .get('/accessToken', this.getAccessTokenHandler.bind(this))
            .post('/keepAlive', (req: Request, res: Response) => res.end())
            .get('/_myself_/:app?', (req: Request, res: Response) => {
                const user: IUser = req.session.user
                const app = req.params.app
                const userInfo: IUserInfo = {
                    login: user.ecas.userId,
                    name: `${user.ecas.firstName} ${user.ecas.lastName}`,
                    anonymous: user.anonymous,
                }
                if (app) {
                    const authzs = user.impersonated[app] || user.authzs[app]
                    if (authzs) {
                        userInfo.groups = authzs.reduce(
                            (acc, authz)=> (acc[authz.groupId] = authz.countries || [], acc), {}
                        )
                    }
                    if (user.impersonated[app]) userInfo.impersonated = true
                }
                res.json(userInfo)
            })
            .post(BaseApiRouter.LOGOUT_ROUTE, (req: Request, res: Response) => {
                req.session.destroy(err => err ? this.logs.log(err, Level.ERROR) : null)
                res.json({ecasLogout: `${config.ecas}/cas/logout`})
            })

        router.use(json())
        router.route('/_myself_/impersonate/:service')
            .all(this.impersonateCheckAuthz)
            .post((req: IImpersonateRequest, res: Response) => {
                req.impersonated[req.params.service] = [req.body]
                res.end()
            })
            .delete((req: IImpersonateRequest, res: Response) => {
                delete req.impersonated[req.params.service]
                res.end()
            })

        return router
    }

    /**********************************************************************************************
     * @method configAppServices
     *********************************************************************************************/
    protected configAppServices(router: Router) {
        config.appServices[this.forIntragate ? 'intragate' : 'webgate'].forEach(app => {
            router.use(`/${app}`, this.proxy_middleware(app))
        })
    }

    /**********************************************************************************************
     * @method skipStats
     *********************************************************************************************/
    protected skipStats(url: string, method: string): boolean {
        return ['/internal', '/diag', '/keepAlive', '/_myself_'].some(
            skipUrl => url.startsWith(skipUrl)
        ) || ApiRouter.API_LOG_REGEXP.test(url)
          || (method.toUpperCase() === 'GET' && url.startsWith('/accessToken'))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method proxy_middleware
     * Proxy the api calls to backend services.
     * For streaming the parsing of the body needs to be disabled and there's no size limit.
     *********************************************************************************************/
    private proxy_middleware(app: string) {
        return (req: Request, res: Response, next: NextFunction) => {
            const contentType = req.header('Content-Type')

            const proxyOptions: IProxyOptions = {
                proxyReqPathResolver: this.replaceMyself.bind(this),
                proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
            }
            if (contentType !== undefined && contentType.toLowerCase() === 'application/octet-stream') {
                proxyOptions.parseReqBody = false
            } else {
                proxyOptions.limit = `${config.JSONLimit}kb`
            }

            proxy(`${config.apps[app].host}:${config.apps[app].port}`, proxyOptions)(req, res, next)
        }
    }

    /**********************************************************************************************
     * @method replaceMyself replaces _myself_ with user login name in the request url
     *********************************************************************************************/
    private replaceMyself(req: Request): string {
        if (!req.url.includes('_myself_')) return req.url

        const user: IUser = req.session.user
        const unit = `unitId=${user.ecas.departmentNumber}`
        const external = this.forIntragate ? '' : '&external=true'
        const querySign = req.url.includes('?') ? '&' : '?'
        return `${req.url.replace(/_myself_/, user.ecas.userId)}${querySign}${unit}${external}`
    }

    /**********************************************************************************************
     * @method impersonateCheckAuthz perform for all impersonate actions
     *********************************************************************************************/
    private impersonateCheckAuthz = (req: IImpersonateRequest, res: Response, next: NextFunction) => {
        const service = req.params.service
        const user: IUser = req.session.user
        const authzs: IUserAuthz[] = user.authzs[service]

        if (authzs?.map(a => a.groupId).includes('SU')) {
            req.impersonated = user.impersonated
            next()
        } else {
            res.status(403).send('Not authorised')
        }
    }

    /**********************************************************************************************
     * @method getDiagnosticsHandler
     *********************************************************************************************/
    private getDiagnosticsHandler(req: Request, res: Response, next: NextFunction) {
        const service = req.params.service as EApps
        const action = req.query.action || 'mem'
        const user: IUser = req.session.user
        const authzs: IUserAuthz[] = user.authzs.DEV

        if (authzs?.map(a => a.groupId).includes('SU')) {
            if (service) {
                RequestService.request(
                    service, `/serverInfo/${action}`, 'get', undefined, {authzs: 'SU'}
                ).then(res.send.bind(res), next)
            } else res.json(process.memoryUsage())
        } else {
            res.status(403).send('Not authorised')
        }
    }

    /**********************************************************************************************
     * @method getNewAccessTokenHandler
     *********************************************************************************************/
    private getNewAccessTokenHandler(req: Request, res: Response, next: NextFunction) {
        const ipBased = req.query.ip === 'true'
        AccessTokenClient.generateToken(req, this.wqRedis, this.logs, ipBased).then(
            (token) => {
                if (!req.session.tokens) req.session.tokens = {}
                const sessionToken = Object.assign({}, token, { generationTime: Date.now() })
                if (ipBased) req.session.tokens.ip = sessionToken
                else req.session.tokens.code = sessionToken
                res.send(token)
            },
            next)
    }

    /**********************************************************************************************
     * @method getAccessTokenHandler
     *********************************************************************************************/
    private getAccessTokenHandler(req: Request, res: Response) {
        let tokens: ITokens = req.session.tokens
        if (tokens) {
            const now = Date.now()
            const expired = (t: IAccessToken) => t && (now - t.generationTime > t.timeout)
            if (expired(tokens.code)) delete tokens.code
            if (expired(tokens.ip)) delete tokens.ip

            if (!tokens.code && !tokens.ip) tokens = undefined
        }
        res.send(tokens)
    }

    /**********************************************************************************************
     * @method isInternalHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private isInternalHandler(req: Request, res: Response, next: NextFunction) {
        res.json(this.forIntragate)
    }
}

interface IImpersonateRequest extends Request {
    impersonated: IUserAuthzs
}

interface IProxyOptions {
    proxyReqPathResolver: (req: Request) => string
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    proxyReqOptDecorator: (proxyReqOpts: any, srcReq: Request) => any
    limit?: string
    parseReqBody?: boolean
}
