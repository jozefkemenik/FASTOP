import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { EApps } from 'config'

import { AdminController } from './admin.controller'
import { AdminService } from './admin.service'
import { SharedService } from '../shared/shared.service'


export class AdminRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method AdminRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        appId: EApps,
        dbService: DbService<DbProviderService>,
        sharedService: SharedService
    ): Router {
        return new AdminRouter(appId, dbService, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: AdminController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, dbService: DbService<DbProviderService>, sharedService: SharedService) {
        super()
        this.controller = new AdminController(appId, new AdminService(dbService), sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/', this.getRootHandler.bind(this))
            .get('/entries/abolished', this.getAbolishedEntries.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getRootHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getRootHandler(req: Request, res: Response, next: NextFunction) {
        res.json('Admin API')
    }

    /**********************************************************************************************
     * @method getAbolishedEntries
     *********************************************************************************************/
    private getAbolishedEntries(req: Request, res: Response, next: NextFunction) {
        this.controller.getAbolishedEntries(
            this.appId)
        .then( res.json.bind(res), next )
    }

    

}
