import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { EApps } from 'config'
import { VintagesController } from './vintages.controller'
import { VintagesService } from './vintages.service'


export class VintagesRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        appId: EApps,
        dbService: DbService<DbProviderService>
    ): Router {
        return new VintagesRouter(appId, dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: VintagesController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, dbService: DbService<DbProviderService>) {
        super(appId)
        this.controller = new VintagesController(appId, new VintagesService(dbService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/attributes', this.getVtAppAttrs.bind(this))
            .get('/:year', this.getVintageData.bind(this))
            .get('/vintage/:vintageType/:viewType', this.getVintage.bind(this))
            .get('/vintage/views/:vintageType/:viewType', this.getVintageViews.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getVintageData
     *********************************************************************************************/
    private getVintageData(req: Request, res: Response, next: NextFunction) {
        this.controller.getVintageData(
            this.appId,
            Number(req.params.year),
            AuthzLibService.isAdmin(req)
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getVtAppAttrs
     *********************************************************************************************/
    private getVtAppAttrs(req: Request, res: Response, next: NextFunction) {
        this.controller.getVtAppAttrs(
            this.appId,
            AuthzLibService.isAdmin(req)
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getVintage
     *********************************************************************************************/
    private getVintage(req: Request, res: Response, next: NextFunction) {
        this.controller.getVintage(
            req.params.vintageType,
            req.params.viewType
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getVintageViews
     *********************************************************************************************/
    private getVintageViews(req: Request, res: Response, next: NextFunction) {
        this.controller.getVintageViews(
            req.params.vintageType,
            req.params.viewType
        ).then(res.json.bind(res), next)
    }

}
