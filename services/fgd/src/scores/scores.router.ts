import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist/authzLib.service'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import { ScoresController } from './scores.controller'
import { ScoresService } from './scores.service'
import { SharedService } from './../shared/shared.service'

export class ScoresRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService, dbService: DbService<DbProviderService>): Router {
        return new ScoresRouter(sharedService, dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: ScoresController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService, dbService: DbService<DbProviderService>) {
        super()
        this.controller = new ScoresController(new ScoresService(dbService), sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/stages/:indexSid', this.getIndexCalculationStages.bind(this))
            .get('/:indexSid/criteria', this.getIndexCriteria.bind(this))
            .get('/:indexSid', this.getIndexDescription.bind(this))
            .get('/criteria/:criterionSid/questions', this.getCriterionQuestions.bind(this))
            .get('/final/:criterionSid/:roundSid', this.getPreviousFinalScore.bind(this))
            .get('/comments/:ruleCriteriaSid/:isMS', this.getScoreComments.bind(this))
            .put('/comments/:commentSid', this.updateScoreComment.bind(this))
            .post('/:ruleCriteriaSid/accept', this.acceptCriteriaScore.bind(this))
            .post('/comments/:ruleCriteriaSid', this.addScoreComment.bind(this))
            .post('/email', this.sendEmail.bind(this))
            .delete('/comments/:commentSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.deleteScoreComment.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndexCalculationStages
     *********************************************************************************************/
    private getIndexCalculationStages(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndexCalculationStages(
            Number(req.params.indexSid),
            AuthzLibService.isMS(req))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getIndexCriteria
     *********************************************************************************************/
    private getIndexCriteria(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndexCriteria(
            Number(req.params.indexSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getIndexDescription
     *********************************************************************************************/
    private getIndexDescription(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndexDescription(
            Number(req.params.indexSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getCriterionQuestions
     *********************************************************************************************/
    private getCriterionQuestions(req: Request, res: Response, next: NextFunction) {
        this.controller.getCriterionQuestions(
            Number(req.params.criterionSid),
            Number(req.query.ruleSid),
            Number(req.query.roundSid) || 0)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getPreviousFinalScore
     *********************************************************************************************/
    private getPreviousFinalScore(req: Request, res: Response, next: NextFunction) {
        this.controller.getPreviousFinalScore(
            Number(req.params.criterionSid),
            Number(req.params.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getScoreComments
     *********************************************************************************************/
    private getScoreComments(req: Request, res: Response, next: NextFunction) {
        this.controller.getScoreComments(
            Number(req.params.ruleCriteriaSid),
            Number(req.params.isMS))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method updateScoreComment
     *********************************************************************************************/
    private updateScoreComment(req: Request, res: Response, next: NextFunction) {
        this.controller.updateScoreComment(
            Number(req.params.ruleCriteriaSid),
            req.body.commentText,
            this.getUserId(req),
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method acceptCriteriaScore
     *********************************************************************************************/
    private acceptCriteriaScore(req: Request, res: Response, next: NextFunction) {
        this.controller.acceptCriteriaScore(
            Number(req.params.ruleCriteriaSid),
            Number(req.body.score),
            this.getUserId(req),
            this.getUserUnit(req),
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method addScoreComment
     *********************************************************************************************/
    private addScoreComment(req: Request, res: Response, next: NextFunction) {
        this.controller.addScoreComment(
            Number(req.params.ruleCriteriaSid),
            req.body.commentText,
            this.getUserId(req),
            this.getUserUnit(req),
            AuthzLibService.isMS(req)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method sendEmail
     *********************************************************************************************/
    private sendEmail(req: Request, res: Response, next: NextFunction) {
        this.controller.sendEmail(
            Number(req.body.indexSid),
            req.body.countryId)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method deleteScoreComment
     *********************************************************************************************/
    private deleteScoreComment(req: Request, res: Response, next: NextFunction) {
        this.controller.deleteScoreComment(
            Number(req.params.commentSid),
            this.getUserId(req),
            )
        .then( res.json.bind(res), next )
    }
}
