import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import { ConfigController } from './config.controller'
import { ConfigService } from './config.service'
import { SharedService } from './../shared/shared.service'

import { EApps } from 'config'

export class ConfigRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService, dbService: DbService<DbProviderService>): Router {
        return new ConfigRouter(appId, sharedService, dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: ConfigController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(_app: EApps, sharedService: SharedService, dbService: DbService<DbProviderService>) {
        super()
        this.controller = new ConfigController(_app, new ConfigService(dbService), sharedService)
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
            .get('/editSteps', this.getEditSteps.bind(this))
            .get('/ifi/:countryId/:dets', this.getCountryIFI.bind(this))
            .get('/NFRCompliance/:mode', this.getComplianceHandler.bind(this))
            .get('/user/rights/:user', this.getUserApp.bind(this))
            .get('/user/rule/:user', this.getUserRule.bind(this))
            .get('/ifis', this.getIfis.bind(this))
            .get('/user/defaultQuestSid', this.getDefaultQuestSid.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRootHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getRootHandler(req: Request, res: Response, next: NextFunction) {
        res.json('Config API')
    }

    /**********************************************************************************************
     * @method getEditSteps
     *********************************************************************************************/
    private getEditSteps(req: Request, res: Response, next: NextFunction) {
        this.controller.getEditSteps().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getComplianceHandler
     *********************************************************************************************/
    private getComplianceHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getNFRCompliance(
            Number(req.query.ruleSid),
            Number(req.query.periodSid),
            req.params.mode,
            String(req.query.countryId)
            ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCountryIFI
     *********************************************************************************************/
    private getCountryIFI(req: Request, res: Response, next: NextFunction) {
        this.controller.getCountryIFI(
            req.params.countryId,
            Number(req.params.dets)
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getUserRule
     *********************************************************************************************/
    private getUserRule(req: Request, res: Response, next: NextFunction) {
        this.controller.getUserRule(
            req.params.user
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getUserApp
     *********************************************************************************************/
    private getUserApp(req: Request, res: Response, next: NextFunction) {
        this.controller.getUserApp(
            req.params.user
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getIfis
     *********************************************************************************************/
    private getIfis(req: Request, res: Response, next: NextFunction) {
        this.controller.getIfis().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getDefaultQuestSid
     *********************************************************************************************/
    private getDefaultQuestSid(req: Request, res: Response, next: NextFunction) {
        this.controller.getDefaultQuestSid().then(res.json.bind(res), next)
    }
}
