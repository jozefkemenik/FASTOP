import { IError } from '../../../lib/dist/error.service'

import { IDBIdxCriterion, IIdxCriterion, IIndex } from '.'
import { ISectionQuestion } from '../shared/'
import { ScoresService } from './scores.service'
import { SharedService } from '../shared/shared.service'

export class ScoresController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    private dbCriteria: IDBIdxCriterion[]
    private _criteria: {[indexSid: number]: IIdxCriterion[]} = {}
    private _indexes: {[indexSid: number]: IIndex[]} = {}
    private _criterionQuestions: {[criterionSid: number]: ISectionQuestion[]} = {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private scoresService: ScoresService, private sharedService: SharedService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
    * @method getIndexCalculationStages
     *********************************************************************************************/
    public async getIndexCalculationStages(
        indexSid: number, isMS: boolean
    ) {
        const stage = await this.sharedService.getIndexCalculationStages(indexSid).catch(
            (err: IError) => {
                err.method = 'ScoresController.getIndexCalculationStages'
                throw err
            }
        )
        if (isMS) {
            return stage.filter(elem => elem.MS_SHARED = 1)
        }
        return stage
    }

    /**********************************************************************************************
    * @method getIndexCriteria
     *********************************************************************************************/
    public async getIndexCriteria(
        indexSid: number
    ) {
        if (!this._criteria[indexSid]) {
        this.dbCriteria = await this.scoresService.getIndexCriteria(indexSid).catch(
            (err: IError) => {
                err.method = 'ScoresController.getIndexCriteria'
                throw err
            }
        )
        this._criteria[indexSid] = this.dbCriteria.map(idxCriterion => ({
            CRITERION_SID: idxCriterion.CRITERION_SID,
            CRITERION_ID: idxCriterion.CRITERION_ID,
            SUB_CRITERION_ID: idxCriterion.SUB_CRITERION_ID,
            DESCR: idxCriterion.DESCR,
            HELP_TEXT: idxCriterion.HELP_TEXT,
            SCORES: idxCriterion.SCORES.split(',').map(res => Number(res))
        }))
        }
        return this._criteria[indexSid]
    }

    /**********************************************************************************************
    * @method getIndexDescription
     *********************************************************************************************/
    public async getIndexDescription(
        indexSid: number
    ) {
        if (!this._indexes[indexSid]) {
            this._indexes[indexSid] = await this.scoresService.getIndexDescription(indexSid).catch(
            (err: IError) => {
                err.method = 'ScoresController.getIndexDescription'
                throw err
            }
        )}
        return this._indexes[indexSid]
    }

    /**********************************************************************************************
    * @method getPreviousFinalScore
     *********************************************************************************************/
    public async getPreviousFinalScore(
        criterionSid: number, roundSid: number
    ) {
        return this.scoresService.getPreviousFinalScore(criterionSid, roundSid).catch(
            (err: IError) => {
                err.method = 'ScoresController.getPreviousFinalScore'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method getScoreComments
     *********************************************************************************************/
    public async getScoreComments(
        ruleCriteriaSid: number,
        isMS: number
    ) {
        return this.sharedService.getScoreComments(ruleCriteriaSid, isMS).catch(
            (err: IError) => {
                err.method = 'ScoresController.getScoreComments'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method getCriterionQuestions
     *********************************************************************************************/
    public async getCriterionQuestions(
        criterionSid: number, ruleSid: number, roundSid?: number, applyConditions = true
    ) {
        if (!this._criterionQuestions[criterionSid]) {
            this._criterionQuestions[criterionSid] = await this.scoresService.getCriterionQuestions(criterionSid).catch(
                (err: IError) => {
                    err.method = 'ScoresController.getCriterionQuestions'
                    throw err
                }
            )
        }
        return this.sharedService.addConditions(
            this._criterionQuestions[criterionSid],
            ruleSid,
            roundSid,
            applyConditions,
            -1
        )
    }

    /**********************************************************************************************
    * @method updateScoreComment
     *********************************************************************************************/
    public async updateScoreComment(
        commentSid: number, comment: string, ldap: string
    ) {
        return this.scoresService.updateScoreComment(commentSid, comment, ldap).catch(
            (err: IError) => {
                err.method = 'ScoresController.updateScoreComment'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method addScoreComment
     *********************************************************************************************/
    public async addScoreComment(
        ruleCriteriaSid: number, commentText: string, ldap: string, dep: string, isMS: boolean
    ) {
        if (isMS) {
            const emailParams = await this.scoresService.getEmailParams(ruleCriteriaSid)
            const sendEmail = await this.sharedService.sendEmail(ldap, emailParams[0].INDEX_SID,
                    emailParams[0].CRITERION_SID,  emailParams[0].ENTRY_SID)
            if (sendEmail > 0) {return -1}
        }
        return this.scoresService.addScoreComment(ruleCriteriaSid, commentText, ldap, dep).catch(
            (err: IError) => {
                err.method = 'ScoresController.addScoreComment'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method deleteScoreComment
     *********************************************************************************************/
    public async deleteScoreComment(
        commentSid: number, user: string, isAdmin = true
    ) {
        return this.scoresService.deleteScoreComment(commentSid, isAdmin ? '' : user).catch(
            (err: IError) => {
                err.method = 'ScoresController.deleteScoreComment'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method sendEmail
     *********************************************************************************************/
    public async sendEmail(
        indexSid: number, countryId: string
    ) {
        return this.scoresService.sendEmail(indexSid, countryId).catch(
            (err: IError) => {
                err.method = 'ScoresController.sendEmail'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method acceptCriteriaScore
     *********************************************************************************************/
    public async acceptCriteriaScore(
        ruleCriteriaSid: number, score: number, user: string, department: string
    ) {
        return this.scoresService.acceptCriteriaScore(ruleCriteriaSid, score, user, department).catch(
            (err: IError) => {
                err.method = 'ScoresController.acceptCriteriaScore'
                throw err
            }
        )
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
