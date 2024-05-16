import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'

import { IDBIdxCriterion, IDBIndex } from '.'
import { IScore, ISectionQuestion } from '../shared/'
import { FgdDbService } from '../db/db.service'
import { IEmailParams } from './shared-interfaces'

export class ScoresService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndexCriteria
     *********************************************************************************************/
    public async getIndexCriteria(
        indexSid: number
    ): Promise<IDBIdxCriterion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndexCriteria' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndexDescription
     *********************************************************************************************/
    public async getIndexDescription(
        indexSid: number
    ): Promise<IDBIndex[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndexDescription' , options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getPreviousFinalScore
     *********************************************************************************************/
    public async getPreviousFinalScore(
        criterionSid: number, roundSid: number
    ): Promise<IScore[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getPreviousFinalScore' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCriterionQuestions
     *********************************************************************************************/
    public async getCriterionQuestions(
        criterionSid: number
    ): Promise<ISectionQuestion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getCriterionQuestions' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method updateScoreComment
     *********************************************************************************************/
    public async updateScoreComment(
        commentSid: number, comment: string, user: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_comment_sid', type: NUMBER, value: commentSid },
                { name: 'p_comment', type: STRING, value: comment },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.updateScoreComment' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method addScoreComment
     *********************************************************************************************/
    public async addScoreComment(
        entryCriteriaSid: number, comment: string, user: string, organisation: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_criteria_sid', type: NUMBER, value: entryCriteriaSid },
                { name: 'p_comment', type: STRING, value: comment },
                { name: 'p_user', type: STRING, value: user },
                { name: 'p_organisation', type: STRING, value: organisation },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.addScoreComment' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getEmailParams
     *********************************************************************************************/
     public async getEmailParams(
        entryCriteriaSid: number
    ): Promise<IEmailParams[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_criteria_sid', type: NUMBER, value: entryCriteriaSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getEmailParams' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method deleteScoreComment
     *********************************************************************************************/
    public async deleteScoreComment(
        commentSid: number, user: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_comment_sid', type: NUMBER, value: commentSid },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.deleteScoreComment' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method sendEmail
     *********************************************************************************************/
    public async sendEmail(
        indexSid: number, countryId: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_inbound', type: NUMBER, value: 0 },
                { name: 'p_ret', type: NUMBER, value: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.sendMailFGD' , options)
        return dbResult.p_ret
    }

    /**********************************************************************************************
     * @method acceptCriteriaScore
     *********************************************************************************************/
    public async acceptCriteriaScore(
        entryCriteriaSid: number, score: number, user: string, organisation = ''
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_criteria_sid', type: NUMBER, value: entryCriteriaSid },
                { name: 'p_score', type: NUMBER, value: score },
                { name: 'p_user', type: STRING, value: user },
                { name: 'p_organisation', type: STRING, value: organisation },
                { name: 'o_res', type: NUMBER, value: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.acceptCriteriaScore' , options)
        return dbResult.o_res
    }
}
