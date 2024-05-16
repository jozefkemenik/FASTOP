import { ISchemaConfigs } from 'config'

import { Level, LoggingService } from '../../lib/dist'
import { BaseServerDb } from '../../lib/dist/db/base-server-db'
import { MenuRouter } from '../../lib/dist/menu/menu.router'
import { version } from '../version'

import { AuthzRouter } from './authz/authz.router'
import { SharedService } from './shared/shared.service'
import { SumDbService } from './db/sum.db.service'
import { UserRouter } from './user/user.router'

export class WebServer extends BaseServerDb {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(schemas: ISchemaConfigs, logs: LoggingService): WebServer {
        BaseServerDb.schemas = schemas
        return new WebServer(logs, version)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private sharedService: SharedService
    private sumDbService: SumDbService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        this.sumDbService.close().then(
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
     * @method setup local setup function
     * @overrides
     *********************************************************************************************/
    protected setup(): void {
        this.sharedService = new SharedService(this.appId)
        this.sumDbService = new SumDbService(this._logs, BaseServerDb.schemas.sum)
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/menus', MenuRouter.createRouter(this.sharedService.menuService))
            .use('/users', UserRouter.createRouter(this._logs, this.sumDbService))
            .use('/authz', AuthzRouter.createRouter())
    }
}
