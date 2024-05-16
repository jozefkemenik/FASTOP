import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { RoundController } from './round.controller'
import { RoundService } from './round.service'


export class RoundRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new RoundRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: RoundController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new RoundController(new RoundService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/next',
                 AuthzLibService.checkAuthorisation('ADMIN'),
                 this.getNextRoundInfoHandler)
            .get('/list',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getRoundsHandler)
            .get('/next/:year/:periodSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.checkNewRoundHandler)
            .post('/next/:year/:periodSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.createNewRoundHandler)
            .post('/custom/:year/:periodSid/:version',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.createCustomRoundHandler)
            .get('/activate/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.checkRoundActivationHandler)
            .put('/activate',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.activateRoundHandler)
            .get('/periods',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getPeriodsHandler)
            .get('/version/:year/:periodSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getLatestVersionHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNextRoundInfoHandler
     *********************************************************************************************/
    private getNextRoundInfoHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getNextRoundInfo().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getRoundsHandler
     *********************************************************************************************/
    private getRoundsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRounds().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method checkNewRoundHandler
     *********************************************************************************************/
    private checkNewRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.checkNewRound(
            Number(req.params.year),
            Number(req.params.periodSid)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method createNewRoundHandler
     *********************************************************************************************/
    private createNewRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.createNewRound(
            Number(req.params.year),
            Number(req.params.periodSid),
            req.body.roundTitle
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method createCustomRoundHandler
     *********************************************************************************************/
    private createCustomRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.createCustomRound(
            Number(req.params.year),
            Number(req.params.periodSid),
            Number(req.params.version),
            req.body.roundTitle
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method checkRoundActivationHandler
     *********************************************************************************************/
    private checkRoundActivationHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.checkRoundActivation(
            Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method activateRoundHandler
     *********************************************************************************************/
    private activateRoundHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.activateRound(req.body.roundSid, req.get('authLogin')).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getPeriodsHandler
     *********************************************************************************************/
    private getPeriodsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getPeriods().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLatestVersionHandler
     *********************************************************************************************/
    private getLatestVersionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getLatestRoundVersion(
            Number(req.params.year),
            Number(req.params.periodSid),
        ).then(res.json.bind(res), next)
}
