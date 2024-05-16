import { NextFunction, Request, Response } from 'express'

import { AuthzLibService, BaseServerDb, IError, Level, LoggingService, MongoDbService } from '../../lib/dist'
import { IDbProviderConfig, IMongoConfig, ISchemaConfigs } from 'config'
import { AppRouter } from './app/app.router'


export class WebServer extends BaseServerDb {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(schemas: ISchemaConfigs, logs: LoggingService): WebServer {
        BaseServerDb.schemas = schemas
        return new WebServer(logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _db: MongoDbService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        this._db.close().then(
            () => {
                this._logs.log('Server: Successfully closed MongoDB')
                process.exit(0)
            },
            err => {
                this._logs.log(`Server: Error closing MongoDB: ${err}`, Level.ERROR)
                process.exit(1)
            }
        )
    }

    /**********************************************************************************************
     * @method setup app specific setup
     *********************************************************************************************/
    protected setup(): void {
        const providerConfig: IDbProviderConfig = BaseServerDb.schemas.airflow.providerConfig
        this._db = new MongoDbService(this._logs, providerConfig as IMongoConfig)
    }

    /**********************************************************************************************
     * @method middleware set up middleware
     *********************************************************************************************/
    protected middleware(): void {
        super.middleware()

        this.app
            .use(AuthzLibService.checkAuthorisation())
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/', AppRouter.createRouter(this._db, this._logs))
    }

    /**********************************************************************************************
     * @method error set up error handler
     * @overrides
     *********************************************************************************************/
    protected error(): void {
        this.app.use(this.errorHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method errorHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private errorHandler(err: IError, req: Request, res: Response, next: NextFunction) {
        const error = `MongoDB error: ${req.path} \n${err.toString()}`
        this._logs.log(error, Level.ERROR)
        res.status(500).send(error)
    }
}
