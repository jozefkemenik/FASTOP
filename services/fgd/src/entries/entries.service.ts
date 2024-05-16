import { BIND_OUT, CURSOR, DATE, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'

import { IAbolishEntry, IDBCreateReform, IDBResponseChoices, IDBRuleScoreDetail, IDBRuleType, IDuplicateEntry } from '.'
import { IComment, IScore } from '../shared/'
import { FgdDbService } from '../db/db.service'

export class EntriesService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRuleScoreDetails
     *********************************************************************************************/
    public async getRuleScoreDetails(
        entrySid: number, roundSid: number, criterionSid: number, versionSid: number, msOnly: number
    ): Promise<IDBRuleScoreDetail[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_version_sid', type: NUMBER, value: versionSid },
                { name: 'p_ms_only', type: NUMBER, value: msOnly },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getEntryScoreDetails' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getRuleScores
     *********************************************************************************************/
    public async getEntryScores(
        entrySid: number, indexSid: number, roundSid: number, versionSid: number, criterionSid: number, msOnly: number
    ): Promise<IScore[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_version_sid', type: NUMBER, value: versionSid },
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_ms_only', type: NUMBER, value: msOnly },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getEntryScores' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getResponseChoices
     *********************************************************************************************/
    public async getResponseChoices(): Promise<IDBResponseChoices[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getResponseChoices' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getScoreComments
     *********************************************************************************************/
    public async getScoreComments(
        ruleCriteriaSid: number,
        isMS: number
    ): Promise<IComment[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_rule_criteria_sid', type: NUMBER, value: ruleCriteriaSid },
                { name: 'p_is_ms', type: NUMBER, value: isMS},
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getScoreComments' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIfiName
     *********************************************************************************************/
    public async getIfiName(
        entrySid: number
    ): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_rule_no', type: NUMBER, value: entrySid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.getIfiName' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getRuleTypes
     *********************************************************************************************/
    public async getRuleTypes(): Promise<IDBRuleType[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getRuleTypes' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method setComplianceValue
     *********************************************************************************************/
    public async setComplianceValue(
        entrySid: number, questionVersionSid: number, periodSid: number, val?: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_value', type: NUMBER, value: val },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.setEntryComplianceValue' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setAmbitious
     *********************************************************************************************/
    public async setAmbitious(
        entrySid: number, ambitious: boolean
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_ambitious', type: NUMBER, value: ambitious ? 1 : 0 },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.setAmbitious' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setEntryTargetNAYear
     *********************************************************************************************/
    public async setEntryTargetNAYear(
        entrySid: number, questionVersionSid: number, year: number, na: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_year', type: NUMBER, value: year },
                { name: 'p_na', type: NUMBER, value: na },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.setEntryTargetNAYear' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method addRuleCriteriaIteration
     *********************************************************************************************/
    public async addRuleCriteriaIteration(
        entrySid: number, roundSid: number, criterionSid: number, versionSid: number, score: number,
        user: string, organisation?: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_criterion_sid', type: NUMBER, value: criterionSid },
                { name: 'p_version_sid', type: NUMBER, value: versionSid },
                { name: 'p_score', type: NUMBER, value: score },
                { name: 'p_user', type: STRING, value: user },
                { name: 'p_organisation', type: STRING, value: organisation },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_scores.addRuleCriteriaIteration' , options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method createRule
     *********************************************************************************************/
    public async createRule(
        country: string,
        ruleType: number,
        strDateAdopt: string,
        strDateImpl: string,
        ruleDescr: string,
        user: string,
        roundSid: number
    ): Promise<IDBCreateReform> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country', type: STRING, value: country },
                { name: 'p_ruletype', type: NUMBER, value: ruleType },
                { name: 'p_dateadopt', type: DATE, value: new Date(strDateAdopt) },
                { name: 'p_date_impl', type: DATE, value: new Date(strDateImpl) },
                { name: 'p_description', type: STRING, value: ruleDescr },
                { name: 'p_last_login', type: STRING, value: user },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'p_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.createRule' , options)
        return dbResult
    }

    /**********************************************************************************************
     * @method createIfi
     *********************************************************************************************/
    public async createIfi(
        country: string, strDateEstab: string, nameEng: string, user: string, roundSid: number
    ): Promise<IDBCreateReform> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country', type: STRING, value: country },
                { name: 'p_estabdate', type: DATE, value: new Date(strDateEstab) },
                { name: 'p_engname', type: STRING, value: nameEng },
                { name: 'p_last_login', type: STRING, value: user },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'p_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.createIfi' , options)
        return dbResult
    }

    /**********************************************************************************************
     * @method createGbd
     *********************************************************************************************/
    public async createGbd(
        country: string, strDateAdopt: string, strDateEntry: string,
        nameEng: string, user: string, roundSid: number
    ): Promise<IDBCreateReform> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country', type: STRING, value: country },
                { name: 'p_adoptdate', type: DATE, value: new Date(strDateAdopt) },
                { name: 'p_entrydate', type: STRING, value: new Date(strDateEntry) },
                { name: 'p_engname', type: STRING, value: nameEng },
                { name: 'p_last_login', type: STRING, value: user },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'p_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.createGbd' , options)
        return dbResult
    }

    /**********************************************************************************************
     * @method createMtbf
     *********************************************************************************************/
    public async createMtbf(
        country: string, strDateAdopt: string, strDateEntry: string,
        descr: string, user: string, roundSid: number
    ): Promise<IDBCreateReform> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country', type: STRING, value: country },
                { name: 'p_adoptdate', type: DATE, value: new Date(strDateAdopt) },
                { name: 'p_entrydate', type: DATE, value: new Date(strDateEntry) },
                { name: 'p_engname', type: STRING, value: descr },
                { name: 'p_last_login', type: STRING, value: user },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'p_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.createMtbf' , options)
        return dbResult
    }

    /**********************************************************************************************
     * @method setEntryQuestionResponseValue
     *********************************************************************************************/
    public async setEntryQuestionResponseValue(
        entrySid: number,
        questionVersionSid: number,
        responseSid: number,
        val?: number
    ): Promise<number> {

        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_value', type: STRING, value: String(val) },
                { name: 'p_response_sid', type: NUMBER, value: responseSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.setEntryQuestionResponseValue', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setAttributeAdditionalInfo
     *********************************************************************************************/
    public async setAttributeAdditionalInfo(
        entrySid: number,
        questionVersionSid: number,
        info: string,
        periodSid?: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_info', type: STRING, value: info },
                { name: 'p_period_sid', type: NUMBER, value: periodSid ? periodSid : 0 },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.setEntryQuestionAdditionalInfo', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setAssessmentValue
     *********************************************************************************************/
    public async setAssessmentValue(
        entrySid: number,
        roundSid: number,
        periodSid: number,
        tableName: string,
        attrName: string,
        val: string,
        attrSid: number,
        details: string,
        accessor: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: attrSid },
                { name: 'p_value', type: STRING, value: String(val) },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_details', type: STRING, value: details },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const SP = 'cfg_accessors.set' + accessor
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method duplicateEntry
     *********************************************************************************************/
    public async duplicateEntry(
        entrySid: number,
        reasonReform: string,
        dateReform: string,
        dateForceReform: string,
        username: string,
        roundSid: number
    ): Promise<IDuplicateEntry> {
        const options: ISPOptions = {
            params: [
                { name: 'p_in_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_reason', type: STRING, value: reasonReform },
                { name: 'p_date', type: DATE, value: new Date(dateReform) },
                { name: 'p_date_force', type: DATE, value: new Date(dateForceReform) },
                { name: 'p_last_login', type: STRING, value: username },
                { name: 'p_out_entry_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'p_ret', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP('cfg_questionnaire.duplicateEntry', options)
        return dbResult
    }

    /**********************************************************************************************
     * @method abolishEntry
     *********************************************************************************************/
    public async abolishEntry(
        entrySid: number,
        reason: string,
        date: string
    ): Promise<IAbolishEntry> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_reason', type: STRING, value: reason },
                { name: 'p_date', type: DATE, value: new Date(date) },
                { name: 'p_ret', type: NUMBER, dir: BIND_OUT },
            ]
        }
        const dbResult = await this.execSP('cfg_questionnaire.abolishEntry', options)
        return dbResult
    }

    /**********************************************************************************************
     * @method deleteAttributeValue
     *********************************************************************************************/
    public async deleteAttributeValue(
        entrySid: number,
        questionVersionSid: number,
        val: string,
        periodSid? : number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_value', type: STRING, value: val },
                { name: 'p_period_sid', type: NUMBER, value: periodSid ? periodSid : 0 },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.deleteEntryQuestionValue', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method deleteAssessmentValue
     *********************************************************************************************/
    public async deleteAssessmentValue(
        entrySid: number,
        roundSid: number,
        periodSid: number,
        tableName: string,
        attrName: string,
        val: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_table_name', type: STRING, value: tableName },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_attr_name', type: STRING, value: attrName },
                { name: 'p_value', type: STRING, value: val },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const SP = 'cfg_accessors.deleteRuleAssessmentMultValue'
        const dbResult = await this.execSP(SP, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method clearAssessmentValue
     *********************************************************************************************/
    public async clearAssessmentValue(
        entrySid: number,
        questionVersionSid: number,
        periodSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.clearAssessmentValue', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method deleteEntryTargetNAYear
     *********************************************************************************************/
    public async deleteEntryTargetNAYear(
        entrySid: number, questionVersionSid: number, year: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_question_version_sid', type: NUMBER, value: questionVersionSid },
                { name: 'p_year', type: NUMBER, value: year },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_accessors.deleteEntryTargetNAYear' , options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
