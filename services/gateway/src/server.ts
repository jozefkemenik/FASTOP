import * as cs from 'cookie-signature'
import * as express from 'express'
import * as jwt from 'jsonwebtoken'
import * as morgan from 'morgan'
import * as path from 'path'
import * as session from 'express-session'
import { Application, NextFunction, Request, Response } from 'express'
import Redis from 'ioredis'
import RedisStore from 'connect-redis'
import { csrfSync } from 'csrf-sync'

import { ASSURANCE_LEVEL, AUTHENTICATION_LEVEL, EcasClient } from './ecasClient'
import { Level, LoggingService } from '../../lib/dist/logging.service'
import { AddinRouter } from './addinRouter'
import { ApiDocRouter } from './apiDocRouter'
import { ApiRouter } from './apiRouter'
import { DocRouter } from './docRouter'
import { EApps } from 'config'
import { FpapiRouter } from './fpapiRouter'
import { IEcasUser } from './interfaces'
import { IUserAuthzs } from 'users'
import { RequestService } from '../../lib/dist/request.service'
import { SdmxRouter } from './sdmxRouter'
import { WqRouter } from './wqRouter'
import { config } from '../../config/config'

export class WebServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly ECFIN_DEV_UNIT = 'ECFIN.R.3'
    private static readonly X_AUTH_TOKEN_HEADER = 'x-auth-token'
    private static readonly X_AUTH_TOKEN_HEADER_ANGULAR ='x-xsrf-token'
    private static readonly X_AUTH_TOKEN_COOKIE_ANGULAR ='XSRF-TOKEN'

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(logs: LoggingService, forIntragate = false): WebServer {
        return new WebServer(logs, forIntragate)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly _app: Application
    private readonly _ecasClient: EcasClient

    private _ecasPassthru = config.ecasPassthru && process.env.NODE_ENV === 'windows' ? {
        userId: config.ecasPassthru,
        loginDate: null,
        groups: [],
        departmentNumber: WebServer.ECFIN_DEV_UNIT,
    } : null

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly logs: LoggingService, private readonly forIntragate: boolean) {
        this._app = express()
        this._ecasClient = new EcasClient(
            this.getServiceUrl(forIntragate),
            this.getServiceUnsecurePort(forIntragate),
            this.getServiceSecurePort(),
            this.logs,
            {
                ecasBaseUrl: config.ecas,
                requestedGroups: 'ECFIN*',
                debug: true,
                userDetails: true,
                acceptedStrengths: ['STRONG', 'CLIENT_CERT'],
                authenticationLevel: forIntragate ? AUTHENTICATION_LEVEL.BASIC : AUTHENTICATION_LEVEL.MEDIUM,
                assuranceLevel: forIntragate ? ASSURANCE_LEVEL.TOP : ASSURANCE_LEVEL.LOW,
            }
        )
        this.config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get app() {
        return this._app
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServiceUrl
     *********************************************************************************************/
    private getServiceUrl(forIntragate: boolean): string {
        return config.ecasRedirect ? config.ecasRedirect.host :
               (forIntragate ? config.host : config.host.replace('intragate', 'webgate'))
    }

    /**********************************************************************************************
     * @method getServiceUnsecurePort
     *********************************************************************************************/
    private getServiceUnsecurePort(forIntragate: boolean): number {
        return config.ecasRedirect ? config.ecasRedirect.httpPort :
               (config.useHostPort ? (forIntragate ? config.intragatePort : config.httpPort) : 0)
    }

    /**********************************************************************************************
     * @method getServiceSecurePort
     *********************************************************************************************/
    private getServiceSecurePort(): number {
        return config.ecasRedirect ? config.ecasRedirect.httpsPort : (config.useHostPort ? config.httpsPort : 0)
    }

    /**********************************************************************************************
     * @method config
     *********************************************************************************************/
    private config(): void {
        const store = config.redis && new RedisStore({client: new Redis(config.redis), ttl: config.sessionTimeout})
        const wqRedis = this.forIntragate && config.redis && new Redis(
            Object.assign({}, config.redis, { keyPrefix: `${config.host}:` })
        )
        if (!store) {
            this.logs.log(
                'Running without redis store! Local development only. Not Suitable for production!', Level.WARNING
            )
        }
        this.app.enable('trust proxy')
        this.app.use(morgan('short'))
        this.app.use('/wq', WqRouter.createRouter(this.logs, wqRedis, this.forIntragate))
        this.app.use('/fpapi/1.0/', FpapiRouter.createRouter(this.logs, wqRedis, this.forIntragate))
        this.app.use('/fpapi', WqRouter.createRouter(this.logs, wqRedis, this.forIntragate))

        this.app.use('/sdmx/dissemination', SdmxRouter.createRouter(this.logs, this.forIntragate))
        if (this.forIntragate) this.app.use(this.processJwt)

        this.app.use(session({
            store,
            secret: config.secret,
            resave: false,
            rolling: true,
            saveUninitialized: true,
        }))

        if (config.useHostPort) this.app.use(this.rewriteUrl)

        this.app.use(
            csrfSync({
                getTokenFromRequest: req => req.headers[WebServer.X_AUTH_TOKEN_HEADER_ANGULAR] as string,
            }).csrfSynchronisedProtection
        )

        this.app.get('/', (_, res) => res.redirect('/menu/'))
        this.app.use('/test.html', express.static(path.join(__dirname, '..', 'static', 'test.html')))
        this.configureAddInRoutes()

        this.app.use('/api', ApiRouter.createRouter(this.logs, this.forIntragate, wqRedis))

        this.app.get('/favicon.ico', (_, res) => {
            res.sendFile(path.join(__dirname, '..', 'static', 'menu', 'favicon.ico'))
        })

        this.app.use(this.authenticate)
        this.app.use('/doc', DocRouter.createRouter(this.logs, this.forIntragate))
        this.app.use('/api-docs', ApiDocRouter.createRouter(this.logs))

        if (this.forIntragate) {
            this.app.get('/wqLogin.html', WqRouter.wqLoginHandler(wqRedis, this.logs))
            this.app.get('/wqIpLogin.html', WqRouter.wqLoginHandler(wqRedis, this.logs, true))
        }

        config.appServices[this.forIntragate ? 'intragate' : 'webgate'].concat('menu').forEach(app => {
            this.app.use(`/${app}`, express.static(path.join(__dirname, '..', 'static', app.toLowerCase())))
            this.app.get(`/${app}/*`, (_, res) =>
                res.sendFile(path.join(__dirname, '..', 'static', app.toLowerCase(), 'index.html')))
        })
    }

    /**********************************************************************************************
     * @method processJwt
     *********************************************************************************************/
    private processJwt = (req: Request, res: Response, next: NextFunction) => {
        const token = req.get(WebServer.X_AUTH_TOKEN_HEADER) || req.query.authToken
        if (token) {
            try {
                const data = jwt.verify(token, config.jwtSecret)
                const final = `s:${cs.sign(data.sessionId, config.secret)}`
                const cookieName = 'connect.sid'
                req.headers.cookie = `${cookieName}=${final};`
                req.headers[WebServer.X_AUTH_TOKEN_HEADER_ANGULAR] = data.xsrf
            } catch(err) {
                this.logs.log(`Failed to process the json web token: ${err}`, Level.WARNING)
            }
        }
        next()
    }

    /**********************************************************************************************
     * @method anonymousSession Excel web add-in requires public access
     *********************************************************************************************/
    private anonymousSession = (req: Request, res: Response, next: NextFunction) => {
        const reqSession = req.session

        if (req.query.reauthenticate !== undefined) {
            // for fp-explorer when session expires and user is redirected to home page
            // it should not create anonymous session but force the ecas authentication
            this.deleteAnonymousSessionUser(req)
        } else if (reqSession && !reqSession.user?.authenticated) {
            reqSession.user = {
                anonymous: true,
                authenticated: true,
                ecas: {
                    userId: 'anonymous',
                    loginDate: new Date().toDateString(),
                    groups: [],
                    firstName: 'anonymous',
                    lastName: '',
                },
                authzs: { 'ADDIN': [{ groupId: 'READ_ONLY', countries: [] }] },
                impersonated: {},
            }
        }

        next()
    }
    /**********************************************************************************************
     * @method configureAddInRoutes
     *********************************************************************************************/
    private configureAddInRoutes() {
        if (this.forIntragate) {
            config.appServices['intragate'].concat('menu').forEach(app => {
                this.app.use(`/${app}`, app.toLowerCase() === 'addin' ? this.anonymousSession : this.deleteAnonymousUser)
            })
            this.app.get('/addin/init', (req, res) => { res.send(this.getJwt(req)) })

            this.app.use(
                '/addin/assets/static',
                express.static(path.join(__dirname, '..', 'static', 'addin', 'assets', 'static'))
            )
            this.app.use('/addin/assets/ecas.html', this.deleteAnonymousUser)
            this.app.use('/api/addin/onbehalf', AddinRouter.createRouter(this.logs, this.forIntragate, true))
        }
    }

    /**********************************************************************************************
     * @method deleteAnonymousUser
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private deleteAnonymousUser = (req: Request, res: Response, next: NextFunction) => {
        this.deleteAnonymousSessionUser(req)

        next()
    }

    /**********************************************************************************************
     * @method deleteAnonymousSessionUser
     *********************************************************************************************/
    private deleteAnonymousSessionUser(req: Request) {
        if (req.session?.user?.anonymous) delete req.session.user
    }

    /**********************************************************************************************
     * @method getJwt JSON Web-Token will store sessionId and xsrf token as excel blocks cookies.
     * Token is then stored in local storage on client side and added to each request with interceptor.
     *********************************************************************************************/
    private getJwt(req: Request): string {
        return jwt.sign({
            sessionId: req.session.id,
            xsrf: req.csrfToken()
        }, config.jwtSecret)
    }

    /**********************************************************************************************
     * @method authenticate
    Authentication function.
    Must be called on each request.

    Authentication process:
     - if the user was already authenticated, no further action is taken and the previous result is returned.
     - otherwise authenticate function of ecasClient is called
     *********************************************************************************************/
    private authenticate = (req: Request, res: Response, next: NextFunction) => {
        const reqSession = req.session

        if (reqSession.user?.authenticated || req.path.endsWith('.js')) {
            next()
        } else {
            const authenticate: Promise<string|IEcasUser> = this._ecasPassthru
                ? Promise.resolve(this._ecasPassthru)
                /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                : this._ecasClient.authenticate(req as any)

            authenticate.then(
                response => {
                    if (typeof response === 'string') {
                        // Redirect to ECAS login page
                        res.redirect(response)
                    } else {
                        // Authenticated, get user authorisations
                        reqSession.user = {
                            authenticated: true,
                            ecas: response,
                            authzs: {},
                            impersonated: {},
                        }
                        // Set XSRF-TOKEN in the response
                        res.cookie(WebServer.X_AUTH_TOKEN_COOKIE_ANGULAR, req.csrfToken())

                        this.getAuthzs(response).then(
                            authzs => {
                                this.logs.log(`Server: secunda response: ${JSON.stringify(authzs)}`, Level.DEBUG)
                                reqSession.user.authzs = authzs
                                next()
                            },
                            reject => {
                                // error getting authorisation information
                                this.logs.log(`Server: secunda rejected: ${reject}`, Level.ERROR)
                                next()
                            })
                    }
                },
                reject => {
                    // Not authenticated
                    this.logs.log(`Server: ECAS rejected: ${reject}`, Level.WARNING)
                    res.status(401).send('Not authenticated')
                }
            )
        }
    }

    /**********************************************************************************************
     * @method getAuthzs gets user authorisations from secunda
     *********************************************************************************************/
    private getAuthzs(ecas: IEcasUser): Promise<IUserAuthzs> {
        this.logs.log(`Server: Calling secunda with [${ecas.userId}]`, Level.DEBUG)
        return RequestService.request(EApps.SECUNDA, `/users/${ecas.userId}/authzs?unit=${ecas.departmentNumber}`).then(
            authzs => this.forIntragate || (ecas.departmentNumber === WebServer.ECFIN_DEV_UNIT && config.webgateAdmin)
                ? authzs
                : this.webgateAuthzs(authzs),
            err => (this.logs.log(`Secunda error: ${err}`, Level.ERROR), {} as IUserAuthzs)
        )
    }

    /**********************************************************************************************
     * @method rewriteUrl removes /fastop pefix - required for hosted environment without rp
     *********************************************************************************************/
    private rewriteUrl = (req: Request, res: Response, next: NextFunction) => {
        if (config.useHostPort) req.url = req.url.replace(/\/fastop/, '')
        next()
    }

    /**********************************************************************************************
     * @method webgateAuthzs downgrade user rights on webgate
     *********************************************************************************************/
    private webgateAuthzs(userAuthzs: IUserAuthzs): IUserAuthzs {
        return Object.fromEntries(Object.entries(userAuthzs).map(([app, authzs]) => {
            for (const authz of authzs) {
                if (['SU', 'ADMIN'].includes(authz.groupId)) authz.groupId = 'CTY_DESK'
            }
            return [app, authzs]
        }))
    }
}
