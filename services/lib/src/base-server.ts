import * as express from 'express'
import * as morgan from 'morgan'

import { AuthzLibService, ErrorService, LoggingService, ServerInfoRouter } from '.'
import { CnsRouter } from './cns/cns.router'
import { EApps } from 'config'
import { MailRouter } from './mail/mail.router'
import { RemoteLoggerRouter } from './remote-logger.router'
import { config } from '../../config/config'

export abstract class BaseServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected readonly _app: express.Application
    protected readonly _appId: EApps
    protected readonly _intragate: boolean

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        protected readonly _logs: LoggingService,
        private readonly version?: string,
    ) {
        this._app = express()
        this._appId = _logs.appId
        this._intragate = ['windows', 'DEV'].includes(process.env.NODE_ENV) || process.env.NODE_ENV.endsWith('_INTRAGATE')
        this.setup()

        this.middleware()
        this.api()
        this.error()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get app() {
        return this._app
    }

    public get appId() {
        return this._appId
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method registerShutdownListeners
     *********************************************************************************************/
    protected registerShutdownListeners(): void {
        process.on('SIGTERM', () => {
            this._logs.log('Index: Received SIGTERM')
            this.shutdown()
        }).on('SIGINT', () => {
            this._logs.log('Index: Received SIGINT')
            this.shutdown()
        }).on('SIGUSR2', () => {
            this._logs.log('Index: Received SIGUSR2')
            this.shutdown()
        }).on('uncaughtException', err => {
            this._logs.log(`Index: Uncaught exception: ${err}`)
            this.shutdown()
        })
    }

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        // stub, should be overwritten by the app if specific cleanup required on shutdown
    }

    protected setup(): void {
        // stub, should be overwritten by the app if additional setup required
    }

    /**********************************************************************************************
     * @method middleware set up middleware
     *********************************************************************************************/
    protected middleware(): void {
        this.app
            .use(morgan('short'))
            .use(AuthzLibService.checkApiKey())
            .use(express.json({limit: `${config.JSONLimit}kb`}))
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        this.app
            .use('/cns', CnsRouter.createRouter(this.appId))
            .use('/mails', MailRouter.createRouter(this.appId))
            .use('/serverInfo', ServerInfoRouter.createRouter(this.version))
            .use('/log', RemoteLoggerRouter.createRouter(this._logs))
    }

    /**********************************************************************************************
     * @method error set up error handler
     *********************************************************************************************/
    protected error(): void {
        this.app.use(ErrorService.errorHandler(this._logs))
    }
}
