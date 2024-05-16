import { BaseAppServer, Level, LoggingService, MongoDbService } from '../../lib/dist'
import { IDbProviderConfig, IMongoConfig, ISchemaConfigs } from 'config'
import { ReportRouter } from './report/report.router'
import { version } from '../version'

export class WebServer extends BaseAppServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected static schemas: ISchemaConfigs

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(schemas: ISchemaConfigs, logs: LoggingService): WebServer {
        WebServer.schemas = schemas
        return new WebServer(logs, version)
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
                this._logs.log('Successfully closed MongoDB client')
                process.exit(0)
            },
            err => {
                this._logs.log(`Error closing MongoDB client: ${err}`, Level.ERROR)
                process.exit(1)
            }
        )
    }

    /**********************************************************************************************
     * @method setup app specific setup
     *********************************************************************************************/
    protected setup(): void {
        const providerConfig: IDbProviderConfig = WebServer.schemas.cosnap.providerConfig
        this._db = new MongoDbService(this._logs, providerConfig as IMongoConfig)
        this.registerShutdownListeners()
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/report', ReportRouter.createRouter(this.appId, this._db))
    }
}
