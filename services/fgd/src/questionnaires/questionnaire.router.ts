import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import { QuestionnaireController } from './questionnaire.controller'
import { QuestionnaireService } from './questionnaire.service'
import { SharedService } from './../shared/shared.service'

export class QuestionnaireRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        sharedService: SharedService,
        appId: EApps,
        dbService: DbService<DbProviderService>
        ): Router {
        return new QuestionnaireRouter(sharedService, appId, dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: QuestionnaireController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService, appId: EApps, dbService: DbService<DbProviderService>) {
        super(appId)
        this.controller = new QuestionnaireController(new QuestionnaireService(dbService), sharedService, appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/', this.getQuestionnaires.bind(this))
            .get('/entries/:entrySid', this.getEntry.bind(this))
            .get('/:questionnaireSid/:countryId/entries',
                this.checkCountryAuthorisation(), this.getQuestionnaireEntries.bind(this))
            .get('/:questionnaireSid/:countryId/submit', this.getQuestionnaireSubmissionDate.bind(this))
            .get('/:qstnnrVersionSid/sections', this.getQuestionnaireSections.bind(this))
            .get('/:questionnaireSid/years', this.getQuestionnaireYears.bind(this))
            .get('/:questionnaireSid/indexes', this.getQuestionnaireIndexes.bind(this))
            .get('/:qstnnrVersionSid/attributes/:option', this.getHeaderAttributes.bind(this))
            .get('/:qstnnrVersionSid/elements', this.getQuestionnaireElementsHandler.bind(this))
            .get('/:questionnaireSid/customHeaders/:page', this.getCustomHeaderAttributes.bind(this))
            .get('/:messageId', this.getDialogMessage.bind(this))
            .get('/:questionnaireSid/:countryId/qversion', this.getQstnnrVersion.bind(this))
            .post('/:questionnaireSid/:year/entries/:ruleSid/complete', this.completeQuestionnaireRule.bind(this))
            .post('/:questionnaireSid/entries/:ruleSid/nochange', this.noChangeRule.bind(this))
            .post('/:questionnaireSid/entries/:entrySid/reopen',
                AuthzLibService.checkAuthorisation('ADMIN'), this.reopenEntry.bind(this))
            .post('/:questionnaireSid/:countryId/submit', this.submitQuestionnaire.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getQuestionnaires
     *********************************************************************************************/
    private getQuestionnaires(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaires()
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQstnnrVersion
     *********************************************************************************************/
    private getQstnnrVersion(req: Request, res: Response, next: NextFunction) {
        this.controller.getQstnnrVersion(
            Number(req.params.questionnaireSid),
            req.params.countryId
        )
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getEntry
     *********************************************************************************************/
    private getEntry(req: Request, res: Response, next: NextFunction) {
        this.controller.getEntry(
            Number(req.params.entrySid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionnaireEntries
     *********************************************************************************************/
    private getQuestionnaireEntries(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaireEntries(
            Number(req.params.questionnaireSid),
            req.params.countryId,
            Number(req.query.roundSid),
            AuthzLibService.getUserCountries(req))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionnaireSubmissionDate
     *********************************************************************************************/
    private getQuestionnaireSubmissionDate(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaireSubmissionDate(
            Number(req.params.questionnaireSid),
            req.params.countryId,
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionnaireSections
     *********************************************************************************************/
    private getQuestionnaireSections(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaireSections(
            Number(req.params.qstnnrVersionSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionnaireYears
     *********************************************************************************************/
    private getQuestionnaireYears(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaireYears(
            Number(req.params.questionnaireSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionnaireIndexes
     *********************************************************************************************/
    private getQuestionnaireIndexes(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaireIndexes(
            Number(req.params.questionnaireSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getHeaderAttributes
     *********************************************************************************************/
    private getHeaderAttributes(req: Request, res: Response, next: NextFunction) {
        this.controller.getHeaderAttributes(
            Number(req.params.qstnnrVersionSid),
            req.params.option)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getCustomHeaderAttributes
     *********************************************************************************************/
    private getCustomHeaderAttributes(req: Request, res: Response, next: NextFunction) {
        this.controller.getCustomHeaderAttributes(
            Number(req.params.questionnaireSid),
            req.params.page)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionnaireElementsHandler
     *********************************************************************************************/
    private getQuestionnaireElementsHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionnaireElements(Number(req.params.qstnnrVersionSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getDialogMessage
     *********************************************************************************************/
    private getDialogMessage(req: Request, res: Response, next: NextFunction) {
        this.controller.getDialogMessage(req.params.messageId)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method completeQuestionnaireRule
     *********************************************************************************************/
    private completeQuestionnaireRule(req: Request, res: Response, next: NextFunction) {
        this.controller.completeQuestionnaireRule(
            Number(req.params.questionnaireSid),
            Number(req.params.year),
            Number(req.params.ruleSid),
            Number(req.body.roundSid),
            Number(req.body.editStepSid),
            this.getUserId(req)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method noChangeRule
     *********************************************************************************************/
    private noChangeRule(req: Request, res: Response, next: NextFunction) {
        this.controller.noChangeRule(
            Number(req.params.questionnaireSid),
            Number(req.params.ruleSid),
            Number(req.body.roundSid),
            this.getUserId(req),
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method reopenEntry
     *********************************************************************************************/
    private reopenEntry(req: Request, res: Response, next: NextFunction) {
        this.controller.reopenEntry(
            Number(req.params.questionnaireSid),
            Number(req.params.entrySid),
            Number(req.body.roundSid),
            Number(req.body.editStepSid),
            this.getUserId(req),
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method submitQuestionnaire
     *********************************************************************************************/
    private submitQuestionnaire(req: Request, res: Response, next: NextFunction) {
        this.controller.submitQuestionnaire(
            Number(req.params.questionnaireSid),
            req.params.countryId,
            Number(req.body.roundSid),
            this.getUserId(req),
            this.getUserUnit(req),
            AuthzLibService.isMS(req),
            req.body.rules
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method checkCountryAuthorisation
     *********************************************************************************************/
    private checkCountryAuthorisation() {
        return (req: Request, res: Response, next: NextFunction): void => {
            if (this.appId === EApps.IFI) {
                next()
            } else {
                AuthzLibService.checkCountryAuthorisation()(req, res, next)
            }
        }
    }
}
