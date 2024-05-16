import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { BaseRouter } from '../../../lib/dist/base-router'
import { MeasureSharedService } from '../../../lib/dist/measure/shared/measure-shared.service'

import { AppController } from './app.controller'
import { AppService } from './app.service'

export class AppRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new AppRouter().buildRouter({mergeParams: true})
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: AppController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new AppController(new AppService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/accepted/:countries?', this.getCountryLastAcceptedHandler.bind(this))
            .get('/comments/:countryId', this.getCountryRoundCommentsHandler.bind(this))
            .get('/statusChanges/:countries?', this.getStatusChangesHandler.bind(this))
            .put('/statusChanges/:countryId', this.setStatusChangesHandler.bind(this))
            .get('/:countries?', this.getStatusesHandler.bind(this))
            .post('/:countryId', this.setCountryStatusHandler.bind(this))
            .put('/:countries?', this.setManyCountriesStatusHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryLastAcceptedHandler
     *********************************************************************************************/
    private getCountryLastAcceptedHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getCountryLastAccepted(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countries?.split(','),
            req.query.onlyFullStorage === 'true',
            req.query.onlyFullRound === 'true',
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCountryRoundCommentsHandler
     *********************************************************************************************/
    private getCountryRoundCommentsHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getCountryRoundComments(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countryId,
            Number(req.query.roundSid),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getStatusChangesHandler
     *********************************************************************************************/
    private getStatusChangesHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getStatusChanges(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countries?.split(','),
            MeasureSharedService.getReqArchiveParams(req.query),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getStatusesHandler
     *********************************************************************************************/
    private getStatusesHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getStatuses(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countries?.split(','),
            MeasureSharedService.getReqArchiveParams(req.query),
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method setCountryStatusHandler
     *********************************************************************************************/
    private setCountryStatusHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.setCountryStatus(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countryId,
            req.body
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method setManyCountriesStatusHandler
     *********************************************************************************************/
    private setManyCountriesStatusHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.setManyCountriesStatus(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countries?.split(','),
            req.body
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method setStatusChangesHandler
     *********************************************************************************************/
    private setStatusChangesHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.setStatusChangeDate(
            req.params.appId?.toUpperCase() as EApps,
            req.params.countryId,
            req.body,
        ).then(res.json.bind(res), next)
    }
}
