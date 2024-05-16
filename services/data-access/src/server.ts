import { NextFunction, Request, Response } from 'express'

import { AuthzLibService, IError, Level, LoggingService } from '../../lib/dist'
import { BaseServerDb } from '../../lib/dist/db/base-server-db'
import { ConfigRouter } from './config/config.router'
import { DbProviderService } from '../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../lib/dist/db/db.service'
import { ExecRouter } from './exec/exec.router'
import { FileRouter } from './file/file.router'
import { ISchemaConfigs } from 'config'


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

    private _db: DbService<DbProviderService>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        this._db.close().then(
            () => {
                this._logs.log('Server: Successfully closed DB')
                process.exit(0)
            },
            err => {
                this._logs.log(`Server: Error closing DB: ${err}`, Level.ERROR)
                process.exit(1)
            }
        )
    }

    /**********************************************************************************************
     * @method setup app specific setup
     *********************************************************************************************/
    protected setup(): void {
        this._db = DbService.createDbService(this._logs, Object.values(BaseServerDb.schemas)[0])
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
            .use('/config', ConfigRouter.createRouter(this._db))
            .use('/exec', ExecRouter.createRouter(this._db))
            .use('/files', FileRouter.createRouter(this._logs))
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
        const error = `DB error: ${req.path} \n${err.toString()}`
        this._logs.log(error, Level.ERROR)
        res.status(500).send(error)
    }
}
