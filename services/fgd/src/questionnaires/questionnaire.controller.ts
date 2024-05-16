import { DashboardApi } from '../../../lib/dist/api'
import { EApps } from 'config'

import { SharedService } from '../shared/shared.service'

import { EQuestionType, IEntry, IResponseDetail } from '../shared'
import { IError } from '../../../lib/dist'
import { IInvalidSection } from './shared-interfaces'
import { IQuestionnaireIndex } from '.'
import { QuestionnaireService } from './questionnaire.service'

export class QuestionnaireController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    private _questionnaireIndexes: {[qstnnrSectionSid: number]: IQuestionnaireIndex[]} = {}
    private appId: EApps

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private questionnaireService: QuestionnaireService,
        private sharedService: SharedService,
        private _app: EApps
        ) {
            this.appId = _app
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getQuestionnaires
     *********************************************************************************************/
    public getQuestionnaires() {
        return this.sharedService.getQuestionnaires()
            .catch(
                (err: IError) => {
                    err.method = 'QuestionnaireController.getQuestionnaires'
                    throw err
                }
            )

    }

    /**********************************************************************************************
     * @method getQstnnrVersion
     *********************************************************************************************/
    public getQstnnrVersion(questionnaireSid: number, countryId: string) {
        return this.sharedService.getQstnnrVersion(questionnaireSid, countryId)
            .catch(
                (err: IError) => {
                    err.method = 'QuestionnaireController.getQuestionnaires'
                    throw err
                }
            )

    }

    /**********************************************************************************************
     * @method getHeaderAttributes
     *********************************************************************************************/
    public async getHeaderAttributes(
        qstnnrVersionSid: number, flag: string
    ) {
        return this.sharedService.getHeaderAttributes(qstnnrVersionSid, flag)
            .catch(
                (err: IError) => {
                    err.method = 'QuestionnaireController.getHeaderAttributes'
                    throw err
                }
            )

    }

    /**********************************************************************************************
     * @method getCustomHeaderAttributes
     *********************************************************************************************/
    public async getCustomHeaderAttributes(
        qstnnrVersionSid: number,
        page: string
    ) {
        return this.questionnaireService.getCustomHeaderAttributes(qstnnrVersionSid, page)
            .catch(
                (err: IError) => {
                    err.method = 'QuestionnaireController.getCustomHeaderAttributes'
                    throw err
                }
            )

    }
    /**********************************************************************************************
     * @method getQuestionnaireSubmissionDate
     *********************************************************************************************/
    public async getQuestionnaireSubmissionDate(
        questionnaireSid: number, countryId: string, roundSid: number
    ) {
        const submit = await this.questionnaireService.getQuestionnaireSubmissionDate(questionnaireSid, countryId,
            roundSid).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getQuestionnaireSubmissionDate'
                throw err
            }
        )
        if (submit[0] !== undefined) {
            return submit[0]
        } else return []

    }

    /**********************************************************************************************
     * @method getQuestionnaireYears
     *********************************************************************************************/
    public getQuestionnaireYears(
        questionnaireSid: number
    ) {
        return this.questionnaireService.getQuestionnaireYears(questionnaireSid).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getQuestionnaireYears'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getQuestionnaireIndexes
     *********************************************************************************************/
    public async getQuestionnaireIndexes(
        questionnaireSid: number
    ) {
        if (!this._questionnaireIndexes[questionnaireSid]) {
            this._questionnaireIndexes[questionnaireSid] =
                await this.sharedService.menuService.getQuestionnaireIndexes(this.appId).catch(
                    (err: IError) => {
                        err.method = 'QuestionnaireController.getQuestionnaireIndexes'
                        throw err
                    }
                )
        }
        return this._questionnaireIndexes[questionnaireSid]
    }

    /**********************************************************************************************
     * @method getQuestionnaireEntries
     *********************************************************************************************/
    public async getQuestionnaireEntries(
        questionnaireSid: number, countryId: string, roundSid: number, userCountries: string[]
    ) {
        let result = await this.questionnaireService.getQuestionnaireEntries(
            questionnaireSid, countryId, roundSid).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getQuestionnaireEntries'
                throw err
            }
        )

        if (this.appId === EApps.IFI) {
            result = result.filter(entry => userCountries.some(country => country.split('/')[1] === entry.IFI_MAIN_ABRV)
            )
        }
        result.forEach(entry => entry.IS_AMBITIOUS = String(entry.IS_AMBITIOUS) === '1' ? true : false)
        return result

    }

    /**********************************************************************************************
     * @method getQuestionnaireSections
     *********************************************************************************************/
    public getQuestionnaireSections(
        qstnnrVersionSid: number
    ) {
        return this.sharedService.getQuestionnaireSections(qstnnrVersionSid).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getQuestionnaireSections'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getEntry
     *********************************************************************************************/
    public async getEntry(
        entrySid: number, roundSid: number
    ) {
        return this.sharedService.getEntry(
            entrySid, roundSid).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getEntry'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getQuestionnaireElements
     *********************************************************************************************/
    public async getQuestionnaireElements(qstnnrVersionSid: number) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.questionnaireService.getQuestionnaireElements(qstnnrVersionSid, roundInfo.year).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getQuestionnaireElements'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getDialogMessage
     *********************************************************************************************/
    public async getDialogMessage(messageId: string) {
        return this.sharedService.getDialogMessage(messageId).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getDialogMessage'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method completeQuestionnaireRule
     *********************************************************************************************/
    public async completeQuestionnaireRule(
        questionnaireSid: number, year: number, ruleSid: number, roundSid: number, editStepSid: number,
        user: string
    ) {

        const ret = {invalidStep: true, result: -1, invalidSections: []}

        const editSteps = await this.sharedService.getEditSteps()
        const rule: IEntry = await this.getEntry(ruleSid, roundSid)

        if (( rule.EDIT_STEP_SID !== editStepSid ) ||
              rule.EDIT_STEP_ID === 'UPD' ||
              rule.EDIT_STEP_ID === 'CPL') {
            return ret
        }
        ret.invalidStep = false
        ret.invalidSections = await this.verifyRuleCompleteness(
            questionnaireSid, year, ruleSid, roundSid, editSteps[editStepSid].EDIT_STEP_ID
        ).catch(
            (err: IError) => {
                err.method = 'completeQuestionnaireRule.verifyRuleCompleteness error'
                throw err
            })
        if (ret.invalidSections.length > 0) {return ret}

        let newStep = 'CPL'
        if (editSteps[editStepSid].EDIT_STEP_ID === 'VFY') {newStep = 'UPD'}

        // if this point reached, the questionnaire is complete
        // should delete stored values for questions that are not displayed in the questionnaire
        this.questionnaireCleanUp(
            questionnaireSid, year, ruleSid, roundSid, editSteps[editStepSid].EDIT_STEP_ID
        )
        ret.result = await this.setEntryEditStep(
            ruleSid,
            newStep,
            user,
            this.appId,
            roundSid
        ).catch(
            (err: IError) => {
                err.method = 'completeQuestionnaireRule.setEntryEditStep error'
                throw err
            })

        if (newStep === 'CPL') {

            (await this.getQuestionnaireIndexes(questionnaireSid)).forEach(async index => {
                await this.sharedService.calcAllScores(index.INDEX_SID, roundSid, ruleSid).catch(
                    (err: IError) => {
                        err.method = 'completeQuestionnaireRule.calcAllScores error'
                        throw err
                    })
            })
        }

        return ret

    }

    /**********************************************************************************************
    * @method verifyRuleCompleteness
     *********************************************************************************************/
    public async verifyRuleCompleteness(
        questionnaireSid: number, year: number, ruleSid: number, roundSid: number, editStep: string
    ) {
        const emptyArray: (string | number)[] = []
        const emptyRespDetArr: IResponseDetail[] = []
        let verifyDesign = false
        let verifyCompliance = false
        switch (editStep) {
            case 'VFY':
                verifyDesign = true
                verifyCompliance = true
                break
            case 'RFM':
                verifyDesign = true
                verifyCompliance = true
                break
            case 'NEW':
                verifyDesign = true
                verifyCompliance = true
                break
            case 'NOC':
                verifyCompliance = true
                break
        }

        const choicesQuestionTypes = [EQuestionType.ASSESSMENT_MULTIPLE_CHOICE, EQuestionType.ASSESSMENT_SINGLE_CHOICE,
            EQuestionType.MULTIPLE_CHOICE, EQuestionType.SINGLE_CHOICE]

        const responseChoices = await this.sharedService.getResponseChoices(true)

        const questionnaire = (await this.sharedService.getQuestionnaires()).find(q => q.QUESTIONNAIRE_SID === questionnaireSid)

        const qstSections: IInvalidSection[] = (
            await this.sharedService.getQuestionnaireSections(questionnaireSid)).map(section => {
            return <IInvalidSection>{
                SECTION_VERSION_SID: section.SECTION_VERSION_SID,
                SECTION_ID: section.SECTION_ID,
                DESCR: section.DESCR,
                ASSESSMENT_PERIOD: section.ASSESSMENT_PERIOD,
                NO_HELP: section.NO_HELP,
                WORKFLOW_STEPS: section.WORKFLOW_STEPS,
                subsections: [],
                questions: []
            }
        })

        const sections = await Promise.all(qstSections.map(async section => {
            section.questions = []

            if (verifyDesign || (verifyCompliance && (!section.ASSESSMENT_PERIOD ||
                section.ASSESSMENT_PERIOD === 0))) {
                const questions = (await this.sharedService.getSectionQuestions(
                    section.SECTION_VERSION_SID, ruleSid, roundSid, section.ASSESSMENT_PERIOD)).filter(q => q.COND_SID !== 0)

                questions.forEach(async question => {
                    const q = await this.sharedService.getQuestion(question.QUESTION_VERSION_SID,
                         question.COND_SID)
                    question.DESCR = q.DESCR

                    const qInfo = await this.sharedService.questionInfo(question.QUESTION_VERSION_SID)
                    const questType = await this.sharedService.questionType(qInfo.type)
                    const values = await Promise.all(await this.sharedService.getAttributeValues(
                        ruleSid, question.QUESTION_VERSION_SID, questType.accessor, true, year))
                    if (choicesQuestionTypes.includes(q.QUESTION_TYPE_SID)) {
                        const respDetails = responseChoices[q.LOV_TYPE_SID].map(resp => {
                            if (resp.needsDetails === 1) return resp.sid
                        })
                        values.forEach(async val => {
                            if (respDetails.includes(val)) {
                                // check if there is a value for the needs Details
                                const dets = await this.sharedService.getAttributeResponseDetails(
                                    ruleSid, question.QUESTION_VERSION_SID, 'Details', 0)
                                if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                    dets.length === 0) section.questions.push(question)

                            }
                        })
                    }
                    if (q.MANDATORY === 1 && question.COND_SID !== 0 && (values === emptyArray || values.length === 0) ) {
                        section.questions.push(question)
                    }
                })
            }

            section.subsections = []
            const subsections = await this.sharedService.getSectionSubsections(section.SECTION_VERSION_SID)
            .catch(
                (err: IError) => {
                    err.method = 'verifyRuleCompleteness.getSectionSubsections'
                    throw err
                })

            section.subsections = await Promise.all(subsections.map(async subsection => {
                    subsection.questions = []
                    const questions = (await this.sharedService.getSectionQuestions(
                        subsection.SECTION_VERSION_SID, ruleSid, roundSid, subsection.ASSESSMENT_PERIOD)
                        .catch(
                            (err: IError) => {
                                err.method = 'verifyRuleCompleteness.getSectionQuestions'
                                throw err
                            })).filter(q => q.COND_SID !== 0)

                    if (verifyDesign && (!subsection.ASSESSMENT_PERIOD || subsection.ASSESSMENT_PERIOD === 0)) {
                        await Promise.all(questions.map(async question => {
                            const q = await this.sharedService.getQuestion(question.QUESTION_VERSION_SID,
                                question.COND_SID)
                            question.DESCR = q.DESCR
                            const questionInfo = await this.sharedService.questionInfo(question.QUESTION_VERSION_SID)
                            const questType = await this.sharedService.questionType(questionInfo.type)
                            if (questionInfo.type !== 8) {
                                if (questionInfo.type === 10) {
                                    const response = await this.verifyTargetEntries(
                                        questionnaire.APP_ID,
                                        ruleSid,
                                        q.QUESTION_VERSION_SID,
                                        year)
                                    if (!response ) {subsection.questions.push(question)}
                                } else {
                                    if (questionInfo.type !== 12 ) {
                                        const values = await this.sharedService.getAttributeValues(
                                            ruleSid, question.QUESTION_VERSION_SID, questType.accessor, true, year)
                                            if (choicesQuestionTypes.includes(q.QUESTION_TYPE_SID)) {
                                                const respDetails = responseChoices[q.LOV_TYPE_SID].map(resp => {
                                                    if (resp.needsDetails === 1) return resp.sid
                                                })
                                                await Promise.all(values.map(async val => {
                                                        if (respDetails.includes(val)) {
                                                            // check if there is a value for the needs Details
                                                            const dets = await this.sharedService.getAttributeResponseDetails(
                                                                ruleSid, question.QUESTION_VERSION_SID, 'Details', 0)
                                                            if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                                                dets.length === 0) section.questions.push(question)

                                                        }
                                                    })
                                                )
                                            }
                                            if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                                (values.length === 0 ||
                                                    values === emptyArray )) subsection.questions.push(question)
                                    } else {
                                        const values = await Promise.all(await this.sharedService.getAttributeResponseDetails(
                                            ruleSid,
                                            q.QUESTION_VERSION_SID, 'Values', 0))
                                        if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                            (values.length === 0 ||
                                                values === emptyRespDetArr )) subsection.questions.push(question)
                                    }
                                }
                            }
                        }))
                    } else if (subsection.SECTION_VERSION_SID === 16 || subsection.SECTION_VERSION_SID === 78) {
                        questions.map(async question => {
                            const q = await this.sharedService.getQuestion(question.QUESTION_VERSION_SID,
                                question.COND_SID)
                            question.DESCR = q.DESCR

                            const targets = await this.verifyTargetEntries(
                                questionnaire.APP_ID,
                                ruleSid,
                                q.QUESTION_VERSION_SID,
                                year).catch(
                                (err: IError) => {
                                    err.method = 'targetEntries'
                                    throw err
                                })

                            if ( !targets && question.COND_SID !== 0) {
                                subsection.questions.push(question)
                            }
                        })
                    } else if (verifyCompliance && subsection.ASSESSMENT_PERIOD && subsection.SECTION_VERSION_SID !== 7) {
                        await Promise.all(questions.map(async question => {
                            const q = await this.sharedService.getQuestion(question.QUESTION_VERSION_SID,
                                question.COND_SID)
                            question.DESCR = q.DESCR
                            const questionInfo = await this.sharedService.questionInfo(
                                (await question).QUESTION_VERSION_SID)
                            const questType = await this.sharedService.questionType(questionInfo.type)

                            if (questionInfo.type === 17) {
                                const value = await this.sharedService.getComplianceValue(
                                    ruleSid, roundSid, subsection.ASSESSMENT_PERIOD).catch(
                                        (err: IError) => {
                                            err.method = 'getComplianceValue'
                                            throw err
                                        })

                                if ( q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                    value === null ) subsection.questions.push(question)
                            } else if (questionInfo.type === 12) {
                                
                                const values = await this.sharedService.getAttributeResponseDetails(ruleSid,
                                    q.QUESTION_VERSION_SID, 'Values', 0)
                                if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                    (values.length === 0 || values === emptyRespDetArr )) subsection.questions.push(question)
                            } else {
                                
                                const values = await this.sharedService.getAssessmentValues(ruleSid,
                                    q.QUESTION_VERSION_SID,
                                    subsection.ASSESSMENT_PERIOD,
                                    roundSid,
                                    questType.accessor).catch(
                                        (err: IError) => {
                                            err.method = 'getAssessmentValues'
                                            throw err
                                        })
                                if (choicesQuestionTypes.includes(q.QUESTION_TYPE_SID)) {
                                    const respDetails = responseChoices[q.LOV_TYPE_SID].map(resp => {
                                        if (resp.needsDetails === 1) return resp.sid
                                    })
                                    await Promise.all(values.map(async val => {
                                            if (respDetails.includes(val)) {
                                                // check if there is a value for the needs Details
                                                const dets = await this.sharedService.getAssessmentResponseDetails(
                                                    ruleSid,
                                                    q.QUESTION_VERSION_SID, subsection.ASSESSMENT_PERIOD, roundSid)
                                                if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                                    dets.length === 0) subsection.questions.push(question)

                                            }
                                        })
                                    )
                                }
                                if (q.MANDATORY === 1 && question.COND_SID !== 0 &&
                                (values.length === 0 || values === emptyArray )) subsection.questions.push(question)
                                
                            }
                        }))
                    } 

                    return subsection
                })).catch(
                    (err: IError) => {
                        err.method = 'error subsection'
                        throw err
                    })
            return section
        })).catch(
            (err: IError) => {
                err.method = 'error section'
                throw err
            })
        const retSections = sections.filter(section => {
            section.subsections = section.subsections.filter(subsection => subsection.questions.length !== 0)

            return (section.questions.length !== 0 || section.subsections.length !== 0)
        })

        return retSections
    }

    /**********************************************************************************************
    * @method questionnaireCleanUp
     *********************************************************************************************/
    public async questionnaireCleanUp(
        questionnaireSid: number, year: number, ruleSid: number, roundSid: number, editStep: string
    ) {
        let verifyDesign = false
        let verifyCompliance = false
        switch (editStep) {
            case 'VFY':
                verifyDesign = true
                verifyCompliance = true
                break
            case 'RFM':
                verifyDesign = true
                verifyCompliance = true
                break
            case 'NEW':
                verifyDesign = true
                verifyCompliance = true
                break
            case 'NOC':
                verifyCompliance = true
                break
        }

        const qstSections = await this.sharedService.getQuestionnaireSections(questionnaireSid)
        await Promise.all(qstSections.map(async section => {
            if (verifyDesign || (verifyCompliance && (!section.ASSESSMENT_PERIOD ||
                section.ASSESSMENT_PERIOD === 0))) {
                const questions = (await this.sharedService.getSectionQuestions(
                    section.SECTION_VERSION_SID, ruleSid, roundSid, section.ASSESSMENT_PERIOD))
                questions.map(async question => {
                    if (question.COND_SID === 0) {
                        await this.sharedService.clearQuestionValue(ruleSid, question.QUESTION_VERSION_SID)
                    }
                })
            }

            const subsections = await this.sharedService.getSectionSubsections(section.SECTION_VERSION_SID)
            .catch(
                (err: IError) => {
                    err.method = 'questionnaireCleanUp.getSectionSubsections'
                    throw err
                })
            await Promise.all(subsections.map(async subsection => {

                const questions = (await this.sharedService.getSectionQuestions(
                    subsection.SECTION_VERSION_SID, ruleSid, roundSid, subsection.ASSESSMENT_PERIOD)
                    )
                if (verifyDesign && (!subsection.ASSESSMENT_PERIOD || subsection.ASSESSMENT_PERIOD === 0)) {
                    await Promise.all(questions.map(async question => {
                        if (question.COND_SID === 0) {
                            await this.sharedService.clearQuestionValue(ruleSid, question.QUESTION_VERSION_SID)
                        }
                    }))
                } else if (verifyCompliance && subsection.ASSESSMENT_PERIOD) {
                    await Promise.all(questions.map(async question => {
                        if (question.COND_SID === 0) {
                            await this.sharedService.clearQuestionValue(ruleSid, question.QUESTION_VERSION_SID)
                        }
                    }))
                }
            })
            )
        })
        )
    }

    /**********************************************************************************************
    * @method verifyTargetEntries
     *********************************************************************************************/
    public verifyTargetEntries(
        appId: string, ruleSid: number, attrSid: number, year: number
    ) {
        return this.sharedService.verifyTargetEntries(appId, ruleSid, attrSid, year).catch(
            (err: IError) => {
                err.method = 'questionnaireController.verifyTargetEntries'
                throw err
            })
    }

    /**********************************************************************************************
     * @method setEntryEditStep
     *********************************************************************************************/
    public async setEntryEditStep(
        entrySid: number, stepId: string, login: string, appId: string, roundSid: number
    ) {
        return this.questionnaireService.setEntryEditStep(
            entrySid,
            stepId,
            login,
            appId,
            roundSid
        ).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.setEntryEditStep'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method noChangeRule
     *********************************************************************************************/
    public async noChangeRule(
        questionnaireSid: number, ruleSid: number, roundSid: number, user: string
    ) {
        const rule: IEntry = await this.getEntry(ruleSid, roundSid)
        if (rule.EDIT_STEP_ID !== 'UPD') {return -1}
        return this.setEntryEditStep(
            ruleSid,
            'NOC',
            user,
            this.appId,
            roundSid
        )
    }

    /**********************************************************************************************
     * @method reopenEntry
     *********************************************************************************************/
    public async reopenEntry(
        questionnaireSid: number, ruleSid: number, roundSid: number, editStepSid: number, user: string
    ) {
        let ret = -1
        const rule: IEntry = await this.getEntry(ruleSid, roundSid)
        if (rule.EDIT_STEP_SID !== editStepSid) {return ret}
        const oldStep = rule.EDIT_STEP_ID
        let newStep = rule.PREV_STEP_ID
        switch (oldStep) {
            case 'UPD':
            case 'NOC':
                newStep = 'UPD'
                break
            case 'CPL':
                newStep = 'UPD'
                break
            case 'RFM':
            case 'RFF':
                return this.questionnaireService.abortReform(
                    await this.sharedService.getQuestionnaireId(questionnaireSid),
                    ruleSid,
                    user
                ).catch(
                    (err: IError) => {
                        err.method = 'QuestionnaireController.abortReform'
                        throw err
                    }
                )
            default:
                return ret
        }

        ret = await this.setEntryEditStep(
            ruleSid,
            newStep,
            user,
            this.appId,
            roundSid
        )

        if (ret >= 0) {
            this.questionnaireService.unsubmitQuestionnaire(
                questionnaireSid,
                rule.COUNTRY_ID,
                roundSid,
                user
            ).catch(
                (err: IError) => {
                    err.method = 'QuestionnaireController.unsubmitQuestionnaire'
                    throw err
                }
            )
        }

        return ret
    }

    /**********************************************************************************************
     * @method submitQuestionnaire
     *********************************************************************************************/
    public async submitQuestionnaire(
        questionnaireSid: number, countryId: string, roundSid: number, user: string, department: string,
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        isMS: boolean, entries: number[]
    ) {
        const ret = await this.questionnaireService.submitQuestionnaire(
            questionnaireSid,
            countryId,
            roundSid,
            user
        ).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.submitQuestionnaire'
                throw err
            }
        )

        if (ret >= 0) {
            const indexes = await this.getQuestionnaireIndexes(questionnaireSid)
            indexes.forEach(async (index) => {
                const result = await this.sharedService.setAutomaticScores(index.INDEX_SID, countryId, roundSid, user, department,
                    entries)
                if (result < 0) return result
            })
        }
        return ret
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
