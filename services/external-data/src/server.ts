import { NextFunction, Request, Response } from 'express'

import { Level, LoggingService } from '../../lib/dist'
import { AmecoRouter } from './ameco/ameco.router'
import { BaseServerDb } from '../../lib/dist/db/base-server-db'
import { DbNomicsRouter } from './dbnomics/dbnomics.router'
import { DbProviderService } from '../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../lib/dist/db/db.service'
import { ISchemaConfigs } from 'config'
import { ImfRouter } from './imf/imf.router'
import { NsiRouter } from './nsi/nsi.router'
import { SpiRouter } from './spi/spi.router'


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

    private _amecoDb: DbService<DbProviderService>
    private _amecoOnlineDb: DbService<DbProviderService>
    private _spiDb: DbService<DbProviderService>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        Promise.all([
            this.closeDbService(this._amecoDb),
            this.closeDbService(this._amecoOnlineDb),
            this.closeDbService(this._spiDb),
        ]).then(
            () => {
                this._logs.log('Server: Successfully closed all DBs')
                process.exit(0)
            },
            err => {
                this._logs.log(`Server: Error closing all DBs: ${err}`, Level.ERROR)
                process.exit(1)
            }
        )
    }

    /**********************************************************************************************
     * @method setup app specific setup
     *********************************************************************************************/
    protected setup(): void {
        this._amecoDb = DbService.createDbService(this._logs, BaseServerDb.schemas.ameco)
        this._amecoOnlineDb = DbService.createDbService(this._logs, BaseServerDb.schemas.ameco_online)

        if (this._intragate) this._spiDb = DbService.createDbService(this._logs, BaseServerDb.schemas.spi)
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/ameco', AmecoRouter.createRouter(this._amecoDb, this._amecoOnlineDb))

        if (this._intragate) {
            this.app
                .use('/imf', ImfRouter.createRouter())
                .use('/spi', SpiRouter.createRouter(this._spiDb))
                .use('/nsi', NsiRouter.createRouter())
                .use('/nomics', DbNomicsRouter.createRouter(this._logs))
        }
    }

    /**********************************************************************************************
     * @method error set up error handler
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
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/no-unused-vars */
    private errorHandler(err: any, req: Request, res: Response, next: NextFunction) {
        const error = `External service returned error: ${req.path} \n${err.toString()}`
        this._logs.log(error, Level.ERROR)
        res.status(err.statusCode || 500).send(err.error?.detail || err.error || error)
    }

    /**********************************************************************************************
     * @method closeDbService
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private closeDbService(service: DbService<any>): Promise<boolean> {
        if (!service) return Promise.resolve(true)
        return service.close().then(
            () => true,
            err => {
                this._logs.log(`Server: Error closing DB: ${err}`, Level.ERROR)
                return false
            }
        )
    }
}
