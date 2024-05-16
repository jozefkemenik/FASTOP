import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import { IndexesController } from './indexes.controller'
import { IndexesService } from './indexes.service'
import { SharedService } from './../shared/shared.service'

import { EApps } from 'config'

export class IndexesRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method IndexesRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService, dbService: DbService<DbProviderService>, appId: EApps): Router {
        return new IndexesRouter(sharedService, dbService, appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: IndexesController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService, dbService: DbService<DbProviderService>, appId: EApps,) {
        super()
        this.controller = new IndexesController(new IndexesService(dbService), sharedService, appId)
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
            .get('/:indexSid/:countryId/stages', this.getCountryStages.bind(this))
            .get('/:indexSid/horizontal', this.getHorizontalStages.bind(this))
            .get('/:indexSid/refresh', this.refreshHorizView.bind(this))
            .get('/:indexSid/horizontal/columns', this.getHorizontalColumns.bind(this))
            .put('/:indexSid/:countryId/calculateScores',
                this.setAutomaticScores.bind(this))
            .post('/:indexSid/:countryId/stages', this.completeIndexCalculationStage.bind(this))
            .delete('/:indexSid/:countryId/stages/:stageSid',
                this.reopenIndexCalculationStage.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRootHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getRootHandler(req: Request, res: Response, next: NextFunction) {
        res.json('Indexes API')
    }

    /**********************************************************************************************
     * @method getCountryStages
     *********************************************************************************************/
    private getCountryStages(req: Request, res: Response, next: NextFunction) {
        this.controller.getCountryStages(
            Number(req.params.indexSid),
            String(req.params.countryId),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getHorizontalStages
     *********************************************************************************************/
    private getHorizontalStages(req: Request, res: Response, next: NextFunction) {
        this.controller.getHorizontalStages(
            Number(req.params.indexSid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method refreshHorizView
     *********************************************************************************************/
     private refreshHorizView(req: Request, res: Response, next: NextFunction) {
        this.controller.refreshHorizView(
            Number(req.params.indexSid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getHorizontalColumns
     *********************************************************************************************/
    private getHorizontalColumns(req: Request, res: Response, next: NextFunction) {
        this.controller.getHorizontalColumns(
            Number(req.params.indexSid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setAutomaticScores
     *********************************************************************************************/
    private setAutomaticScores(req: Request, res: Response, next: NextFunction) {
        this.controller.setAutomaticScores(
            Number(req.params.indexSid),
            req.params.countryId as string,
            Number(req.body.roundSid),
            this.getUserId(req),
            this.getUserUnit(req),
            req.body.rules)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method completeIndexCalculationStage
     *********************************************************************************************/
    private completeIndexCalculationStage(req: Request, res: Response, next: NextFunction) {
        this.controller.completeIndexCalculationStage(
            Number(req.params.indexSid),
            req.params.countryId,
            Number(req.body.roundSid),
            Number(req.body.stageSid),
            this.getUserId(req),
            this.getUserUnit(req),
            AuthzLibService.isMS(req),
            req.body.entries
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method reopenIndexCalculationStage
     *********************************************************************************************/
    private reopenIndexCalculationStage(req: Request, res: Response, next: NextFunction) {
        this.controller.reopenIndexCalculationStage(
            Number(req.params.indexSid),
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.params.stageSid))
        .then( res.json.bind(res), next )
    }
}
