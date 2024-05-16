import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'

import { ICustomHeaderAttr, IDBQuestionnaireElement, IQuestionnaireElement, ISubmit } from '.'
import { FgdDbService } from '../db/db.service'
import { IEntry } from '../shared'

export class QuestionnaireService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _questionnaireElements: Record<number, IQuestionnaireElement[]> = {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getQuestionnaireElements
     *********************************************************************************************/
    public async getQuestionnaireElements(qstnnrVersionSid: number, roundYear: number): Promise<IDBQuestionnaireElement[]> {
            const options: ISPOptions = {
                params: [
                    { name: 'p_qst_version_sid', type: NUMBER, value: qstnnrVersionSid },
                    { name: 'p_round_year', type: NUMBER, value: roundYear },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await this.execSP(`cfg_questionnaire.getQuestionnaireElements`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionnaireSubmissionDate
     *********************************************************************************************/
    public async getQuestionnaireSubmissionDate(
        questionnaireSid: number, countryId: string, roundSid: number
    ): Promise<ISubmit> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_sid', type: NUMBER, value: questionnaireSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getSubmissionDate' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionnaireEntries
     *********************************************************************************************/
    public async getQuestionnaireEntries(
        questionnaireSid: number, countryId: string, roundSid: number
    ): Promise<IEntry[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_sid', type: NUMBER, value: questionnaireSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await
            this.execSP(`cfg_questionnaire.getQuestionnaireEntries`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionnaireYears
     *********************************************************************************************/
    public async getQuestionnaireYears(
        questionnaireSid: number
    ): Promise<number[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_sid', type: NUMBER, value: questionnaireSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestionnaireYears' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCustomHeaderAttributes
     *********************************************************************************************/
    public async getCustomHeaderAttributes(
        qstnnrVersionSid: number, page: string
    ): Promise<ICustomHeaderAttr[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_qstnnr_version_sid', type: NUMBER, value: qstnnrVersionSid },
                { name: 'p_page', type: STRING, value: page },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQstCustomHeaders' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method setEntryEditStep
     *********************************************************************************************/
    public async setEntryEditStep(
        entrySid: number, stepId: string, login: string, appId: string, roundSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_edit_step_id', type: STRING, value: stepId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_last_login', type: STRING, value: login },
                { name: 'p_err', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.setEntryEditStep', options)
        return dbResult.p_err
    }

    /**********************************************************************************************
     * @method abortReform
     *********************************************************************************************/
    public async abortReform(
        questionnaireId: string, entrySid: number, login: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_last_login', type: STRING, value: login },
                { name: 'p_qst_id', type: STRING, value: questionnaireId },
                { name: 'p_err', type: NUMBER, dir: BIND_OUT },
                { name: 'p_mess', type: STRING, dir: BIND_OUT },
            ],
        }
        const SP = 'cfg_questionnaire.abortReform'
        const dbResult = await this.execSP(SP, options)
        return dbResult.p_err
    }

    /**********************************************************************************************
     * @method unsubmitQuestionnaire
     *********************************************************************************************/
    public async unsubmitQuestionnaire(
        questionnaireSid: number, countryId: string, roundSid: number, login: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_sid', type: NUMBER, value: questionnaireSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_user', type: STRING, value: login },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const SP = 'cfg_questionnaire.unsubmit'
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method submitQuestionnaire
     *********************************************************************************************/
    public async submitQuestionnaire(
        questionnaireSid: number, countryId: string, roundSid: number, login: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_sid', type: NUMBER, value: questionnaireSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_user', type: STRING, value: login },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'o_mess', type: STRING, dir: BIND_OUT },
            ],
        }
        const SP = 'cfg_questionnaire.submitLocked'
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
