import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { EApps } from 'config'

import { IndicesController } from './indices.controller'
import { IndicesService } from './indices.service'
import { SharedService } from '../shared/shared.service'


export class IndicesRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method IndicesRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        dbService: DbService<DbProviderService>,
        sharedService: SharedService,
        appId: EApps
    ): Router {
        return new IndicesRouter(dbService, sharedService, appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: IndicesController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(dbService: DbService<DbProviderService>
               ,sharedService: SharedService
               ,appId: EApps) {
        super()
        this.controller = new IndicesController(new IndicesService(dbService), sharedService, appId)
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
            .get('/headers/:indexSid/:year/countryId/:countryId', this.getIndiceEntryData.bind(this))
            .get('/:indexSid/:countryId/:roundSid', this.getIndiceData.bind(this))
            .get('/:indexSid/:multiEntry', this.getIndicators.bind(this))
            .post('/:indexSid/refresh/:countryId', this.refreshIndView.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getRootHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getRootHandler(req: Request, res: Response, next: NextFunction) {
        res.json('Indices API')
    }

    /**********************************************************************************************
     * @method getIndiceData
     *********************************************************************************************/
    private getIndiceData(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndiceData(
            req.params.countryId,
            Number(req.params.indexSid),
            Number(req.params.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getIndiceEntryData
     *********************************************************************************************/
    private getIndiceEntryData(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndiceEntryData(
            Number(req.params.indexSid),
            Number(req.params.year),
            req.params.countryId)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    private getIndicators(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndicators(
            Number(req.params.indexSid),
            Number(req.params.multiEntry))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method refreshIndView
     *********************************************************************************************/
     private refreshIndView(req: Request, res: Response, next: NextFunction) {
        this.controller.refreshIndView(
            Number(req.params.indexSid),
            Number(req.query.roundSid),
            req.params.countryId,
            req.body.entries)
        .then( res.json.bind(res), next )
    }

}
