import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { BcsController } from './bcs.controller'
import { EApps } from 'config'


export class BcsRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new BcsRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: BcsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new BcsController()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/series/observationsArray', this.getSeriesObservationsHandler)
            .get('/surveys', this.getSurveysHandler)
            .get('/countries', this.getCountriesHandler)
            .get('/sectors', this.getSectorsHandler)
            .get('/questions', this.getQuestionsHandler)
            .get('/answers', this.getAnswersHandler)
            .get('/seasonalAdjs', this.getSeasonalAdjsHandler)
            .get('/observationsRange', this.getObservationsRangeHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSeriesObservationsHandler
     *********************************************************************************************/
    private getSeriesObservationsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getObservations(req.url, req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSurveysHandler
     *********************************************************************************************/
    private getSurveysHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSurveys().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSectorsHandler
     *********************************************************************************************/
    private getSectorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSectors().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getQuestionsHandler
     *********************************************************************************************/
    private getQuestionsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getQuestions().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAnswersHandler
     *********************************************************************************************/
    private getAnswersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAnswers().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeasonalAdjsHandler
     *********************************************************************************************/
    private getSeasonalAdjsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeasonalAdjs().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getObservationsRangeHandler
     *********************************************************************************************/
    private getObservationsRangeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getObservationsRange().then(res.json.bind(res), next)
}
