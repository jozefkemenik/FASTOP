import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import {
    IChoiceScore,
    IComment, ICoverage, IDBComplianceOption, IDBComplianceValue,
    IDBCondAttrLvl, IDBConditionalQuestion, IDBCriteriaConditions, IDBCriteriaScoreTypes, IDBDisagreedCriterion,
    IDBHeaderAttribute, IDBIndexCalcStage, IDBIndiceAddAttribute, IDBQQuestion, IDBQuestion,
    IDBQuestionTypeAccessor, IDBResponseChoice, IDBSectionHdrAttr,
    IDBSectionQuestion, IDBSectionSubsection, IEditStep, IEntry,
    IIndicesData,
    ILatestScore, IResponseDetail, ISection, ITargetEntryConfig
} from '.'
import { IIndiceCfg } from '../indices'


export class SharedDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public constructor(private dbService: DbService<DbProviderService>) {
    }

    //////////////////////////////// GETTERS //////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getQstnnrVersion
     *********************************************************************************************/
    public async getQstnnrVersion(
        questionnaireSid: number, countryId: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_sid', type: NUMBER, value: questionnaireSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'l_ret', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP(`cfg_questionnaire.getQstnnrVersion`, options)
        return dbResult.l_ret
    }

    /**********************************************************************************************
     * @method getCountryIFI
     *********************************************************************************************/
    public async getCountryIFI(
        countryId: string,
        monitoring: number
    ): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_monitoring', type: NUMBER, value: monitoring },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true,
        }
        const dbResult = await this.execSP('cfg_questionnaire.getCountryIFI', options)
        return dbResult.o_cur.length ? dbResult.o_cur[0][0] : ''
    }

    /**********************************************************************************************
     * @method getAttributeValues
     *********************************************************************************************/
    public async getAttributeValues(
        entrySid: number, attrSid: number, accessor: string, formatResponse: boolean, roundYear?: number
    ): Promise<Array<number | string>> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: attrSid },
                { name: 'p_format_response', type: NUMBER, value: formatResponse ? 1 : 0 },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP(`cfg_accessors.get${accessor}` , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionLastUpdate
     *********************************************************************************************/
    public async getQuestionLastUpdate(
        entrySid: number, questionVersionSid: number
    ): Promise<Array<number | string>> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP(`cfg_accessors.getQuestionLastUpdate` , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getAttributeOptions
     *********************************************************************************************/
    public async getAttributeOptions(
        entrySid: number, attrOptions: string
    ): Promise<Array<number | string>> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP(`cfg_accessors.get${attrOptions}`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getEntry
     *********************************************************************************************/
    public async getEntry(
        entrySid: number, roundSid: number
    ): Promise<IEntry> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await
            this.execSP(`cfg_questionnaire.getEntry`, options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getQuestions
     *********************************************************************************************/
    public async getQuestions(): Promise<IDBQuestion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestions' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getAssessmentValues
     *********************************************************************************************/
    public async getAssessmentValues(
        entrySid: number, questionVersionSid: number, periodSid: number, roundSid: number, accessor: string
    ): Promise<Array<number | string>> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP(`cfg_accessors.get${accessor}`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getAttributeAdditionalInfo
     *********************************************************************************************/
    public async getAttributeAdditionalInfo(
        entrySid: number, questionVersionSid: number, periodSid?: number
    ): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid ? periodSid : 0 },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true,
        }
        const dbResult = await this.execSP('cfg_accessors.getEntryQuestionAdditionalInfo', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getConditionalQuestions
     *********************************************************************************************/
    public async getConditionalQuestions(): Promise<IDBConditionalQuestion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getConditionalQuestions' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCondQuestionsByLvl
     *********************************************************************************************/
    public async getCondQuestionsByLvl(
        questionVersionSid: number
    ): Promise<IDBCondAttrLvl[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getCondQuestionsByLvl' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionTypeAccessors
     *********************************************************************************************/
    public async getQuestionTypeAccessors(): Promise<IDBQuestionTypeAccessor[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestionTypeAccessors' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getEditSteps
     *********************************************************************************************/
    public async getEditSteps(): Promise<IEditStep[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getEditSteps', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionnaireSections
     *********************************************************************************************/
    public async getQuestionnaireSections(
        qstnnrVersionSid: number
    ): Promise<ISection[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_version_sid', type: NUMBER, value: qstnnrVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestionnaireSections' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionPe
     *********************************************************************************************/
    /*
     public async getQuestionnaireQuestions(
        qstnnrVersionSid: number
    ): Promise<IQuestionnaireQuestions[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_version_sid', type: NUMBER, value: qstnnrVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestionnaireQuestions' , options)
        return dbResult.o_cur
    }
    */

    /**********************************************************************************************
     * @method getSectionSubsections
     *********************************************************************************************/
    public async getSectionSubsections(
        qstnnrSectionSid: number, roundYear: number
    ): Promise<IDBSectionSubsection[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_qstnnr_section_sid', type: NUMBER, value: qstnnrSectionSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getSectionSubsections' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getSectionQuestions
     *********************************************************************************************/
    public async getSectionQuestions(
        qstnnrSectionSid: number
    ): Promise<IDBSectionQuestion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_section_version_sid', type: NUMBER, value: qstnnrSectionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getSectionQuestions' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getAttributeResponseDetails
     *********************************************************************************************/
    public async getAttributeResponseDetails(
        entrySid: number, questionVersionSid: number, attrOptions: string, periodSid = 0
    ): Promise<IResponseDetail[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getEntryResponse'
        .concat('', attrOptions), options)
        dbResult.o_cur.forEach(o => o.NUMERIC_VALUE = o.NUMERIC_VALUE ?
                Number(o.NUMERIC_VALUE.toFixed(2)) : 0)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getScoreComments
     *********************************************************************************************/
    public async getScoreComments(
        entryCriteriaSid: number,
        isMS: number
    ): Promise<IComment[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_criteria_sid', type: NUMBER, value: entryCriteriaSid },
                { name: 'p_is_ms', type: NUMBER, value: isMS},
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getScoreComments' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTargetEntryConfig
     *********************************************************************************************/
    public async getTargetEntryConfig(
        appId: string
    ): Promise<ITargetEntryConfig[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getTargetEntryConfig', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTargetNAYears
     *********************************************************************************************/
    public async getTargetNAYears(
        entrySid: number,
        questionVersionSid: number
    ): Promise<number[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true,
        }
        const dbResult = await this.execSP('cfg_accessors.getEntryTargetNAYears', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndexCalculationStages
     *********************************************************************************************/
     public async getIndexCalculationStages(
        indexSid: number
    ): Promise<IDBIndexCalcStage[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndexCalculationStages' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getResponseChoices
     *********************************************************************************************/
    public async getResponseChoices(): Promise<IDBResponseChoice[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getResponseChoices', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getDependentAttributes
     *********************************************************************************************/
    public async getDependentAttributes(
        questionVersionSid: number
    ): Promise<number[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP('cfg_questionnaire.getDependentQuestions', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getSectionHdrAttributes
     *********************************************************************************************/
    public async getSectionHdrAttributes(
        qstnnrVersionSid: number, sectionVersionSid: number
    ): Promise<IDBSectionHdrAttr[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_qstnnr_version_sid', type: NUMBER, value: qstnnrVersionSid },
                { name: 'p_section_version_sid', type: NUMBER, value: sectionVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getSectionHdrAttributes' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getHeaderAttributes
     *********************************************************************************************/
    public async getHeaderAttributes(
        qstnnrVersionSid: number, flag: string
    ): Promise<IDBHeaderAttribute[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_qstnnr_version_sid', type: NUMBER, value: qstnnrVersionSid },
                { name: 'p_flag', type: STRING, value: flag },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getHeaderAttributes' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getDisagreedCriteria
     *********************************************************************************************/
    public async getDisagreedCriteria(
        entrySid: number, roundSid: number, versionSid: number, indexSid: number, countryId: string
    ): Promise<IDBDisagreedCriterion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_version_sid', type: NUMBER, value: versionSid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getDisagreedCriteria' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestion
     *********************************************************************************************/
    public async getQuestion(
        attrSid: number, condSid: number, roundYear: number
    ): Promise<IDBQQuestion[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_attr_sid', type: NUMBER, value: attrSid },
                { name: 'p_cond_sid', type: NUMBER, value: condSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestion' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getComplianceOptions
     *********************************************************************************************/
    public async getComplianceOptions(
        entrySid: number, periodSid: number
    ): Promise<IDBComplianceOption[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getComplianceOptions' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getComplianceValue
     *********************************************************************************************/
    public async getComplianceValue(
        entrySid: number, roundSid: number, periodSid: number
    ): Promise<IDBComplianceValue> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getEntryComplianceValue' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndexCriteriaScoreTypes
     *********************************************************************************************/
     public async getIndexCriteriaScoreTypes(
        indexSid: number
    ): Promise<IDBCriteriaScoreTypes[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndexCriteriaScoreTypes' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCriteriaConditions
     *********************************************************************************************/
     public async getCriteriaConditions(
        criterionSid: number
    ): Promise<IDBCriteriaConditions[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getCriteriaConditions' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getChoiceLov
     *********************************************************************************************/
     public async getChoiceLov(
        choiceScoreSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_choice_score_sid', type: NUMBER, value: choiceScoreSid },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getChoiceLov' , options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getCriteriaChoices
     *********************************************************************************************/
     public async getCriteriaChoices(
        criterionSid: number, entrySid: number
    ): Promise<IChoiceScore[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getCriteriaChoices' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionPeriod
     *********************************************************************************************/
     public async getQuestionPeriod(
        questionVersionSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getQuestionPeriod' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method checkChoiceCondition
     *********************************************************************************************/
     public async checkChoiceCondition(
        entrySid: number,
        questionVersionSid: number,
        customCondition: string,
        roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_custom_condition', type: STRING, value: customCondition },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_scores.checkChoiceCondition' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method checkFulfillChoice
     *********************************************************************************************/
    public async checkFulfillChoice(
        entrySid: number,
        choiceScoreSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_choice_score_sid', type: NUMBER, value: choiceScoreSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_scores.checkFulfillChoice' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getDialogMessage
     *********************************************************************************************/
    public async getDialogMessage(
        messageId: string
    ): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'pi_message_id', type: STRING, value: messageId },
                { name: 'l_out', type: STRING, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_questionnaire.getDialogMessage' , options)
        return dbResult.l_out
    }

    /**********************************************************************************************
     * @method getAssessmentResponseDetails
     *********************************************************************************************/
     public async getAssessmentResponseDetails(
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        entrySid: number, questionVersionSid: number, periodSid: number, roundSid: number
    ): Promise<IResponseDetail[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getEntryResponseDetails',
        options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method checkIndiceCreation
     *********************************************************************************************/
     public async checkIndiceCreation(
        indexSid: number, roundSid: number, roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.checkIndiceCreation',
        options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getIndicesCfg
     *********************************************************************************************/
     public async getIndicesCfg(indexSid: number): Promise<IIndiceCfg[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndicesCfg',
        options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getLatestScores
     *********************************************************************************************/
     public async getLatestScores(entrySid: number, indexSid: number, roundSid: number): Promise<ILatestScore[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getLatestScores',
        options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method isInForce
     *********************************************************************************************/
     public async isInForce(entrySid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.isInForce', options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getCoverages
     *********************************************************************************************/
     public async getCoverages(entrySid: number): Promise<ICoverage[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getCoverages', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getEntryRanking
     *********************************************************************************************/
     public async getEntryRanking(
        entrySid: number,
        sectorId: string,
        roundSid: number,
        roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_sector_id', type: STRING, value: sectorId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getEntryRanking', options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getComplianceBonus
     *********************************************************************************************/
     public async getComplianceBonus(
        countryId: string,
        roundSid: number,
        startYear: number,
        vector: string,
        year: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_start_year', type: NUMBER, value: startYear },
                { name: 'p_vector', type: STRING, value: vector },
                { name: 'p_year', type: NUMBER, value: year },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getComplianceBonus', options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getComplianceScoring
     *********************************************************************************************/
     public async getComplianceScoring(entrySid: number, roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getComplianceScoring', options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getIndiceValue
     *********************************************************************************************/
     public async getIndiceValue(
        entrySid: number,
        indexSid: number,
        dimensionSid: number,
        roundSid: number,
        roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_dimension_sid', type: NUMBER, value: dimensionSid},
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_round_year', type: NUMBER, value: roundYear},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.getIndiceValue' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getIndiceAddAttributes
     *********************************************************************************************/
     public async getIndiceAddAttributes(
        indexSid: number
    ): Promise<IDBIndiceAddAttribute[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.getIndiceAddAttributes' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getEntryAtrribute
     *********************************************************************************************/
     public async getEntryAtrribute(
        entrySid: number,
        attrName: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_attr_name', type: STRING, value: attrName },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.getEntryAtrribute' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getIndiceData
     *********************************************************************************************/
     public async getIndiceData(
        indexSid: number,
        roundSid: number,
        roundYear: number,
        countryId: string
    ): Promise<IIndicesData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'p_country_id', type: STRING, value: countryId },

                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.getIndiceData' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
    * @method getIndiceEntryData
    *********************************************************************************************/
    public async getIndiceEntryData(
        indexSid: number,
        year: number,
        countryId: string
    ): Promise<IIndicesData> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_year', type: NUMBER, value: year},
                { name: 'p_country_id', type: STRING, value: countryId},
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndiceEntryData' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
    * @method getLovId
    *********************************************************************************************/
    public async getLovId(
        lovSid: number
    ): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_lov_sid', type: NUMBER, value: lovSid },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getLovId' , options)
        return dbResult.o_res
    }
    

    //////////////////////////////// SETTERS //////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calcEntryCriteriaScore
     *********************************************************************************************/
     public async calcEntryCriteriaScore(
        entrySid: number,
        criterionSid: number,
        accessor: string,
        choiceScoreSid?: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_choice_score_sid', type: NUMBER, value: choiceScoreSid},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const SP = 'cfg_scores.' + accessor
        const dbResult = await this.execSP(SP , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setIndiceValue
     *********************************************************************************************/
     public async setIndiceValue(
        entrySid: number,
        indexSid: number,
        dimensionSid: number,
        dimensionValue: string,
        roundSid: number,
        roundYear: number,
        countryId: string,
        sectorId?: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_dimension_sid', type: NUMBER, value: dimensionSid},
                { name: 'p_dimension_value', type: STRING, value: dimensionValue},
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_round_year', type: NUMBER, value: roundYear},
                { name: 'p_country_id', type: STRING, value: countryId},
                { name: 'p_sector_id', type: STRING, value: sectorId},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.setIndiceValue' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setIndiceRankValue
     *********************************************************************************************/
     public async setIndiceRankValue(
        entrySid: number,
        indexSid: number,
        dimensionSid: number,
        dimensionValue: string,
        roundSid: number,
        roundYear: number,
        countryId: string,
        sector: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_dimension_sid', type: NUMBER, value: dimensionSid},
                { name: 'p_dimension_value', type: STRING, value: dimensionValue},
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_round_year', type: NUMBER, value: roundYear},
                { name: 'p_country_id', type: STRING, value: countryId},
                { name: 'p_sector', type: STRING, value: sector},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.setIndiceRankValue' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setIndiceCoverage
     *********************************************************************************************/
     public async setIndiceCoverage(
        entrySid: number,
        indexSid: number,
        dimensionSid: number,
        dimensionValue: string,
        sectorId: string,
        roundSid: number,
        roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_dimension_sid', type: NUMBER, value: dimensionSid},
                { name: 'p_dimension_value', type: STRING, value: dimensionValue},
                { name: 'p_sector_id', type: STRING, value: sectorId},
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_round_year', type: NUMBER, value: roundYear},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.setIndiceCoverage' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setIndiceAttrValue
     *********************************************************************************************/
     public async setIndiceAttrValue(
        indexSid: number,
        entrySid: number,
        attrId: string,
        attrValue: number,
        roundSid: number,
        roundYear: number,
        countryId: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_attr_name', type: STRING, value: attrId},
                { name: 'p_attr_value', type: NUMBER, value: attrValue},
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_round_year', type: NUMBER, value: roundYear},
                { name: 'p_country_id', type: STRING, value: countryId},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.setIndiceAttrValue' , options)
        return dbResult.o_res
    } 
    
    /**********************************************************************************************
     * @method setIndiceMultiAttrValue
     *********************************************************************************************/
     public async setIndiceMultiAttrValue(
        indexSid: number,
        entrySid: number,
        attrId: string,
        attrValue: string,
        roundSid: number,
        roundYear: number,
        countryId: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_attr_name', type: STRING, value: attrId},
                { name: 'p_attr_value', type: STRING, value: attrValue},
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_round_year', type: NUMBER, value: roundYear},
                { name: 'p_country_id', type: STRING, value: countryId},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        
        const dbResult = await this.execSP('cfg_scores.setIndiceMultiAttrValue' , options)
        return dbResult.o_res
    } 

    /**********************************************************************************************
     * @method setCountryIdxCalculationStage
     *********************************************************************************************/
    public async setCountryIdxCalculationStage(
        indexSid: number,
        countryId: string,
        roundSid: number,
        stageSid: number,
        iteration: string,
        user: string,
        organisation?: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_stage_sid', type: NUMBER, value: stageSid },
                { name: 'p_iteration', type: STRING, value: iteration },
                { name: 'p_user', type: STRING, value: user },
                { name: 'p_organisation', type: STRING, value: organisation },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_scores.setCountryIdxCalculationStage', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setEntryCriterionScore
     *********************************************************************************************/
     public async setEntryCriterionScore(
        entrySid: number,
        roundSid: number,
        criterionSid: number,
        versionSid: number,
        score: number,
        user: string,
        department: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_version_sid', type: NUMBER, value: versionSid },
                { name: 'p_score', type: NUMBER, value: score },
                { name: 'p_user', type: STRING, value: user },
                { name: 'p_organisation', type: STRING, value: department },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_scores.setEntryCriterionScore', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method sendEmail
     *********************************************************************************************/
    public async sendEmail(
        user: string, indexSid: number, criterionSid: number, entrySid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user', type: STRING, value: user},
                { name: 'p_index_sid', type: NUMBER, value: indexSid},
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid},
                { name: 'p_entry_sid', type: NUMBER, value: entrySid},
                { name: 'o_res', type: NUMBER, dir: BIND_OUT}
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_scores.sendEmail', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method calcAllScores
     *********************************************************************************************/
    public async calcAllScores(
        indexSid: number,
        roundSid: number,
        entrySid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT},
            ],
            arrayFormat: true
        }
        const SP = 'cfg_scores.calculateScores'
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method setAttributeValue
     *********************************************************************************************/
    public async setAttributeValue(
        entrySid: number,
        questionVersionSid: number,
        val: string,
        details: string,
        accessor: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_value', type: STRING, value: val.toString() },
                { name: 'p_details', type: STRING, value: details },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const SP = 'cfg_accessors.set' + accessor
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method clearQuestionValue
     *********************************************************************************************/
    public async clearQuestionValue(
        entrySid: number,
        questionVersionSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const SP = 'cfg_accessors.clearQuestionValue'
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method execSP
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private execSP(sp: string, options: ISPOptions): Promise<any> {
        return this.dbService.storedProc(sp, options)
    }
}
