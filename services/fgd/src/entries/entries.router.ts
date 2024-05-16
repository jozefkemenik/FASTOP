import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import { EntriesController } from './entries.controller'
import { EntriesService } from './entries.service'
import { SharedService } from './../shared/shared.service'

export class EntriesRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService, dbService: DbService<DbProviderService>): Router {
        return new EntriesRouter(sharedService, dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: EntriesController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService, dbService: DbService<DbProviderService>) {
        super()
        this.controller = new EntriesController(new EntriesService(dbService), sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/:entrySid/questions/:questionVersionSid', this.getQuestionValues.bind(this))
            .get('/:ruleSid/attributes/:attrSid/options', this.getAttributeOptions.bind(this))
            .get('/:ruleSid/attributes/:attrSid/addInfo/:periodSid', this.getAttributeAdditionalInfo.bind(this))
            .get('/:ruleSid/assessments/:attrSid/details', this.getAssessmentResponseDetails.bind(this))
            .get('/:ruleSid/attributes/:attrSid/visible', this.isAttributeVisible.bind(this))
            .get('/:ruleSid/attributes/:attrSid/details', this.getAttributeResponseDetails.bind(this))
            .get('/:ruleSid/attributes/:attrSid/responseValues', this.getAttributeResponseValues.bind(this))
            .get('/:entrySid/attributes/:attrSid/lastUpdate', this.getQuestionLastUpdate.bind(this))
            .get('/:ruleSid/assessments/:attrSid', this.getAssessmentValues.bind(this))
            .get('/:ruleSid/compliance', this.getComplianceValue.bind(this))
            .get('/:ruleSid/scores/:criterionSid', this.getRuleScoreDetails.bind(this))
            .get('/:ruleSid/scores', this.getEntryScores.bind(this))
            .get('/responseChoices/:type', this.getResponseChoices.bind(this))
            .get('/targetYears/:year/:appId', this.getTargetYears.bind(this))
            .get('/:entrySid/:attrSid/targetNAYears', this.getTargetNAYears.bind(this))
            .get('/:attrSid/dependentAttrs', this.hasDependentAttributes.bind(this))
            .get('/:ruleSid/ifiName', this.getIfiName.bind(this))
            .get('/types', this.getRuleTypes.bind(this))
            .put('/:ruleSid/attributes/:attrSid/addInfo', this.setAttributeAdditionalInfo.bind(this))
            .put('/:ruleSid/attributes/:attrSid', this.setAttributeValue.bind(this))
            .put('/:ruleSid/attributes/:attrSid/response/:respSid', this.setAttributeResponseValue.bind(this))
            .put('/:ruleSid/assessments/:attrSid', this.setAssessmentValue.bind(this))
            .put('/:ruleSid/compliance/:questionVersionSid', this.setComplianceValue.bind(this))
            .put('/:ruleSid/scores/:indexSid/:criterionSid', this.setRuleCriterionScore.bind(this))
            .put('/:ruleSid/ambitious', this.setAmbitious.bind(this))
            .put('/:entrySid/:questionVersionSid/targetNAYears/:year', this.setEntryTargetNAYear.bind(this))
            .put('/:ruleSid/reform/:questSid/:roundSid', this.duplicateEntry.bind(this))
            .put('/:ruleSid/abolish/:questionnaireSid', this.abolishRule.bind(this))
            .post('/:ruleSid/scores/:criterionSid', this.addRuleCriteriaIteration.bind(this))
            .post('/createRule', this.createRule.bind(this))
            .post('/createIfi', this.createIfi.bind(this))
            .post('/createMtbf', this.createMtbf.bind(this))
            .post('/creategbd', this.createGbd.bind(this))
            .post('/:entrySid/export', this.getEntryExport.bind(this))
            .delete('/:ruleSid/attributes/:attrSid/value/:respSid', this.deleteAttributeValue.bind(this))
            .delete('/:ruleSid/assessments/:attrSid/value/:respSid', this.deleteAssessmentValue.bind(this))
            .delete('/clear/:ruleSid/assessments/:attrSid/', this.clearAssessmentValue.bind(this))
            .delete('/:entrySid/:questionVersionSid/targetNAYears/:year', this.deleteEntryTargetNAYear.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getQuestionLastUpdate
     *********************************************************************************************/
    private getQuestionLastUpdate(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionLastUpdate(
            Number(req.params.entrySid),
            Number(req.params.attrSid)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getQuestionValues
     *********************************************************************************************/
    private getQuestionValues(req: Request, res: Response, next: NextFunction) {
        this.controller.getQuestionValues(
            Number(req.params.entrySid),
            Number(req.params.questionVersionSid),
            Boolean(req.query.format)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getTargetYears
     *********************************************************************************************/
    private getTargetYears(req: Request, res: Response, next: NextFunction) {
        this.controller.getTargetYears(
            Number(req.params.year),
            req.params.appId)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getAttributeOptions
     *********************************************************************************************/
    private getAttributeOptions(req: Request, res: Response, next: NextFunction) {
        this.controller.getAttributeOptions(
            Number(req.params.ruleSid),
            Number(req.params.attrSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getResponseChoices
     *********************************************************************************************/
    private getResponseChoices(req: Request, res: Response, next: NextFunction) {
        this.controller.getResponseChoices(
            req.params.type === 'grouped' ? true : false)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getAttributeResponseDetails
     *********************************************************************************************/
    private getAttributeResponseDetails(req: Request, res: Response, next: NextFunction) {
        this.controller.getAttributeResponseDetails(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            'Details')
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getAttributeResponseValues
     *********************************************************************************************/
    private getAttributeResponseValues(req: Request, res: Response, next: NextFunction) {
        this.controller.getAttributeResponseDetails(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            'Values')
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getAttributeAdditionalInfo
     *********************************************************************************************/
    private getAttributeAdditionalInfo(req: Request, res: Response, next: NextFunction) {
        this.controller.getAttributeAdditionalInfo(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            Number(req.params.periodSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getAssessmentValues
     *********************************************************************************************/
    private getAssessmentValues(req: Request, res: Response, next: NextFunction) {
        this.controller.getAssessmentValues(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            Number(req.query.periodSid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getAssessmentResponseDetails
     *********************************************************************************************/
    private getAssessmentResponseDetails(req: Request, res: Response, next: NextFunction) {
        this.controller.getAssessmentResponseDetails(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            Number(req.query.periodSid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getComplianceValue
     *********************************************************************************************/
    private getComplianceValue(req: Request, res: Response, next: NextFunction) {
        this.controller.getComplianceValue(
            Number(req.params.ruleSid),
            Number(req.query.roundSid),
            Number(req.query.periodSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getRuleScoreDetails
     *********************************************************************************************/
    private getRuleScoreDetails(req: Request, res: Response, next: NextFunction) {
        this.controller.getRuleScoreDetails(
                Number(req.params.ruleSid),
                Number(req.query.roundSid),
                Number(req.params.criterionSid),
                Number(req.query.versionSid),
                AuthzLibService.isMS(req),
            ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getEntryScores
     *********************************************************************************************/
    private getEntryScores(req: Request, res: Response, next: NextFunction) {
        this.controller.getEntryScores(
                Number(req.params.ruleSid),
                Number(req.query.indexSid),
                Number(req.query.roundSid),
                Number(req.query.versionSid),
                Number(req.query.criterionSid),
                AuthzLibService.isMS(req),
            ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getTargetNAYears
     *********************************************************************************************/
    private getTargetNAYears(req: Request, res: Response, next: NextFunction) {
        this.controller.getTargetNAYears(
            Number(req.params.entrySid),
            Number(req.params.attrSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getEntryExport
     *********************************************************************************************/
     private getEntryExport(req: Request, res: Response, next: NextFunction) {
        this.controller.getEntryExport(
            Number(req.params.entrySid),
            Number(req.query.roundSid),
            Number(req.query.year),
            req.query.country as string,
            Number(req.query.questSid),
            req.body.warning,
            res)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method isAttributeVisible
     *********************************************************************************************/
    private isAttributeVisible(req: Request, res: Response, next: NextFunction) {
        this.controller.isAttributeVisible(
            Number(req.params.attrSid),
            Number(req.params.ruleSid),
            Number(req.query.roundSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method hasDependentAttributes
     *********************************************************************************************/
    private hasDependentAttributes(req: Request, res: Response, next: NextFunction) {
        this.controller.hasDependentAttributes(
            Number(req.params.attrSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getIfiName
     *********************************************************************************************/
    private getIfiName(req: Request, res: Response, next: NextFunction) {
        this.controller.getIfiName(
            Number(req.params.ruleSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method getRuleTypes
     *********************************************************************************************/
    private getRuleTypes(req: Request, res: Response, next: NextFunction) {
        this.controller.getRuleTypes()
        .then( res.json.bind(res), next )
    }

    //////////////////////////////////// SETTERS //////////////////////////////////////////////////

    /**********************************************************************************************
     * @method setAttributeValue
     *********************************************************************************************/
    private setAttributeValue(req: Request, res: Response, next: NextFunction) {
        this.controller.setAttributeValue(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            req.body.value ? req.body.value : '',
            req.body.details)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setAttributeResponseValue
     *********************************************************************************************/
    private setAttributeResponseValue(req: Request, res: Response, next: NextFunction) {
        this.controller.setAttributeResponseValue(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            Number(req.params.respSid),
            Number(req.body.value) ? Number(req.body.value) : null)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setAttributeAdditionalInfo
     *********************************************************************************************/
    private setAttributeAdditionalInfo(req: Request, res: Response, next: NextFunction) {
        this.controller.setAttributeAdditionalInfo(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            req.body.info,
            Number(req.body.periodSid))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setAssessmentValue
     *********************************************************************************************/
    private setAssessmentValue(req: Request, res: Response, next: NextFunction) {
        this.controller.setAssessmentValue(
            Number(req.params.ruleSid),
            Number(req.body.roundSid),
            Number(req.body.periodSid),
            Number(req.params.attrSid),
            req.body.value ? req.body.value : '',
            req.body.details)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setComplianceValue
     *********************************************************************************************/
    private setComplianceValue(req: Request, res: Response, next: NextFunction) {
        this.controller.setComplianceValue(
            Number(req.params.ruleSid),
            Number(req.params.questionVersionSid),
            Number(req.body.periodSid),
            Number(req.body.value))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setRuleCriterionScore
     *********************************************************************************************/
    private setRuleCriterionScore(req: Request, res: Response, next: NextFunction) {
        this.controller.setRuleCriterionScore(
            Number(req.params.ruleSid),
            Number(req.params.indexSid),
            Number(req.body.roundSid),
            Number(req.params.criterionSid),
            Number(req.body.versionSid),
            Number(req.body.score),
            this.getUserId(req),
            this.getUserUnit(req),
            AuthzLibService.isMS(req)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setAmbitious
     *********************************************************************************************/
    private setAmbitious(req: Request, res: Response, next: NextFunction) {
        this.controller.setAmbitious(
            Number(req.params.ruleSid),
            Boolean(req.body.ambitious))
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method setEntryTargetNAYear
     *********************************************************************************************/
    private setEntryTargetNAYear(req: Request, res: Response, next: NextFunction) {
        this.controller.setEntryTargetNAYear(
            Number(req.params.entrySid),
            Number(req.params.questionVersionSid),
            Number(req.params.year),
            req.body.na)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method duplicateEntry
     *********************************************************************************************/
    private duplicateEntry(req: Request, res: Response, next: NextFunction) {
        this.controller.duplicateEntry(
            Number(req.params.ruleSid),
            req.body.reasonReform,
            req.body.strDateReform,
            req.body.strDateForceReform,
            this.getUserId(req),
            Number(req.params.roundSid)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method abolishRule
     *********************************************************************************************/
    private abolishRule(req: Request, res: Response, next: NextFunction) {
        this.controller.abolishRule(
            Number(req.params.questionnaireSid),
            Number(req.params.ruleSid),
            req.body.reason,
            req.body.strDate)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method addRuleCriteriaIteration
     *********************************************************************************************/
    private addRuleCriteriaIteration(req: Request, res: Response, next: NextFunction) {
        this.controller.addRuleCriteriaIteration(
            Number(req.params.ruleSid),
            Number(req.body.roundSid),
            Number(req.params.criterionSid),
            Number(req.body.versionSid),
            Number(req.body.score),
            this.getUserId(req),
            this.getUserUnit(req),
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method createRule
     *********************************************************************************************/
    private createRule(req: Request, res: Response, next: NextFunction) {
        this.controller.createRule(
            req.body.country,
            Number(req.body.ruleType),
            req.body.strDateAdopt,
            req.body.strDateImpl,
            req.body.ruleDescription,
            this.getUserId(req),
            Number(req.body.roundSid)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method createIfi
     *********************************************************************************************/
    private createIfi(req: Request, res: Response, next: NextFunction) {
        this.controller.createIfi(
            req.body.country,
            req.body.strDateEstab,
            req.body.nameEng,
            this.getUserId(req),
            Number(req.body.roundSid)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method createMtbf
     *********************************************************************************************/
    private createMtbf(req: Request, res: Response, next: NextFunction) {
        this.controller.createMtbf(
            req.body.country,
            req.body.strDateEstab,
            req.body.strImplemDate,
            req.body.descr,
            this.getUserId(req),
            Number(req.body.roundSid)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method createGbd
     *********************************************************************************************/
    private createGbd(req: Request, res: Response, next: NextFunction) {
        this.controller.createGbd(
            req.body.country,
            req.body.strDateEstab,
            req.body.nameEng,
            this.getUserId(req),
            Number(req.body.roundSid)
        ).then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method deleteAttributeValue
     *********************************************************************************************/
    private deleteAttributeValue(req: Request, res: Response, next: NextFunction) {
        this.controller.deleteAttributeValue(
            Number(req.params.ruleSid),
            Number(req.params.attrSid),
            req.params.respSid)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method deleteAssessmentValue
     *********************************************************************************************/
    private deleteAssessmentValue(req: Request, res: Response, next: NextFunction) {
        this.controller.deleteAssessmentValue(
            Number(req.params.ruleSid),
            Number(req.query.roundSid),
            Number(req.query.periodSid),
            Number(req.params.attrSid),
            req.params.respSid)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method clearAssessmentValue
     *********************************************************************************************/
    private clearAssessmentValue(req: Request, res: Response, next: NextFunction) {
        this.controller.clearAssessmentValue(
            Number(req.params.ruleSid),
            Number(req.query.roundSid),
            Number(req.query.periodSid),
            Number(req.params.attrSid),)
        .then( res.json.bind(res), next )
    }

    /**********************************************************************************************
     * @method deleteEntryTargetNAYear
     *********************************************************************************************/
    private deleteEntryTargetNAYear(req: Request, res: Response, next: NextFunction) {
        this.controller.deleteEntryTargetNAYear(
            Number(req.params.entrySid),
            Number(req.params.questionVersionSid),
            Number(req.params.year))
        .then( res.json.bind(res), next )
    }
}
