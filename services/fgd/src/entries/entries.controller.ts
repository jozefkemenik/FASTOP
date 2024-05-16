import { Response } from 'express'

import { IError } from '../../../lib/dist'

import { EQuestionType, IDBSection, IDBSectionSubsection, IEntry } from '../shared'
import { IGroupedResponseChoice, IQuestionnaireEntries, ISingleResponseChoice, IUpdateResult } from '.'
import { EntriesPdfExporter } from './entries-pdf-exporter'
import { EntriesService } from './entries.service'
import { SharedService } from '../shared/shared.service'

export class EntriesController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

        private _reponseChoices: {SINGLE: ISingleResponseChoice[], GROUPED: IGroupedResponseChoice[]} =
        {SINGLE: [], GROUPED: []}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private entriesService: EntriesService, private sharedService: SharedService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAssessmentResponseDetails
     *********************************************************************************************/
    public getAssessmentResponseDetails(
        ruleSid: number, attrSid: number, periodSid: number, roundSid: number
    ) {
        return this.sharedService.getAssessmentResponseDetails(ruleSid, attrSid, periodSid, roundSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.getAssessmentResponseDetails'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getRuleScoreDetails
     *********************************************************************************************/
    // modify calling of getScoreComments (V1. DB, V2. tableof ruleCriteriaSid)
    public async getRuleScoreDetails(
        ruleSid: number, roundSid: number, criterionSid: number, versionSid: number, isMS: boolean
    ) {
            const dbDetails = await
            this.entriesService.getRuleScoreDetails(ruleSid, roundSid, criterionSid, versionSid, isMS ? 1 : 0)
                .catch(
                    (err: IError) => {
                        err.method = 'EntriesController.getRuleScoreDetails'
                        throw err
                    }
                )
            const result = await Promise.all(dbDetails.map(async elem => {

                return {ENTRY_CRITERIA_SID: elem.ENTRY_CRITERIA_SID,
                        SCORE: elem.SCORE,
                        SCORE_VERSION_SID: elem.SCORE_VERSION_SID,
                        LDAP_LOGIN: elem.LDAP_LOGIN,
                        ORGANISATION: elem.ORGANISATION,
                        DATETIME: elem.DATETIME,
                        ACC_LDAP_LOGIN: elem.ACC_LDAP_LOGIN,
                        ACC_DATETIME: elem.ACC_DATETIME,
                        ACC_ORGANISATION: elem.ACC_ORGANISATION,

                        comments: await this.sharedService.getScoreComments(elem.ENTRY_CRITERIA_SID, isMS ? 1 : 0) }
                })
            )
            return result

    }

    /**********************************************************************************************
     * @method getEntryScores
     *********************************************************************************************/
    public getEntryScores(
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        ruleSid: number, indexSid: number, roundSid: number, versionSid: number, criterionSid: number, isMS: boolean
    ) {
        return this.entriesService.getEntryScores(ruleSid, indexSid, roundSid, versionSid, criterionSid, isMS ? 1 : 0)
        .catch(
            (err: IError) => {
                err.method = 'EntriesController.getEntryScores'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getAttributeResponseDetails
     *********************************************************************************************/
    public getAttributeResponseDetails(
        ruleSid: number, attrSid: number, mode: string, periodSid = 0
    ) {
        return this.sharedService.getAttributeResponseDetails(ruleSid, attrSid, mode, periodSid)
        .catch(
            (err: IError) => {
                err.method = 'EntriesController.getAttributeResponseDetails'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getQuestionValues
     *********************************************************************************************/
    public async getQuestionValues(
        entrySid: number, questionVersionSid: number, formatResp: boolean, roundYear?: number
    ) {
        const questType = await this.sharedService.questionType((
            await this.sharedService.questionInfo(questionVersionSid)).type)
        return this.sharedService.getAttributeValues(entrySid, questionVersionSid, questType.accessor, formatResp, roundYear)
    }

    /**********************************************************************************************
     * @method getQuestionLastUpdate
     *********************************************************************************************/
    public async getQuestionLastUpdate(
        entrySid: number, questionVersionSid: number
    ) {
        return this.sharedService.getQuestionLastUpdate(entrySid, questionVersionSid)
    }

    /**********************************************************************************************
     * @method getAttributeOptions
     *********************************************************************************************/
    public async getAttributeOptions(
        ruleSid: number, attrSid: number
    ) {
        const questType = await this.sharedService.questionType((await this.sharedService.questionInfo(attrSid)).type)
        return this.sharedService.getAttributeOptions(ruleSid, questType.options).catch(
            (err: IError) => {
                err.method = 'EntriesController.getAttributeOptions'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getAssessmentValues
     *********************************************************************************************/
    public async getAssessmentValues(
        ruleSid: number, attrSid: number, periodSid: number, roundSid: number
    ) {
        const questType = await this.sharedService.questionType((await this.sharedService.questionInfo(attrSid)).type)
        return this.sharedService.getAssessmentValues(ruleSid, attrSid, periodSid, roundSid, questType.accessor)
    }

    /**********************************************************************************************
     * @method getComplianceValue
     *********************************************************************************************/
    public getComplianceValue(
        ruleSid: number, roundSid: number, periodSid: number
    ) {
        return this.sharedService.getComplianceValue(ruleSid, roundSid, periodSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.getComplianceValue'
                throw err
            }
        )

    }
    /**********************************************************************************************
     * @method getAttributeAdditionalInfo
     *********************************************************************************************/
    public async getAttributeAdditionalInfo(
        ruleSid: number, attrSid: number, periodSid?: number
    ) {
        return this.sharedService.getAttributeAdditionalInfo(ruleSid, attrSid, periodSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.getAttributeAdditionalInfo'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getTargetYears
     *********************************************************************************************/
    public async getTargetYears(
        year: number, appId: string
    ) {
        return this.sharedService.getTargetYears(year, appId).catch(
            (err: IError) => {
                err.method = 'EntriesController.getTargetYears'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getResponseChoices
     *********************************************************************************************/
    public async getResponseChoices(
        grouped: boolean
    ) {
        const dbResponseChoices = await this.entriesService.getResponseChoices()
        .catch(
            (err: IError) => {
                err.method = 'EntriesController.getResponseChoices'
                throw err
            }
        )
        const reponseChoices: {SINGLE: ISingleResponseChoice[], GROUPED: IGroupedResponseChoice[]} =
        {SINGLE: [], GROUPED: []}
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        reponseChoices.SINGLE = dbResponseChoices.reduce((acc: any, q) => {
            acc[q.RESPONSE_SID] = {id: q.RESPONSE_ID
                                 ,descr: q.DESCR
                                 , group_sid: q.RESPONSE_GROUP_SID
                                 , needsDetails: q.PROVIDE_DETAILS}
            return acc
        }, {})
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        reponseChoices.GROUPED = dbResponseChoices.reduce((acc: any, q) => {
            if (!acc[q.RESPONSE_GROUP_SID]) {
                acc[q.RESPONSE_GROUP_SID] = []
            }
            acc[q.RESPONSE_GROUP_SID].push({sid: q.RESPONSE_SID
                                          , id: q.RESPONSE_ID
                                          , descr: q.DESCR
                                          , needsDetails: q.PROVIDE_DETAILS
                                          , respType: q.RESPONSE_TYPE_SID
                                          , helpText: q.HELP_TEXT
                                         ,  choiceLimit: q.CHOICE_LIMIT
                                          , detailsText: q.DETS_TXT
                                          , infoIcon: q.INFO_ICON
                                          , infoTxt: q.INFO_TXT})
            return acc
        }, {})

        if (grouped) {
            return reponseChoices.GROUPED
        }
        return reponseChoices.SINGLE

    }

    /**********************************************************************************************
     * @method getTargetNAYears
     *********************************************************************************************/
    public getTargetNAYears(
        entrySid: number,
        attrSid: number
    ) {
        return this.sharedService.getTargetNAYears(entrySid, attrSid)
        .catch(
            (err: IError) => {
                err.method = 'EntriesController.getTargetNAYears'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getIfiName
     *********************************************************************************************/
    public getIfiName(
        ruleSid: number
    ) {
        return this.entriesService.getIfiName(ruleSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.getIfiName'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getRuleTypes
     *********************************************************************************************/
    public async getRuleTypes() {
        const ruleTypes = await this.entriesService.getRuleTypes().catch((err: IError) => {
            err.method = 'EntriesController.getRuleTypes';
            throw err;
        })
        const ret = []
        ruleTypes.forEach(row => {
            ret.push({'label': row.DESCR, 'value': row.LOV_SID})
        })
        return ret

    }

    /**********************************************************************************************
     * @method getEntryExport
     *********************************************************************************************/
    public async getEntryExport(
        entrySid: number,
        roundSid: number,
        year: number,
        country: string,
        questSid: number,
        warningMsg: string,
        res: Response
    ) {
        const entry:IEntry = await this.sharedService.getEntry(entrySid, roundSid)

        const sections:IDBSection[] = await this.sharedService.getQuestionnaireSections(questSid)

        const entries = await Promise.all(sections.map(async section => {
            const subsections:IDBSectionSubsection[] = await this.sharedService.getSectionSubsections(section.SECTION_VERSION_SID)

            section.SUBSECTIONS = await Promise.all(subsections.map(async subsection => {
                subsection.questions = await Promise.all(await this.getSectionQuestionEntries(subsection.SECTION_VERSION_SID,
                    entrySid, roundSid, country, entry.APP_ID, year, questSid, subsection.ASSESSMENT_PERIOD)).catch(
                        (err: IError) => {
                            err.method = 'EntriesController.wordgetSectionQuestionEntries'
                            throw err
                        }
                    )
                return subsection
            }))

            section.QUESTIONS = await Promise.all(await this.getSectionQuestionEntries(section.SECTION_VERSION_SID,
                entrySid, roundSid, country, entry.APP_ID, year, questSid, section.ASSESSMENT_PERIOD)).catch(
                    (err: IError) => {
                        err.method = 'EntriesController.wordgetSectionQuestionEntries'
                        throw err
                    })
            return section
        }))

        const questionnaireEntries: IQuestionnaireEntries = {
            appId: entry.APP_ID,
            countryCode: entry.COUNTRY_ID,
            country: '',
            year: year,
            entryNo: entry.ENTRY_NUMBER,
            entryVersion: entry.ENTRY_VERSION,
            entries: entries
        }

        const entriesPdfExporter = new EntriesPdfExporter();

        return await entriesPdfExporter.execute(questionnaireEntries, warningMsg, res);
    }

    //////////////////////////////////// SETTERS //////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isAttributeVisible
     *********************************************************************************************/
    public isAttributeVisible(
        attrSid: number, ruleSid: number, roundSid: number
    ) {
        return this.sharedService.isAttributeVisible(attrSid, ruleSid, roundSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.isAttributeVisible'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method hasDependentAttributes
     *********************************************************************************************/
    public hasDependentAttributes(
        attrSid: number
    ) {
        return this.sharedService.hasDependentAttributes(attrSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.hasDependentAttributes'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setAttributeValue
     *********************************************************************************************/
    public async setAttributeValue(
        ruleSid: number, questionVersionSid: number, value: string , details: string
    ) {

        const ret: IUpdateResult = {updatedRecords: -1, refreshAttrs: [], refreshHeader: false }
        const questInfo = await this.sharedService.questionInfo(questionVersionSid)
        const questType = await this.sharedService.questionType(questInfo.type)
        const respChoices = await this.sharedService.getResponseChoices()
        if (questType.mapToRC) {
            if (respChoices[value].needsDetails !== 1 && respChoices[value].needsDetails !== 4) {details = ''}
        }
        ret.updatedRecords = await this.sharedService.setAttributeValue(
            ruleSid,
            questionVersionSid,
            value,
            details,
            questType.accessor
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.setAttributeValue'
                throw err
            }
        )

        if (ret.updatedRecords === 1) {
            const query = await this.sharedService.getDependentAttributes(questionVersionSid).catch(
                (err: IError) => {
                    err.method = 'EntriesController.getDependentAttributes for setAttributeValue'
                    throw err
                }
            )
            ret.refreshAttrs = query.length > 0 ? query : []

            if (questType.multiple) {
                ret.refreshAttrs.push(questionVersionSid)
            }

            ret.refreshHeader = await this.sharedService.isAttributeInHeader(
                questionVersionSid,
                questInfo.qstnnr
            ).catch(
                (err: IError) => {
                    err.method = 'EntriesController.isAttributeInHeader for setAttributeValue'
                    throw err
                }
            )
        }
        return ret
    }

    /**********************************************************************************************
     * @method setAttributeResponseValue
     *********************************************************************************************/
    public async setAttributeResponseValue(
        entrySid: number, questionVersionSid: number, respSid: number, value?: number
    ) {
        return this.entriesService.setEntryQuestionResponseValue(
            entrySid,
            questionVersionSid,
            respSid,
            value ? value : 0
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.setAttributeResponseValue'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setAttributeAdditionalInfo
     *********************************************************************************************/
    public async setAttributeAdditionalInfo(
        ruleSid: number, attrSid: number, info: string, periodSid?: number
    ) {

        return this.entriesService.setAttributeAdditionalInfo(
            ruleSid,
            attrSid,
            info,
            periodSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.setAttributeAdditionalInfo'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setComplianceValue
     *********************************************************************************************/
    public async setComplianceValue(
        ruleSid: number, questionVersionSid: number, periodSid: number, value?: number
    ) {
        const ret: IUpdateResult = {updatedRecords: -1, refreshAttrs: [], refreshHeader: false }
        ret.updatedRecords = await this.entriesService.setComplianceValue(
            ruleSid, questionVersionSid, periodSid,
            value ? value : 0
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.setComplianceValue'
                throw err
            }
        )

        return ret
    }

    /**********************************************************************************************
     * @method setAmbitious
     *********************************************************************************************/
    public async setAmbitious(
        ruleSid: number, ambitious: boolean
    ) {
        return this.entriesService.setAmbitious(ruleSid, ambitious).catch(
            (err: IError) => {
                err.method = 'EntriesController.setAmbitious'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setEntryTargetNAYear
     *********************************************************************************************/
    public async setEntryTargetNAYear(
        entrySid: number, questionVersionSid: number, year: number, na: boolean
    ) {
        return this.entriesService.setEntryTargetNAYear(entrySid, questionVersionSid, year, na ? 1 : 0).catch(
            (err: IError) => {
                err.method = 'EntriesController.setEntryTargetNAYear'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method addRuleCriteriaIteration
     *********************************************************************************************/
    public async addRuleCriteriaIteration(
        ruleSid: number, roundSid: number, criterionSid: number, versionSid: number, score: number,
        ldap: string, department: string
    ) {
        return this.entriesService.addRuleCriteriaIteration(
            ruleSid, roundSid, criterionSid, versionSid, score, ldap, department
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.addRuleCriteriaIteration'
                throw err
            }
        )
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
    ) {
        return this.entriesService.createRule(
            country, ruleType, strDateAdopt, strDateImpl, ruleDescr, user, roundSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.createRule'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method createIfi
     *********************************************************************************************/
    public async createIfi(
        country: string, strDateEstab: string, nameEng: string, user: string, roundSid: number
    ) {
        return this.entriesService.createIfi(
            country, strDateEstab, nameEng, user, roundSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.createIfi'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method createGbd
     *********************************************************************************************/
    public async createGbd(
        country: string, strDateEstab: string, nameEng: string, user: string, roundSid: number
    ) {
        return this.entriesService.createGbd(
            country, strDateEstab, strDateEstab, nameEng, user, roundSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.createGbd'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method createMtbf
     *********************************************************************************************/
    public async createMtbf(
        country: string, strDateAdopt: string, strDateEntry: string, descr: string, user: string, roundSid: number
    ) {
        return this.entriesService.createMtbf(
            country, strDateAdopt, strDateEntry, descr, user, roundSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.createMtbf'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setAssessmentValue
     *********************************************************************************************/
    public async setAssessmentValue(
        ruleSid: number, roundSid: number, periodSid: number, attrSid: number, value: string, details: string
    ) {
        const ret: IUpdateResult = {updatedRecords: -1, refreshAttrs: [], refreshHeader: false }
        const questInfo = await this.sharedService.questionInfo(attrSid)
        const questType = await this.sharedService.questionType(questInfo.type)
        const respChoices = await this.sharedService.getResponseChoices()

        if (questType.mapToRC) {
            if (respChoices[value].needsDetails !== 1) {details = ''}
        }

        ret.updatedRecords = await this.entriesService.setAssessmentValue(
            ruleSid,
            roundSid,
            periodSid,
            null,
            null,
            value,
            attrSid,
            details,
            questType.accessor
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.setAssessmentValue'
                throw err
            }
        )

        if (ret.updatedRecords === 1) {
            const query = await this.sharedService.getDependentAttributes(attrSid).catch(
                (err: IError) => {
                    err.method = 'EntriesController.getDependentAttributes for setAssessmentValue'
                    throw err
                }
            )
            ret.refreshAttrs = query

            if (questType.multiple) {
                ret.refreshAttrs.push(attrSid)
            }

            ret.refreshHeader = await this.sharedService.isAttributeInHeader(
                attrSid,
                questInfo.qstnnr
            ).catch(
                (err: IError) => {
                    err.method = 'EntriesController.isAttributeInHeader for setAssessmentValue'
                    throw err
                }
            )
        }
        return ret
    }

    /**********************************************************************************************
     * @method setRuleCriterionScore
     *********************************************************************************************/
    public async setRuleCriterionScore(
        ruleSid: number, indexSid: number, roundSid: number, criterionSid: number, versionSid: number, score: number,
        ldap: string, depart: string, isMS: boolean
    ) {
        const stage = await this.sharedService.getIndexCalculationStages(indexSid)
        if (!stage.find(st => {
            if (isMS) {
                return st.SCORE_VERSION_SID === versionSid && st.READ_ONLY !== 1 && st.MS_SHARED === 1
            } else {
                return st.SCORE_VERSION_SID === versionSid && st.READ_ONLY !== 1
            }
        })) {return -1}

        let user = ''
        let department = ''
        if (isMS) {
            user = ldap
            department = depart
            const emailConfirmation = await this.sharedService.sendEmail(user, indexSid, criterionSid, ruleSid)
            if (emailConfirmation > 0) {return -1}
        }
        

        return this.sharedService.setEntryCriterionScore(
            ruleSid,
            roundSid,
            criterionSid,
            versionSid,
            score,
            user,
            department
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.setRuleCriterionScore'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method duplicateEntry
     *********************************************************************************************/
    public async duplicateEntry(
        entrySid: number, reasonReform: string, dateReform: string,
        dateForceReform: string, ldap: string, roundSid: number
    ) {
        return this.entriesService.duplicateEntry(
            entrySid,
            reasonReform,
            dateReform,
            dateForceReform,
            ldap,
            roundSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.reformRule'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method abolishRule
     *********************************************************************************************/
    public async abolishRule(
        questionnaireSid: number, ruleSid: number, reason: string, date: string
    ) {
        return this.entriesService.abolishEntry(
            ruleSid,
            reason,
            date
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.abolishEntry'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method deleteAttributeValue
     *********************************************************************************************/
    public async deleteAttributeValue(
        ruleSid: number, attrSid: number, value: string
    ) {
        const ret: IUpdateResult = {updatedRecords: -1, refreshAttrs: [], refreshHeader: false }
        const questInfo = await this.sharedService.questionInfo(attrSid)
        const questType = await this.sharedService.questionType(questInfo.type)

        if (!questType.multiple) {return ret}

        ret.updatedRecords = await this.entriesService.deleteAttributeValue(
            ruleSid, attrSid, value
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.deleteAttributeValue'
                throw err
            }
        )

            const query = await this.sharedService.getDependentAttributes(attrSid).catch(
                (err: IError) => {
                    err.method = 'EntriesController.getDependentAttributes for delete'
                    throw err
                }
            )
            ret.refreshAttrs = query
            if (questType.multiple) {
                ret.refreshAttrs.push(attrSid)
            }
            ret.refreshHeader = await this.sharedService.isAttributeInHeader(attrSid, questInfo.qstnnr)

        return ret
    }

    /**********************************************************************************************
     * @method deleteAssessmentValue
     *********************************************************************************************/
    public async deleteAssessmentValue(
        ruleSid: number, roundSid: number, periodSid: number, attrSid: number, value: string
    ) {
        const ret: IUpdateResult = {updatedRecords: -1, refreshAttrs: [], refreshHeader: false }
        const questInfo = await this.sharedService.questionInfo(attrSid)
        const questType = await this.sharedService.questionType(questInfo.type)

        if (!questType.multiple) {return ret}

        ret.updatedRecords = await this.entriesService.deleteAttributeValue(
            ruleSid, attrSid, value, periodSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.deleteAttributeValue'
                throw err
            }
        )

            const query = await this.sharedService.getDependentAttributes(attrSid).catch(
                (err: IError) => {
                    err.method = 'EntriesController.getDependentAttributes for delete'
                    throw err
                }
            )

            ret.refreshAttrs = query
            if (questType.multiple) {
                ret.refreshAttrs.push(attrSid)
            }
            ret.refreshHeader = await this.sharedService.isAttributeInHeader(attrSid, questInfo.qstnnr)

        return ret
    }

    /**********************************************************************************************
     * @method clearAssessmentValue
     *********************************************************************************************/
    public async clearAssessmentValue(
        ruleSid: number, roundSid: number, periodSid: number, attrSid: number
    ) {
        const ret: IUpdateResult = {updatedRecords: -1, refreshAttrs: [], refreshHeader: false }
        const questInfo = await this.sharedService.questionInfo(attrSid)

        ret.updatedRecords = await this.entriesService.clearAssessmentValue(
            ruleSid, attrSid, periodSid
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.clearAssessmentValue'
                throw err
            }
        )

        const query = await this.sharedService.getDependentAttributes(attrSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.getDependentAttributes for delete'
                throw err
            }
        )

        ret.refreshAttrs = query
        ret.refreshHeader = await this.sharedService.isAttributeInHeader(attrSid, questInfo.qstnnr)
        return ret
    }

    /**********************************************************************************************
     * @method deleteEntryTargetNAYear
     *********************************************************************************************/
    public async deleteEntryTargetNAYear(
        entrySid: number, questionVersionSid: number, year: number
    ) {
        return this.entriesService.deleteEntryTargetNAYear(entrySid, questionVersionSid, year).catch(
            (err: IError) => {
                err.method = 'EntriesController.deleteEntryTargetNAYear'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSectionQuestionEntries
     *********************************************************************************************/
     private async getSectionQuestionEntries(
        sectionSid: number,
        entrySid: number,
        roundSid: number,
        country: string,
        appId: string,
        year: number,
        questSid: number,
        assesmentPeriod: number
    ) {
        // Get applicable section questions
        const questions = (await this.sharedService.getSectionQuestions(sectionSid,
            entrySid, roundSid, assesmentPeriod, false).catch(
                (err: IError) => {
                    err.method = 'EntriesController.wordgetSectionQuestions'
                    throw err
                }
            )).filter(q => Number(q.COND_SID) !== 0)

        const responseGroups = await this.getResponseChoices(true).catch(
            (err: IError) => {
                err.method = 'EntriesController.wordgetResponseChoices'
                throw err
            }
        )

        const questionResponses = await Promise.all(questions.map(async questionResponse => {
            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
            const question:any = await this.sharedService.getQuestion(
                questionResponse.QUESTION_VERSION_SID,
                questionResponse.COND_SID
                ).catch(
                    (err: IError) => {
                    err.method = 'EntriesController.wordgetQuestion'
                    throw err
                }
            )

            const questionType = await this.sharedService.questionType((await this.sharedService.questionInfo(
                questionResponse.QUESTION_VERSION_SID)).type
            )

            Object.assign(  question,
                            {'RESPONSE_CHOICES': []},
                            {'ADDITIONAL_INFO_TEXT': ''},
                            {'COMPLIANCE': []},
                            {'options': []},
                            {'LINKED_ENTRIES': []},
                            {'TARGETS': []},
                            {'ANSWERS': []}
            )

            question.RESPONSE_CHOICES = responseGroups[question.LOV_TYPE_SID]

            let provideDetails = []

            if (question.QUESTION_TYPE_SID === EQuestionType.NO_CHOICE) {
                provideDetails = await this.getAttributeResponseDetails(
                    entrySid,
                    question.MASTER_SID,
                    'Values',
                    assesmentPeriod
                    ).catch(
                        (err: IError) => {
                        err.method = 'EntriesController.wordgetAttributeResponseDetails'
                        throw err
                    }
                )
            } else {
                provideDetails = await this.getAttributeResponseDetails(
                    entrySid,
                    questionResponse.QUESTION_VERSION_SID,
                    'Details',
                    assesmentPeriod
                    ).catch(
                        (err: IError) => {
                        err.method = 'EntriesController.wordgetAttributeResponseDetails'
                        throw err
                    }
                )
            }

            let responseValues = []

            if (assesmentPeriod > 0) {
                if (questionResponse.QUESTION_TYPE_SID === EQuestionType.ASSESSMENT_COMPLIANCE) {
                    // e.g. NFR - Planned Budgetary Data OR Outturn Budgetary Data
                    question.COMPLIANCE = await this.getComplianceAnswer (
                        entrySid,
                        questionResponse.QUESTION_VERSION_SID,
                        assesmentPeriod,
                        roundSid,
                        questionType.accessor
                    )
                } else if (questionResponse.QUESTION_TYPE_SID === EQuestionType.NUMERICAL_TARGET) {
                    question.TARGETS = await this.getNumericalTargetAnswers(
                        entrySid,
                        appId,
                        year,
                        question.QUESTION_VERSION_SID
                    )
                } else {
                    responseValues = await this.sharedService.getAssessmentValues(
                        entrySid,
                        questionResponse.QUESTION_VERSION_SID,
                        assesmentPeriod,
                        roundSid,
                        questionType.accessor
                    ).catch(
                        (err: IError) => {
                            err.method = 'EntriesController.wordgetAssessmentValues'
                            throw err
                        }
                    )
                }

            } else {
                switch(question.QUESTION_TYPE_SID) {
                    case EQuestionType.NO_CHOICE: {
                        // e.g. NFR - Estimated Share of exluded elements - percentage -- question_version_sid=5
                        // Get values from question_version_sid=2 - Gvt Sectors (stored in target_entries)
                        responseValues = await this.getNoChoiceAnswers(
                            entrySid,
                            question.MASTER_SID,
                            questionType.accessor,
                            true,
                            year
                        )
                        break
                    }
                    case EQuestionType.NUMERICAL_TARGET: {
                        // e.g. NFR - Numerical Target (in selected Measurement Unit)
                        question.TARGETS = await this.getNumericalTargetAnswers(
                            entrySid,
                            appId,
                            year,
                            question.QUESTION_VERSION_SID
                         )
                        break
                    }
                    case EQuestionType.LINKED_ENTRIES: {
                        // e.g. NFR - Other Rules covering the same Sector(s) question_version_sid=12
                        question.LINKED_ENTRIES = await this.getLinkedEntryAnswers(
                            entrySid,
                            questionType.options,
                            questSid,
                            responseGroups
                        )
                        break
                    }
                    default: {
                        responseValues = await this.sharedService.getAttributeValues(
                            entrySid,
                            questionResponse.QUESTION_VERSION_SID,
                            questionType.accessor,
                            true,
                            year
                        ).catch(
                            (err: IError) => {
                                err.method = 'EntriesController.wordgetAttributeValues'
                                throw err
                            }
                        )
                    }
                }
            }

            // SET ANSWERS
            if (question.MAP_TO_RESP_CHOICES === 1) {
                /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                let responses: ISingleResponseChoice | IGroupedResponseChoice | any
                if (responseGroups[question.LOV_TYPE_SID]) {
                    responses = responseGroups[question.LOV_TYPE_SID]
                } else {
                    responses = []
                }

                responses.forEach(async response => {
                    if (response.needsDetails > 1) {
                        response.institution = await this.sharedService.getCountryIFI(country, response.needsDetails)
                    }
                    if (Object.values(responseValues).includes(response.sid)) {
                        response.provideDetails = provideDetails.filter(d => d.RESPONSE_SID == response.sid)
                        response.SELECTED = response.sid
                        question.ANSWERS.push(response)
                    }
                })
            } else {
                question.ANSWERS.push(responseValues.join())
            }

            if (question.ADD_INFO !== null && question.ADD_INFO === 1) {
                question.ADDITIONAL_INFO_TEXT = await this.getAttributeAdditionalInfo(
                    entrySid,
                    questionResponse.QUESTION_VERSION_SID,
                    assesmentPeriod
                )
            }

            return question

        })).catch(
            (err: IError) => {
                err.method = 'EntriesController.WordSectionQuestions'
                throw err
            })

        return questionResponses
    }

    /**********************************************************************************************
     * @method getComplianceAnswer
     *********************************************************************************************/
    private async getComplianceAnswer (
        entrySid: number,
        questionVersionSid: number,
        assesmentPeriod: number,
        roundSid: number,
        accessor: string
    ) {
        const complianceSourceSid = await this.sharedService.getAssessmentValues(
            entrySid,
            questionVersionSid,
            assesmentPeriod,
            roundSid,
            accessor
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.wordgetAssessmentValues'
                throw err
            }
        )

        const complianceOptions = await this.sharedService.getComplianceOptions(
            entrySid, assesmentPeriod).catch(
                (err: IError) => {
                    err.method = 'EntriesController.getComplianceOptions'
                    throw err
                })

        const complianceValue = await this.sharedService.getComplianceValue(
            entrySid, roundSid, assesmentPeriod).catch(
                (err: IError) => {
                    err.method = 'EntriesController.getComplianceValue'
                    throw err
                })

        const complianceSource = complianceOptions.filter(c => c.COMPLIANCE_SOURCE_SID === complianceSourceSid[0])
        const complianceSourceDescr =
            complianceSource[0] !== undefined ? complianceSource[0].DESCR: 'Custom compliance assessment'

        return {
            complianceSource: complianceSourceDescr,
            complianceValue: complianceValue
        }
    }

    /**********************************************************************************************
     * @method getLinkedEntryAnswers
     *********************************************************************************************/
    private async getLinkedEntryAnswers (
        entrySid: number,
        options: string,
        questionnaireSid: number,
        responseGroups: any[],   /* eslint-disable-line @typescript-eslint/no-explicit-any */
        roundYear?: number
    ) {
        const linkedEntries = []

        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const entries:any[] = await this.sharedService.getAttributeOptions(entrySid,
            options).catch(
                (err: IError) => {
                    err.method = 'EntriesController.wordgetAttributeOptions'
                    throw err
                }
            )

        // hdrAttrs array containing linked questions:
        // QUESTION_VERSION_SID, SHORT, MAPPING_TYPE, MAP_TO_RESP_CHOICES, ACCESSOR
        const hdrAttrs = (await this.sharedService.getHeaderAttributes(questionnaireSid,
            'questionnaire').catch(
                (err: IError) => {
                    err.method = 'EntriesController.wordgetHeaderAttributes'
                    throw err
                }
            )).slice(0, 2).sort((a, b) => a.QUESTION_VERSION_SID - b.QUESTION_VERSION_SID)

        await Promise.all(entries.map(async entry => {
            const linkedAnswers = []
            const linkedAnswersSummary = {nature: null, sectors: null}

            hdrAttrs.forEach(async hdrAttr => {
                    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                    const question:any = await this.sharedService.getQuestion(
                        hdrAttr.QUESTION_VERSION_SID,
                        -1
                        ).catch(
                            (err: IError) => {
                            err.method = 'EntriesController.wordgetQuestion'
                            throw err
                        }
                    )

                    const hdrAttribValues = await this.sharedService.getAttributeValues(
                        entry.ENTRY_SID,
                        hdrAttr.QUESTION_VERSION_SID,
                        hdrAttr.ACCESSOR,
                        true,
                        roundYear
                    ).catch(
                        (err: IError) => {
                            err.method = 'EntriesController.wordgetAttributeValues'
                            throw err
                        }
                    )

                    const answerChoices = []
                    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                    const responseChoices: ISingleResponseChoice | IGroupedResponseChoice | any =
                        responseGroups[question.LOV_TYPE_SID]

                    hdrAttribValues.forEach(async hdrAttribValue => {
                        responseChoices.forEach(async response => {
                            if (hdrAttribValue === response.sid) {
                                answerChoices.push(response)
                            }
                        })
                    })

                    if (question.QUESTION_VERSION_SID === 1) {
                        linkedAnswersSummary.nature = answerChoices[0].descr
                    }

                    if (question.QUESTION_VERSION_SID === 2) {
                        const sectorsAnswerArray = []
                        answerChoices.forEach(async answerChoice => {
                            sectorsAnswerArray.push(answerChoice.id)
                        })
                        linkedAnswersSummary.sectors = sectorsAnswerArray.toString()
                    }

                    linkedAnswers.push(answerChoices)
                })

                const linkedEntry = {
                    entrySid: entry.ENTRY_SID,
                    linkedEntrySummary: linkedAnswersSummary
                }

                linkedEntries.push(linkedEntry)

                return entry
            })
        )

        return linkedEntries
    }

    /**********************************************************************************************
     * @method getNoChoiceAnswers
     *********************************************************************************************/
    private async getNoChoiceAnswers (
        entrySid: number,
        masterSid: number,
        accessor: string,
        formatResp: boolean,
        roundYear: number
    ) {
        return await this.sharedService.getAttributeValues(
            entrySid,
            masterSid,
            accessor,
            formatResp,
            roundYear
        ).catch(
            (err: IError) => {
                err.method = 'EntriesController.wordgetAttributeValues'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getNumericalTargetAnswers
     *********************************************************************************************/
    private async getNumericalTargetAnswers (
        entrySid: number,
        appId: string,
        year: number,
        questionVersionSid: number
     ) {
        const targets = await Promise.all(await this.sharedService.getAttributeResponseDetails(entrySid,
            questionVersionSid,
            'Values')).catch(
                (err: IError) => {
                    err.method = 'EntriesController.wordgetAttributeResponseDetails'
                    throw err
                }
            )

        const targetYears = await this.sharedService.getTargetYears(year, appId).catch(
            (err: IError) => {
                err.method = 'EntriesController.wordgetTargetYears'
                throw err
            }
        )

        const applicableTargets = []

        for (const targetYear of targetYears) {
            for (const target of targets) {
                if (target.RESPONSE_SID === targetYear) {
                    applicableTargets.push(target)
                    break
                }
            }
        }

        return applicableTargets.sort((a, b) => a.RESPONSE_SID - b.RESPONSE_SID)
    }
}
