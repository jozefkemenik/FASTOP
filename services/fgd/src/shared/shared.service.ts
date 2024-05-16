import { DashboardApi, GridsApi } from '../../../lib/dist/api'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { EApps } from 'config'
import { IError } from '../../../lib/dist/error.service'

import { ICondResp, IEditStep, IEntry,
         IGroupedRespChoice, IQQuestion, IQuestion,
         IQuestionTypeAccessor, IQuestionnaire, ISectionQuestion, ISectionSubsection, ISingleRespChoice } from '.'
import { MenuService } from '../menu/menu.service'
import { SharedDbService } from './shared.db.service'

export class SharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

        private _questions: {[QUESTION_VERSION_SID: number]: IQuestion} = {}
        private _conditionalAttributes: {[QUESTION_VERSION_SID: number]: {[COND_QUESTION_VERSION_SID: number]: ICondResp[]}} = {}
        private _questionTypeAccessors: {[QUESTION_TYPE_SID: number]: IQuestionTypeAccessor} = {}
        private _responseChoices: {single: {[RESPONSE_ID: number]: ISingleRespChoice[]},
                                  grouped: {[RESPONSE_GROUP_SID: number]: IGroupedRespChoice[]}} =
                                  {single: {},
                                grouped: {}}
        private _sectionQuestions: {[qstnnrSectionSid: number]: ISectionQuestion[]} = {}
        private _sectionSubsections: {[qstnnrSectionSid: number]: ISectionSubsection[]} = {}
        private _questionnaireIds: {[sid: number]: string} = {}
        private _editSteps: {[EDIT_STEP_SID: number]: IEditStep} = {}
        private _qstnnrVersions: {[key: number]: number} = {}

        private _dbService: SharedDbService
        private _menuService: MenuService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    public appId: EApps
    constructor(_app: EApps, dbService: DbService<DbProviderService>) {
        this.appId = _app
        this._menuService = new MenuService(this.appId, dbService)
        this._dbService = new SharedDbService(dbService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get menuService() {
        return this._menuService
    }

    private get dbService() {
        return this._dbService
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getQstnnrVersion
     *********************************************************************************************/
    public async getQstnnrVersion(questionnaireSid: number, countryId: string) {
        const key = `${countryId}${questionnaireSid}`
        if (!this._qstnnrVersions[key]) {
            this._qstnnrVersions[key] = await this.dbService.getQstnnrVersion(questionnaireSid, countryId)
                .catch(
                    (err: IError) => {
                        err.method = 'QuestionnaireController.getQuestionnaires'
                        throw err
                    }
                )
        }
        return this._qstnnrVersions[key]
    }

    /**********************************************************************************************
     * @method getQstnnrVersionForEntry
     *********************************************************************************************/
     public async getQstnnrVersionForEntry(entrySid: number, roundSid: number) {
        const entry:IEntry = await this.getEntry(entrySid, roundSid)
        const questionnaires:IQuestionnaire[] = await this.getQuestionnaires()
        const questionnaire:IQuestionnaire = questionnaires.find(q => q.APP_ID === entry.APP_ID)

        return await this.getQstnnrVersion(questionnaire.QUESTIONNAIRE_SID, entry.COUNTRY_ID)
    }

    /**********************************************************************************************
     * @method getCountryIFI
     *********************************************************************************************/
    public getCountryIFI(
        countryId: string, monitoring: number
    ) {
        return this.dbService.getCountryIFI(countryId, monitoring).catch(
            (err: IError) => {
                err.method = 'ConfigController.getCountryIFI'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getAttributeValues
     *********************************************************************************************/
    public async getAttributeValues(
        ruleSid: number, attrSid: number, accessor: string, formatResp: boolean, roundYear?: number
    ) {
        const response = await this.dbService.getAttributeValues(ruleSid, attrSid, accessor, formatResp, roundYear)
        .catch(
            (err: IError) => {
                err.method = 'SharedService.getAttributeValues'
                throw err
            }
        )

        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const ret: Array<number | string> = response.reduce((acc, q: any) => {
            acc.push(q.RESPONSE)
            return acc
        }, [])

        return ret

    }

    /**********************************************************************************************
     * @method getQuestionLastUpdate
     *********************************************************************************************/
    public async getQuestionLastUpdate(
        entrySid: number, questionVersionSid: number
    ) {
        return this.dbService.getQuestionLastUpdate(entrySid, questionVersionSid)
    }

    /**********************************************************************************************
     * @method getAttributeOptions
     *********************************************************************************************/
    public async getAttributeOptions(
        ruleSid: number, options: string
    ) {
        return this.dbService.getAttributeOptions(ruleSid, options).catch(
            (err: IError) => {
                err.method = 'RulesController.getAttributeOptions'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getEntry
     *********************************************************************************************/
     public async getEntry(
        entrySid: number, roundSid: number
    ): Promise<IEntry> {
        return this.dbService.getEntry(entrySid, roundSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getEntry'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getAssessmentValues
     *********************************************************************************************/
    public async getAssessmentValues(
        ruleSid: number, attrSid: number, periodSid: number, roundSid: number, accessor: string
    ) {
        const response = await this.dbService.getAssessmentValues(ruleSid, attrSid, periodSid, roundSid, accessor)
        .catch(
            (err: IError) => {
                err.method = 'SharedService.getAssessmentValues'
                throw err
            }
        )

        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        return response.reduce((acc , q: any) => {
            acc.push(q.RESPONSE)
            return acc
        }, [])
    }

    /**********************************************************************************************
     * @method getAttributeAdditionalInfo
     *********************************************************************************************/
    public async getAttributeAdditionalInfo(
        ruleSid: number, attrSid: number, periodSid?: number
    ) {
        return this.dbService.getAttributeAdditionalInfo(ruleSid, attrSid, periodSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getAttributeAdditionalInfo'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getSectionQuestions
     *********************************************************************************************/
    public async getSectionQuestions(
        qstnnrSectionSid: number, ruleSid: number, roundSid: number, periodSid: number, applyConditions = true
    ) {
        const dbSectionQuestions = await this.dbService.getSectionQuestions(qstnnrSectionSid).catch(
                (err: IError) => {
                    err.method = 'SharedService.getSectionQuestions'
                    throw err
                }
        )
        const qs = dbSectionQuestions.map(q => {
            if (!q.UPD_ROLES) {q.UPD_ROLES = []}
            return q
        })
        this._sectionQuestions[qstnnrSectionSid] = qs

        return await this.addConditions(
            this._sectionQuestions[qstnnrSectionSid],
            ruleSid,
            roundSid,
            applyConditions,
            periodSid
        )
    }

    /**********************************************************************************************
     * @method getEntryQuestionsStatus
     *********************************************************************************************/
    /*
     public async getEntryQuestionsStatus(
        entrySid: number, roundSid: number
    ) {
        const qstnnrVersionSid = await this.getQstnnrVersionForEntry(entrySid, roundSid)
        const allQuestionsWithConditions = await this.getAllQuestionsWithConditions(
            qstnnrVersionSid, entrySid, roundSid
        )

        const entryQuestionsStatus = await Promise.all(allQuestionsWithConditions.map(async question => {
            question.COND_QUESTION_VERSION_SID = null
            question.COND_SID = question.CONDITIONAL_QUESTIONS === undefined ? -1 : null

            return question
        })).catch(
            (err: IError) => {
                err.method = 'SharedService.getEntryQuestionsStatus'
                throw err
            })

        // Determine question status for dependent questions
        entryQuestionsStatus.forEach(question => {

            if (question.COND_SID === null) {
                let validDependentQuestion = false
                let dependentFound = false

                for (const key of Object.keys(question.CONDITIONAL_QUESTIONS)) {
                    const questionVersionSid = parseInt(key)
                    const condQuestionStatus = entryQuestionsStatus.find(q => q.QUESTION_VERSION_SID === questionVersionSid)

                    if (condQuestionStatus !== undefined) { // Ignore dummy questions
                        if (condQuestionStatus.COND_SID !== null) {
                            validDependentQuestion = true
                        }

                        if (condQuestionStatus.COND_SID !== null && condQuestionStatus.COND_SID !== 0) {
                            for (const conditionalQuestion of question.CONDITIONAL_QUESTIONS[key]) {
                                for (const RESPONSE_VALUE of condQuestionStatus.RESPONSE_VALUES) {
                                    if (conditionalQuestion.LOV_SID === RESPONSE_VALUE) {
                                        // i.e. first dependent response value found
                                        question.COND_QUESTION_VERSION_SID = questionVersionSid
                                        question.COND_SID = conditionalQuestion.COND_SID
                                        dependentFound = true
                                        break
                                    }
                                }
                            }
                        }

                        if (dependentFound) {
                            break
                        }
                    }
                }

                if (validDependentQuestion && question.COND_SID === null) {
                    question.COND_SID = 0
                }
            }


            return question
        })

        return entryQuestionsStatus
    }
    */

    /**********************************************************************************************
     * @method getAllQuestionsWithConditions
     *********************************************************************************************/
    /*
     public async getAllQuestionsWithConditions(
        qstnnrVersionSid: number, entrySid: number, roundSid: number
    ) {
        // Get all questionnaire questions. Order by section order, subsection order, section question order
        const questionnaireQuestions = await this.getQuestionnaireQuestions(qstnnrVersionSid)

        // Get all conditional questions
        const conditionalQuestions = await this.getConditionalQuestions()

        const allQuestionsWithConditions = await Promise.all(questionnaireQuestions.map(async question => {
            question.RESPONSE_VALUES = await this.getResponseValues(
                entrySid, roundSid, question.ASSESSMENT_PERIOD, question.QUESTION_VERSION_SID, question.ACCESSOR
            )
            question.CONDITIONAL_QUESTIONS = conditionalQuestions[question.QUESTION_VERSION_SID]

            return question
        }))

        return allQuestionsWithConditions
    }
    */

    /**********************************************************************************************
     * @method getResponseValues
     *********************************************************************************************/
    public async getResponseValues(
        entrySid: number, roundSid: number, periodSid: number, questionVersionSid: number, accessor: string
    ) {
        if (accessor === 'EntryLinkableEntries') {
            return await this.getAttributeResponseDetails(entrySid, Number(questionVersionSid), 'Values', 0)
        }

        return await Promise.all((periodSid === 1 || periodSid === 2) ?
            await this.getAssessmentValues(entrySid, Number(questionVersionSid), periodSid, roundSid, accessor) :
            await this.getAttributeValues(entrySid, Number(questionVersionSid), accessor, true))
    }

    /**********************************************************************************************
     * @method getCompletionSectionQuestions
     *********************************************************************************************/
    public async getCompletionSectionQuestions(
        qstnnrSectionSid: number, ruleSid: number, roundSid: number, periodSid: number, applyConditions = true
    ) {
        const dbSectionQuestions = await this.dbService.getSectionQuestions(qstnnrSectionSid).catch(
                (err: IError) => {
                    err.method = 'SharedService.getSectionQuestions'
                    throw err
                }
        )
        const qs = dbSectionQuestions.map(q => {
            if (!q.UPD_ROLES) {q.UPD_ROLES = []}
            return q
        })

        const filteredQuestions = await this.addConditions(
            qs,
            ruleSid,
            roundSid,
            applyConditions,
            periodSid
        )

        return await Promise.all(filteredQuestions.map(async q => {

            const dbQuestion = await this.getQuestion(q.QUESTION_VERSION_SID, q.COND_SID)
            const ret = Object.assign( q, {DESCR: dbQuestion.DESCR})
            return ret
        }))
    }

    /**********************************************************************************************
     * @method getSectionSubsections
     *********************************************************************************************/
    public async getSectionSubsections(
        qstnnrSectionSid: number
    ) {
        if (!this._sectionSubsections[qstnnrSectionSid]) {
            const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
            const dbSectionSubsections = await this.dbService.getSectionSubsections(qstnnrSectionSid, roundInfo.year).catch(
                (err: IError) => {
                    err.method = 'SharedService.getSectionSubsections'
                    throw err
                }
            )
            this._sectionSubsections[qstnnrSectionSid] = dbSectionSubsections
        }
        return this._sectionSubsections[qstnnrSectionSid]

    }

    /**********************************************************************************************
     * @method getDialogMessage
     *********************************************************************************************/
    public async getDialogMessage(
        messageId: string
    ) {
        return this.dbService.getDialogMessage(messageId).catch(
                (err: IError) => {
                    err.method = 'SharedService.getDialogMessage'
                    throw err
                }
            )
    }

    /**********************************************************************************************
     * @method getSectionHdrAttributes
     *********************************************************************************************/
    public getSectionHdrAttributes(
        qstnnrVersionSid: number, sectionVersionSid: number
    ) {
        return this.dbService.getSectionHdrAttributes(qstnnrVersionSid, sectionVersionSid).catch(
                (err: IError) => {
                    err.method = 'SharedService.getSectionHdrAttributes'
                    throw err
                }
            )

    }

    /**********************************************************************************************
     * @method getQuestionPeriod
     *********************************************************************************************/
    public getQuestionPeriod(questionVersionSid: number): Promise<number> {
        return this.dbService.getQuestionPeriod(questionVersionSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getQuestionPeriod'
                throw err
            }
        )
    }
    /**********************************************************************************************
     * @method isAttributeVisible
     *********************************************************************************************/
    public  async isAttributeVisible(
        attrSid: number, ruleSid: number, roundSid: number
    ): Promise<number> {
        const conditionalAttributes = await this.getConditionalQuestions().catch(
            (err: IError) => {
                err.method = 'isAttributeVisible.getConditionalAttributes'
                throw err
            }
        )
        if (!conditionalAttributes[attrSid]) {return -1}
        let conditionCounter = Object.keys(conditionalAttributes[attrSid]).length
        // check for level 2 and level 3 conditions
        const levelsObj = await this.getCondQuestionsByLvl(attrSid)
        const fixedCounter = Object.keys(conditionalAttributes[attrSid]).length
        let conditionCounterChk = 0
        let displayCounter = 0
        let responsesCounter = []
        const levelsResponses = Object.keys(levelsObj).reduce( (acc, lvl) => {
            acc[lvl] = 0
            return acc
        }, {})

        if (conditionalAttributes[attrSid]) {
            for (const condAttr of Object.keys(conditionalAttributes[attrSid])) {
                const responses = conditionalAttributes[attrSid][condAttr]
                for (const resp of responses) {
                    if (resp.LOV_SID === 0) {return -1}
                }
                const condAtPerSid = await this.dbService.getQuestionPeriod(Number(condAttr))
                const questType = await this.questionType((await this.questionInfo(Number(condAttr))).type)
                const values = await Promise.all((condAtPerSid === 1 || condAtPerSid === 2) ?
                await this.getAssessmentValues(ruleSid, Number(condAttr), condAtPerSid, roundSid, questType.accessor)
                : await this.getAttributeValues(ruleSid, Number(condAttr), questType.accessor, true))

                for (const resp of responses) {
                    if (values.includes(resp.LOV_SID) ||
                    (resp.LOV_SID === 0 && values.length > 0  )) {
                        responsesCounter.push(resp.COND_SID)
                        if (conditionCounter === 1) {
                            conditionCounterChk = resp.COND_SID
                        }
                        if (Object.keys(levelsObj).length > 0) {
                            // loop through all levels
                                for (const level of Object.keys(levelsObj)) {
                                    // loop through all attr_sid-s from that level
                                    for (const attrLvl of Object.keys(levelsObj[level])) {
                                        // for lvl 2 interested only in attrLvl === condAttr
                                        if (Number(attrLvl) === Number(condAttr)) {
                                            for (const condLvl of Object.keys(levelsObj[level][attrLvl])) {
                                                const respsLvl = levelsObj[level][attrLvl][condLvl]
                                                const qTypLvl =
                                                    await this.questionType((await
                                                        this.questionInfo(Number(condLvl))).type)
                                                const condLvlPerSid = await this.dbService.getQuestionPeriod(Number(condLvl))
                                                const valLvl =  await Promise.all(
                                                    (condLvlPerSid === 1 || condLvlPerSid === 2) ?
                                                await this.getAssessmentValues(ruleSid,
                                                        Number(condLvl),
                                                        condLvlPerSid,
                                                        roundSid, qTypLvl.accessor)
                                                : await this.getAttributeValues(ruleSid,
                                                    Number(condLvl),
                                                    qTypLvl.accessor,
                                                    true))
                                                for (const respLvl of respsLvl) {
                                                    if (valLvl.includes(respLvl.LOV_SID)) {
                                                // lvl2 condition is fullfilled, so lvl 1 is also fulfilled
                                                // show the attribute if only lvl2 exists
                                                levelsResponses[level] = respLvl.LOV_SID
                                            } else {
                                                // lvl 2 condition is not fulfilled, so neither is lvl 1
                                                // remove from responses, if it is the case
                                                responsesCounter = responsesCounter.filter(q => q !== resp.COND_SID)
                                                continue
                                            }
                                                }
                                            }
                                        } else {
                                            for(const condLvl of Object.keys(levelsObj[level][attrLvl])) {
                                                const respsLvl = levelsObj[level][attrLvl][condLvl]
                                                const qTypLvl =
                                                    await this.questionType((await
                                                        this.questionInfo(Number(condLvl))).type)
                                                const condLvlPerSid = await this.dbService.getQuestionPeriod(Number(condLvl))
                                                const valLvl =  await Promise.all(
                                                    (condLvlPerSid === 1 || condLvlPerSid === 2) ?
                                                await this.getAssessmentValues(ruleSid,
                                                        Number(condLvl),
                                                        condLvlPerSid,
                                                        roundSid, qTypLvl.accessor)
                                                : await this.getAttributeValues(ruleSid,
                                                    Number(condLvl),
                                                    qTypLvl.accessor,
                                                    true))
                                                    for (const respLvl of respsLvl) {
                                                        if (valLvl.includes(respLvl.LOV_SID)) {
                                                            levelsResponses[level] = respLvl.LOV_SID
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                                if (Object.keys(levelsObj).length === 1 &&
                                Number(Object.values(levelsResponses)[0]) > 0) {
                                    return resp.COND_SID
                                }
                                if (Object.keys(levelsObj).length > 1) {
                                    const levelsRespLen = Object.keys(levelsResponses).length
                                    const levelsRespPos = []
                                    for (const lvl of Object.keys(levelsResponses)) {
                                        if (levelsResponses[lvl] > 0) {
                                            levelsRespPos.push(lvl)
                                        }
                                    }
                                    if (levelsRespPos.length === levelsRespLen) {
                                        return resp.COND_SID
                                    } else {
                                        return 0
                                    }
                                }
                        } else {
                            if (fixedCounter === 1) {
                                return resp.COND_SID
                            }
                        }
                    }
                }

                if (conditionCounter >= 2 || conditionCounter === 1 ) {
                    displayCounter = 1
                }
                if (conditionCounter > 1 ) {
                    conditionCounter = conditionCounter - 1
                    continue
                } else {
                    if (fixedCounter > 2) {
                        if (responsesCounter.length <= 1) {
                            return 0
                        } else {
                            return conditionCounterChk
                        }
                    } else {
                        if ( displayCounter === 1 && responsesCounter.length >= 1) {
                            if (responsesCounter.includes(conditionCounterChk)) {
                                return conditionCounterChk
                            } else {
                                return responsesCounter[0]
                            }
                        } else return 0
                    }
                }
            }
        } else {
            return -1
        }
    }

    /**********************************************************************************************
     * @method hasDependentAttributes
     *********************************************************************************************/
    public async hasDependentAttributes(
        attrSid: number
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    ): Promise<any[]> {
        const dbCondAttrs = await this.dbService.getConditionalQuestions()
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.hasDependentAttributes'
                    throw err})
        const hasDependentAttr = dbCondAttrs.reduce((acc, q) => {
            if (!acc[q.COND_QUESTION_VERSION_SID]) {
                acc[q.COND_QUESTION_VERSION_SID] = []
            }
            acc[q.COND_QUESTION_VERSION_SID].push({QUESTION_VERSION_SID: q.QUESTION_VERSION_SID})
            return acc
        }, {})

        return hasDependentAttr[attrSid]
    }

    /**********************************************************************************************
     * @method getCondQuestionsByLvl
     *********************************************************************************************/
    public async getCondQuestionsByLvl(
        attrSid: number
    ) {
        const dbCondLvl = await this.dbService.getCondQuestionsByLvl(attrSid)
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.getCondQuestionsByLvl'
                    throw err})
        const ret = dbCondLvl.reduce( (acc, q) => {
            if (!acc[q.LVL]) {
                acc[q.LVL] = {}
            }

            if (!acc[q.LVL][q.QUESTION_VERSION_SID]) {
                acc[q.LVL][q.QUESTION_VERSION_SID] = {}
            }
            if (!acc[q.LVL][q.QUESTION_VERSION_SID][q.COND_QUESTION_VERSION_SID]) {
                acc[q.LVL][q.QUESTION_VERSION_SID][q.COND_QUESTION_VERSION_SID] = []
            }
                acc[q.LVL][q.QUESTION_VERSION_SID][q.COND_QUESTION_VERSION_SID].push({
                    LOV_SID: q.LOV_SID,
                    COND_SID: q.COND_SID})

            return acc
        }, {})

        return ret
    }

    /**********************************************************************************************
     * @method getConditionalQuestions
     *********************************************************************************************/
    public async getConditionalQuestions() {
            const dbCondAttrs = await this.dbService.getConditionalQuestions()
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.getConditionalQuestions'
                    throw err})
            this._conditionalAttributes = dbCondAttrs.reduce((acc, q) => {
                if (!acc[q.QUESTION_VERSION_SID]) {
                    acc[q.QUESTION_VERSION_SID] = {}
                }
                if (!acc[q.QUESTION_VERSION_SID][q.COND_QUESTION_VERSION_SID]) {
                    acc[q.QUESTION_VERSION_SID][q.COND_QUESTION_VERSION_SID] = []
                }

                acc[q.QUESTION_VERSION_SID][q.COND_QUESTION_VERSION_SID].push(
                    {COND_SID: q.COND_SID, LOV_SID: q.LOV_SID}
                    )

                return acc
            }, {})
            return this._conditionalAttributes
    }

    /**********************************************************************************************
     * @method questionInfo
     *********************************************************************************************/
    public async questionInfo(
        questionVersionSid: number
    ) {
        // if (!this._questions[attrSid]) {
            await this.getQuestions()
        // }

        return this._questions[questionVersionSid]
    }

    /**********************************************************************************************
     * @method questionType
     *********************************************************************************************/
    public async questionType(
        questionTypeSid: number
    ) {
        if (!this._questionTypeAccessors[questionTypeSid]) {await this.getQuestionTypeAccessors()}

        return this._questionTypeAccessors[questionTypeSid]
    }

    /**********************************************************************************************
    * @method getQuestion
     *********************************************************************************************/
    public async getQuestion(
        attrSid: number, condSid: number
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        const question = await this.dbService.getQuestion(attrSid, condSid, roundInfo.year).catch(
            (err: IError) => {
                err.method = 'QuestionnaireController.getQuestion'
                throw err
            }
        )
        const empty: IQQuestion = {
            DESCR: '',
            LOV_TYPE_SID: 0,
            MAP_TO_RESP_CHOICES: false,
            MASTER_SID: 0,
            ADD_INFO: false,
            INDEX_ATTR: false,
            MANDATORY: 0,
            HELP_TEXT: '',
            QUESTION_VERSION_SID: 0,
            QUESTION_TYPE_SID: 0,
            COND_SID: -9,
            UPD_ROLES: [],
            refresh: false,
            allowModify: false,
            PERIOD_SID: 0,
            ALWAYS_MODIFY: 0
        }
        if (question.length) {
            const result = question[0]
            if (result?.MANDATORY === 1) {
                result.DESCR = result.DESCR + '*'
            } else {
                result.MANDATORY = 0
            }
            return question[0]
        } else {
            return empty
        }
    }

    /**********************************************************************************************
     * @method getQuestions
     *********************************************************************************************/
    public async getQuestions() {
        const dbQuestions = await this.dbService.getQuestions().catch(
                (err: IError) => {
                    err.method = 'SharedService.getQuestions'
                    throw err
                }
            )

        this._questions = dbQuestions.reduce((acc, q) => {
            acc[q.QUESTION_VERSION_SID] = {type: q.QUESTION_TYPE_SID
                                          ,qstnnr: q.QSTNNR_VERSION_SID
                              }
            return acc
        }, {})

        return this._questions
    }

    /**********************************************************************************************
     * @method getQuestionnaireId
     *********************************************************************************************/
    public async getQuestionnaireId(questionnaireSid: number) {
        await this.getQuestionnaires()
        return this._questionnaireIds[questionnaireSid]
    }

    /**********************************************************************************************
     * @method getQuestionnaires
     *********************************************************************************************/
    public async getQuestionnaires() {
        const questionnaires = await this.menuService.getQuestionnaires().catch(
                (err: IError) => {
                    err.method = 'SharedService.getQuestionnaires'
                    throw err
                }
            )

        this._questionnaireIds = questionnaires.reduce((acc, q) => {
                acc[q.QUESTIONNAIRE_SID] = q.APP_ID
                return acc
            }, {})

        return questionnaires
    }

    /**********************************************************************************************
     * @method getComplianceOptions
     *********************************************************************************************/
         public async getComplianceOptions(
            ruleSid: number, periodSid: number
        ) {
            return await this.dbService.getComplianceOptions(ruleSid, periodSid).catch(
                (err: IError) => {
                    err.method = 'SharedService.getComplianceOptions'
                    throw err
                }
            )
        }

    /**********************************************************************************************
     * @method getComplianceValue
     *********************************************************************************************/
    public async getComplianceValue(
        ruleSid: number, roundSid: number, periodSid: number
    ) {
        const res = await this.dbService.getComplianceValue(ruleSid, roundSid, periodSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getComplianceValue'
                throw err
            }
        )

        if (res[0] !== undefined) {
            return res[0].VALUE
        } else return null

    }

    /**********************************************************************************************
     * @method getQuestionTypeAccessors
     *********************************************************************************************/
    public async getQuestionTypeAccessors() {
        const dbQuestionTypeAccessors = await this.dbService.getQuestionTypeAccessors().catch(
                (err: IError) => {
                    err.method = 'SharedService.getQuestionTypeAccessors'
                    throw err
                }
            )

        this._questionTypeAccessors = dbQuestionTypeAccessors.reduce((acc, q) => {
            acc[q.QUESTION_TYPE_SID] = {mapToRC: q.MAP_TO_RESP_CHOICES
                              , multiple: q.MULTIPLE
                              , accessor: q.ACCESSOR
                              , options: q.OPTIONS}
            return acc
        }, {})

        return this._questionTypeAccessors
    }

    /**********************************************************************************************
     * @method getQuestionnaireSections
     *********************************************************************************************/
    public getQuestionnaireSections(
        qstnnrVersionSid: number
    ) {
        return this.dbService.getQuestionnaireSections(qstnnrVersionSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getQuestionnaireSections'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getQuestionnaireQuestions
     *********************************************************************************************/
    /*
     public getQuestionnaireQuestions(
        qstnnrVersionSid: number
    ) {
        return this.dbService.getQuestionnaireQuestions(qstnnrVersionSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getQuestionnaireQuestions'
                throw err
            }
        )
    }
    */

    /**********************************************************************************************
     * @method getEditSteps
     *********************************************************************************************/
    public async getEditSteps() {

            const editSteps = await this.dbService.getEditSteps().catch(
                (err: IError) => {
                    err.method = 'SharedService.getEditSteps'
                    throw err
                }
            )
            this._editSteps = editSteps.reduce((acc, q) => {
                acc[q.EDIT_STEP_SID] = q
                return acc
            }, {})

            return this._editSteps
    }

    /**********************************************************************************************
    * @method getScoreComments
     *********************************************************************************************/
    public async getScoreComments(
        entryCriteriaSid: number,
        msOnly: number
    ) {
        return this.dbService.getScoreComments(entryCriteriaSid, msOnly).catch(
            (err: IError) => {
                err.method = 'ScoresController.getScoreComments'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getAttributeResponseDetails
     *********************************************************************************************/
    public async getAttributeResponseDetails(
        ruleSid: number, attrSid: number, mode: string, periodSid = 0
    ) {
        return this.dbService.getAttributeResponseDetails(ruleSid, attrSid, mode, periodSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getAttributeResponseDetails'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getTargetEntryConfig
     *********************************************************************************************/
    public async getTargetEntryConfig(
        appId: string
    ) {
        const targetEntryConfig = await this.dbService.getTargetEntryConfig(appId).catch(
            (err: IError) => {
                err.method = 'SharedService.getTargetEntryConfig'
                throw err
            }
        )

        return targetEntryConfig[0]
    }

    /**********************************************************************************************
     * @method getTargetNAYears
     *********************************************************************************************/
    public async getTargetNAYears(
        entrySid: number, attrSid: number
    ) {
        const res = await this.dbService.getTargetNAYears(entrySid, attrSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getTargetNAYears'
                throw err
            }
        )
        return res.map(y => y[0])
    }

    /**********************************************************************************************
     * @method getTargetYears
     *********************************************************************************************/
     public async getTargetYears(
        year: number, appId: string
    ) {
        const targetYears = []
        const targetEntryConfig = await this.getTargetEntryConfig(appId.toUpperCase())
        const startYear = year - targetEntryConfig.YEARS_PREV_COUNT
        const endYear = year + targetEntryConfig.YEARS_FORW_COUNT - 1

        for (let y = startYear; y <= endYear; y++ ) {
            targetYears.push(y)
        }

        return targetYears
    }

    /**********************************************************************************************
     * @method getIndexCalculationStages
     *********************************************************************************************/
    public getIndexCalculationStages(indexSid: number) {
        return this.dbService.getIndexCalculationStages(indexSid).catch(
                (err: IError) => {
                    err.method = 'SharedService.getIndexCalculationStages'
                    throw err
                }
            )
    }

    /**********************************************************************************************
     * @method getHeaderAttributes
     *********************************************************************************************/
    public getHeaderAttributes(
        qstnnrVersionSid: number, flag: string
    ) {

        return this.dbService.getHeaderAttributes(qstnnrVersionSid, flag)
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.getHeaderAttributes'
                    throw err
                }
            )
    }

    /**********************************************************************************************
     * @method getIndexCriteriaScoreTypes
     *********************************************************************************************/
     public getIndexCriteriaScoreTypes(
        indexSid: number
    ) {
        return this.dbService.getIndexCriteriaScoreTypes(indexSid)
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.getIndeCriteriaScoreTypes'
                    throw err
                }
            )
    }

    /**********************************************************************************************
     * @method getEntryRanking
     *********************************************************************************************/
     public async getEntryRanking(
        entrySid: number,
        sectorId: string,
        roundSid: number
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.getEntryRanking(entrySid, sectorId, roundSid, roundInfo.year)
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.getIndeCriteriaScoreTypes'
                    throw err
                }
            )
    }

    /**********************************************************************************************
     * @method clearQuestionValue
     *********************************************************************************************/
    public clearQuestionValue(
        entrySid: number, questionVersionSid: number,
    ) {

        return this.dbService.clearQuestionValue(entrySid, questionVersionSid)
            .catch(
                (err: IError) => {
                    err.method = 'SharedService.clearQuestionValue'
                    throw err
                }
            )
    }

    /**********************************************************************************************
    * @method verifyTargetEntries
     *********************************************************************************************/
    public async verifyTargetEntries(
        appId: string, ruleSid: number, attrSid: number, year: number
    ) {
        const periodSid = await this.getQuestionPeriod(attrSid)
        const values = await this.getAttributeResponseDetails(ruleSid, attrSid, 'Values', periodSid)
        const vYears = values.map(value => value.RESPONSE_SID)
        const targetYears = await this.getTargetYears(year, appId)
        for (const targetYear of targetYears) {
            if (!vYears.includes(targetYear)) {
                return false
            }
        }

        return true
    }

    //////////////////////////////////// SETTERS //////////////////////////////////////////////////

    /**********************************************************************************************
     * @method setIndiceValue
     *********************************************************************************************/
    public async setIndiceValue(
        entrySid: number,
        indexSid: number,
        dimensionSid: number,
        dimensionValue: string,
        roundSid: number,
        countryId: string,
        sectorId?: string
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.setIndiceValue(entrySid, indexSid, dimensionSid, dimensionValue,
            roundSid, roundInfo.year, countryId, sectorId).catch(
            (err: IError) => {
                err.method = 'SharedService.setIndiceValue'
                throw err
            }
        )
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
        countryId: string
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.setIndiceAttrValue(indexSid, entrySid, attrId, attrValue,
            roundSid, roundInfo.year, countryId).catch(
            (err: IError) => {
                err.method = 'SharedService.setIndiceAttrValue'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method setIndiceAttrValue
     *********************************************************************************************/
    public async setIndiceMultiAttrValue(
        indexSid: number,
        entrySid: number,
        attrId: string,
        attrValue: string,
        roundSid: number,
        countryId: string
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.setIndiceMultiAttrValue(indexSid, entrySid, attrId, attrValue,
            roundSid, roundInfo.year, countryId).catch(
            (err: IError) => {
                err.method = 'SharedService.setIndiceMultiAttrValue'
                throw err
            }
        )
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
        countryId: string,
        sector: string
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.setIndiceRankValue(entrySid, indexSid, dimensionSid, dimensionValue,
            roundSid, roundInfo.year, countryId, sector).catch(
            (err: IError) => {
                err.method = 'SharedService.setIndiceRankValue'
                throw err
            }
        )
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
        roundSid: number
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.setIndiceCoverage(entrySid, indexSid, dimensionSid, dimensionValue,
            sectorId, roundSid, roundInfo.year).catch(
            (err: IError) => {
                err.method = 'SharedService.setIndiceCoverage'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method calcAllScores
     *********************************************************************************************/
    public async calcAllScores(
        indexSid: number, roundSid: number, entrySid: number
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        // get all dimensions and their accessors for the index
        const indexCriteriaTypes = await this.getIndexCriteriaScoreTypes(indexSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getIndexCriteriaScoreTypes'
                throw err
            }
        )
        let ret = -5
        for (const criteriaType of indexCriteriaTypes) {
            //check if that dimension has any conditions for calculating the score
            const criteriaConditions = await this.dbService.getCriteriaConditions(criteriaType.CRITERION_SID).catch(
                (err: IError) => {
                    err.method = 'SharedService.getCriteriaConditions'
                    throw err
                }
            )
            //if there are no conditions, calculate the score
            if (criteriaConditions.length === 0) {
                const entryCriteriaScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                                        criteriaType.CRITERION_SID,
                                                        criteriaType.ACCESSOR)                
                //set the score
                ret = await this.setEntryCriterionScore(entrySid,
                                                roundSid,
                                                criteriaType.CRITERION_SID,
                                                1,
                                                entryCriteriaScore,
                                                'AUTOMATIC',
                                                'ECFIN').catch(
                                                    (err: IError) => {
                                                        err.method = 'SharedService.setEntryCriterionScore'
                                                        throw err
                                                    }
                                                )
            } else {
                //check if there are conditions for a criteria that do not depend on a choice
                if (criteriaConditions.filter(critCond => !critCond.CHOICE_SCORE_SID).length ===
                    criteriaConditions.length) {
                        //both conditions should be met
                        const counter = []
                        let score = 0
                        for (const condition of criteriaConditions) {
                            //check every condition
                            const singleCheck = await this.dbService.checkChoiceCondition(entrySid
                                ,condition.COND_QUESTION_VERSION_SID
                                ,condition.CUSTOM_CONDITION
                                ,roundInfo.year).catch(
                                    (err: IError) => {
                                        err.method = 'SharedService.checkChoiceCondition'
                                        throw err
                                    }
                                )
                            if (singleCheck === 1) counter.push(singleCheck)
                        }
                        if (counter.length === criteriaConditions.length) {
                            //calculate score
                            score = await this.dbService.calcEntryCriteriaScore(entrySid,
                                criteriaType.CRITERION_SID,
                                criteriaType.ACCESSOR).catch(
                                    (err: IError) => {
                                        err.method = 'SharedService.calcEntryCriteriaScore2'
                                        throw err
                                    }
                                )
                        }
                        //set the score
                        ret = await this.setEntryCriterionScore(entrySid,
                            roundSid,
                            criteriaType.CRITERION_SID,
                            1,
                            score,
                            'AUTOMATIC',
                            'ECFIN').catch(
                                (err: IError) => {
                                    err.method = 'SharedService.setEntryCriterionScore'
                                    throw err
                                }
                            )
                    } else {
                        //get the choice(s) of the question(s) for that criteria
                    const criteriaChoices  = await this.dbService.getCriteriaChoices(criteriaType.CRITERION_SID, entrySid)

                    //check if the criteriaConditions are met for that choice(s)
                    // should check first which of the criteriaChoices is true(2 cannot be true at the same time)
                    // const crChoiceQuestion = criteriaChoices[0]. 
                    if (criteriaChoices.length === 0) {
                        //set the score, as no data was found
                        ret = await this.setEntryCriterionScore(entrySid,
                            roundSid,
                            criteriaType.CRITERION_SID,
                            1,
                            0,
                            'AUTOMATIC',
                            'ECFIN').catch(
                                (err: IError) => {
                                    err.method = 'SharedService.setEntryCriterionScore'
                                    throw err
                                }
                            )
                    } else {
                        
                        let singleScore = -1
                        let singleCheck = 0
                        // let allFields = 0
                        for (const choice of criteriaChoices) {
                            const totalConditions = criteriaConditions.filter(c => c.CHOICE_SCORE_SID === choice.CHOICE_SCORE_SID)
        
                            
                            //there is only one condition
                            if (totalConditions.length === 1) {
                                if (totalConditions[0].CUSTOM_CONDITION) {
                                    if (totalConditions[0].COND_LOV_SID ) {
                                        if (!totalConditions[0].AND_CHOICE_SCORE_SID || !totalConditions[0].OR_CHOICE_SCORE_SID) {
                                            //check the period of the question
                                            const periodSid = await this.dbService.getQuestionPeriod(
                                                totalConditions[0].COND_QUESTION_VERSION_SID)
                                            //the choice depends on the response
                                            const questType = await this.questionType(
                                                (await this.questionInfo(Number(
                                                    totalConditions[0].COND_QUESTION_VERSION_SID))).type)
                                            const values = (periodSid === 1 || periodSid === 2) ?
                                            await this.getAssessmentValues(entrySid,
                                                totalConditions[0].COND_QUESTION_VERSION_SID,
                                                periodSid, roundSid, questType.accessor) :
                                                await this.getAttributeValues(entrySid,
                                                Number(totalConditions[0].COND_QUESTION_VERSION_SID),
                                                questType.accessor,
                                                true)
                                            //the condition is met
                                            if (values.includes(totalConditions[0].COND_LOV_SID)) singleCheck = 1
                                            if (singleCheck === 1) {
                                                //condition is met, calculate the score
                                                singleScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                                        criteriaType.CRITERION_SID,
                                                        criteriaType.ACCESSOR,
                                                        totalConditions[0].CHOICE_SCORE_SID).catch(
                                                            (err: IError) => {
                                                                err.method = 'SharedService.calcEntryCriteriaScore3'
                                                                throw err
                                                            }
                                                        )
                                            } else {
                                                //condition is not met, the score should be 0
                                                singleScore = 0
                                            }
                                        } else {
                                            //the CUSTOM_CONDITION and/or the cond_question and cond_lov should be met
                                            //check the custom condition, passing question_version = 0
                                            const customCondCheck = await this.dbService.checkChoiceCondition(entrySid
                                                ,0
                                                ,totalConditions[0].CUSTOM_CONDITION
                                                ,roundInfo.year).catch(
                                                    (err: IError) => {
                                                        err.method = 'SharedService.checkChoiceCondition'
                                                        throw err
                                                    }
                                                )
                                            //check the period of the question
                                            const periodSid = await this.dbService.getQuestionPeriod(
                                                totalConditions[0].COND_QUESTION_VERSION_SID)
                                            //the choice depends on the response
                                            const questType = await this.questionType(
                                                (await this.questionInfo(Number(
                                                    totalConditions[0].COND_QUESTION_VERSION_SID))).type)
                                            const values = (periodSid === 1 || periodSid === 2) ?
                                            await this.getAssessmentValues(entrySid,
                                                totalConditions[0].COND_QUESTION_VERSION_SID,
                                                periodSid, roundSid, questType.accessor) :
                                                await this.getAttributeValues(entrySid,
                                                Number(totalConditions[0].COND_QUESTION_VERSION_SID),
                                                questType.accessor,
                                                true)
                                            //the condition is met
                                            if (values.includes(totalConditions[0].COND_LOV_SID)) singleCheck = 1

                    const ctr = criteriaConditions.filter(choice => choice.COND_QUESTION_VERSION_SID === 
                    totalConditions[0].COND_QUESTION_VERSION_SID &&
                    choice.COND_LOV_SID === totalConditions[0].COND_LOV_SID &&
                    choice.CUSTOM_CONDITION === totalConditions[0].CUSTOM_CONDITION)
                    
                                            const andCtr = ctr.filter(c => c.AND_CHOICE_SCORE_SID)
                                            const orCtr = ctr.filter(c => c.OR_CHOICE_SCORE_SID)
                                            if (ctr.length > 1) {
                                                // there are 2 scores for same cfg, 1 score for AND, 1 score for OR
                                                // if AND is fulfilled, calc the score for AND
                                                // if OR is fullfilled and AND is not fullfilled, calc the score for OR
                                                if (singleCheck === 1 || customCondCheck === 1) {
                                                    if (singleCheck === 1 && customCondCheck === 1) {
                                                        singleScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                                            criteriaType.CRITERION_SID,
                                                            criteriaType.ACCESSOR,
                                                            andCtr[0].CHOICE_SCORE_SID).catch(
                                                                (err: IError) => {
                                                                    err.method = 'SharedService.calcEntryCriteriaScore3'
                                                                    throw err
                                                                }
                                                            )
                                                    } else {
                                                        singleScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                                            criteriaType.CRITERION_SID,
                                                            criteriaType.ACCESSOR,
                                                            orCtr[0].CHOICE_SCORE_SID).catch(
                                                                (err: IError) => {
                                                                    err.method = 'SharedService.calcEntryCriteriaScore3'
                                                                    throw err
                                                                }
                                                            )
                                                    }
                                                }

                                            }
                                        }
                                        
                                    } else {
                                        //check condition
                                        singleCheck = await this.dbService.checkChoiceCondition(entrySid
                                            ,totalConditions[0].COND_QUESTION_VERSION_SID
                                            ,totalConditions[0].CUSTOM_CONDITION
                                            ,roundInfo.year).catch(
                                                (err: IError) => {
                                                    err.method = 'SharedService.checkChoiceCondition'
                                                    throw err
                                                }
                                            )
                                        if (singleCheck === 1) {
                                            //condition is met, calculate the score
                                            singleScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                                criteriaType.CRITERION_SID,
                                                criteriaType.ACCESSOR,
                                                totalConditions[0].CHOICE_SCORE_SID).catch(
                                                    (err: IError) => {
                                                        err.method = 'SharedService.calcEntryCriteriaScore3'
                                                        throw err
                                                    }
                                                )
                                        }
                                    }
            
                                    if (singleScore > -1) {
                                        //set the score only if it was calculated
                                        ret = await this.setEntryCriterionScore(entrySid,
                                            roundSid,
                                            criteriaType.CRITERION_SID,
                                            1,
                                            singleScore,
                                            'AUTOMATIC',
                                            'ECFIN').catch(
                                                (err: IError) => {
                                                    err.method = 'SharedService.setEntryCriterionScore'
                                                    throw err
                                                }
                                            )
                                    }
                                    
                                } else {
                                const specialConditions =
                                criteriaConditions.filter(c => c.CHOICE_SCORE_SID === choice.CHOICE_SCORE_SID
                                        || c.AND_CHOICE_SCORE_SID === choice.CHOICE_SCORE_SID ||
                                        c.OR_CHOICE_SCORE_SID === choice.CHOICE_SCORE_SID)
                                if (specialConditions.length > 1) {
                                    const cndMet = []
                                    for (const cnd of specialConditions) {
                                        //check the period of the question
                                        const periodSid = await this.dbService.getQuestionPeriod(
                                            cnd.COND_QUESTION_VERSION_SID)
                                        //the choice depends on the response
                                        const questType = await this.questionType(
                                            (await this.questionInfo(Number(
                                                cnd.COND_QUESTION_VERSION_SID))).type)
                                        const values = (periodSid === 1 || periodSid === 2) ?
                                        await this.getAssessmentValues(entrySid,
                                            cnd.COND_QUESTION_VERSION_SID,
                                            periodSid, roundSid, questType.accessor) :
                                            await this.getAttributeValues(entrySid,
                                            Number(cnd.COND_QUESTION_VERSION_SID),
                                            questType.accessor,
                                            true)
                                        //the condition is met
                                        if (values.includes(cnd.COND_LOV_SID)) cndMet.push(cnd)
                                    }
                                    singleScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                        criteriaType.CRITERION_SID,
                                        criteriaType.ACCESSOR,
                                        cndMet[0].CHOICE_SCORE_SID).catch(
                                            (err: IError) => {
                                                err.method = 'SharedService.calcEntryCriteriaScore3'
                                                throw err
                                            }
                                        )
                                } else {
                                    // criteriaConditions.filter( c => {
                                    //     return criteriaChoices.filter(cc => cc.CHOICE_SCORE_SID === c.CHOICE_SCORE_SID)
                                        
                                    //     .map(cc => cc.CHOICE_SCORE_SID)
                                    // }).filter( (cc, idx) => cc[idx].COND_LOV_SID !== cc[idx-1].COND_LOV_SID)
                                    const periodSid = await this.dbService.getQuestionPeriod(
                                        specialConditions[0].COND_QUESTION_VERSION_SID)
                                    //the choice depends on the response
                                    const questType = await this.questionType(
                                        (await this.questionInfo(Number(
                                            specialConditions[0].COND_QUESTION_VERSION_SID))).type)
                                    const values = (periodSid === 1 || periodSid === 2) ?
                                    await this.getAssessmentValues(entrySid,
                                        specialConditions[0].COND_QUESTION_VERSION_SID,
                                        periodSid, roundSid, questType.accessor) :
                                        await this.getAttributeValues(entrySid,
                                        Number(specialConditions[0].COND_QUESTION_VERSION_SID),
                                        questType.accessor,
                                        true)
                                    //the condition is met
                                    if (values.includes(specialConditions[0].COND_LOV_SID)) singleCheck = 1
                                    if (singleCheck === 1) {
                                        singleScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                            criteriaType.CRITERION_SID,
                                            criteriaType.ACCESSOR,
                                            specialConditions[0].CHOICE_SCORE_SID).catch(
                                                (err: IError) => {
                                                    err.method = 'SharedService.calcEntryCriteriaScore3'
                                                    throw err
                                                }
                                            )
                                    }
                                }
                                 //set the score
                                ret = await this.setEntryCriterionScore(entrySid,
                                    roundSid,
                                    criteriaType.CRITERION_SID,
                                    1,
                                    singleScore,
                                    'AUTOMATIC',
                                    'ECFIN')     
                            }
                                
                                
                            } else if (totalConditions.length !== 0) {
                                if (totalConditions.filter(cond => cond.OR_CHOICE_SCORE_SID || cond.AND_CHOICE_SCORE_SID).length
                                !== 0) {
                                //the number of mandatory conditions depends on OR and AND fields
                                const condCounter = totalConditions.filter(cond => cond.OR_CHOICE_SCORE_SID ||
                                    cond.AND_CHOICE_SCORE_SID)
                                const condMet = []
                                let conditionalScore = 0
                                for (const condition of totalConditions) {
                                    //check condition fulfillment
                                    const conditionCheck = await this.dbService.checkChoiceCondition(entrySid
                                                        ,condition.COND_QUESTION_VERSION_SID
                                                        ,condition.CUSTOM_CONDITION
                                                        ,roundInfo.year).catch(
                                                                        (err: IError) => {
                                                                            err.method = 'SharedService.checkChoiceCondition'
                                                                            throw err
                                                                        }
                                                                    )
                                    if (conditionCheck === 1) condMet.push(condition)
                                }
                                if (condCounter.length <= condMet.length && condCounter.length > 0) {
                                    //conditions met, calculate the score
                                    conditionalScore = await this.dbService.calcEntryCriteriaScore(entrySid,
                                        criteriaType.CRITERION_SID,
                                        criteriaType.ACCESSOR,
                                        condMet[0]).catch(
                                            (err: IError) => {
                                                err.method = 'SharedService.calcEntryCriteriaScore4'
                                                throw err
                                            }
                                        )
                                }
                                //set the score
                                ret = await this.setEntryCriterionScore(entrySid,
                                        roundSid,
                                        criteriaType.CRITERION_SID,
                                        1,
                                        conditionalScore,
                                        'AUTOMATIC',
                                        'ECFIN').catch(
                                            (err: IError) => {
                                                err.method = 'SharedService.setEntryCriterionScore'
                                                throw err
                                            }
                                        )
                                } 
                                
                            } else {
                                // set the score to 0 for the other possibilities
                                ret = await this.setEntryCriterionScore(entrySid,
                                    roundSid,
                                    criteriaType.CRITERION_SID,
                                    1,
                                    0,
                                    'AUTOMATIC',
                                    'ECFIN')
                            }
                            
                        }
                    }
                }
                
            }
        }
        return ret
    }

    /**********************************************************************************************
    * @method addConditions
     *********************************************************************************************/
    public async addConditions(
        attributes: ISectionQuestion[], ruleSid: number, roundSid: number, applyConditions: boolean, periodSid: number
    ) {
        let questions: ISectionQuestion[] = []

        for (const attr of attributes) {
            let period = periodSid
            if (period < 0) {
                period = attr.PERIOD_SID
            }
            attr.COND_SID = await this.isAttributeVisible(
                attr.QUESTION_VERSION_SID, ruleSid, roundSid
            )
            questions.push(attr)
        }

        if (!applyConditions) {return questions}
        questions = questions.filter(el => el.COND_SID !== 1)
        return questions
    }

    /**********************************************************************************************
     * @method setEntryCriterionScore
     *********************************************************************************************/
     public async setEntryCriterionScore(
        entrySid: number, roundSid: number, criterionSid: number, versionSid: number, score: number,
        ldap: string, depart: string
    ) {
        return this.dbService.setEntryCriterionScore(entrySid, roundSid, criterionSid, versionSid, score, ldap, depart)
    }

    /**********************************************************************************************
     * @method sendEmail
     *********************************************************************************************/
    public async sendEmail(
        user: string, indexSid: number, criterionSid: number, entrySid: number
    ) {
        return this.dbService.sendEmail(user, indexSid, criterionSid, entrySid)
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
    ) {
        const ret = await this.dbService.setAttributeValue(
            entrySid,
            questionVersionSid,
            val,
            details,
            accessor
        ).catch(
            (err: IError) => {
                err.method = 'SharedService.setAttributeValue'
                throw err
            }
        )
        return ret
    }

    /**********************************************************************************************
    * @method setAutomaticScores
     *********************************************************************************************/
    public async setAutomaticScores(
        indexSid: number,
        countryId: string,
        roundSid: number,
        user: string,
        department: string,
        recalculateEntries: number[] = []
    ) {
        let ret = 0;
        if (recalculateEntries.length) {
            for (const entrySid of recalculateEntries) {
                ret = await this.calcAllScores(indexSid, roundSid, entrySid)
                if (ret < 0) {break}
            }
        }

        if (ret >= 0) {
        (await this.getIndexCalculationStages(indexSid))
            .slice(0, 2)
            .map(v => v.SCORE_VERSION_SID)
            .forEach(versionSid => this.setCountryIdxCalculationStage(
                indexSid,
                countryId,
                roundSid,
                versionSid,
                '',
                user,
                department
            ))
            //check if indices table exists and if not create it
            const existsIndices = await this.checkIndiceCreation(indexSid, roundSid)
            if (existsIndices > 0) {
                for (const entrySid of recalculateEntries) {
                    ret = await this.calcAllIndices(indexSid, roundSid, entrySid, countryId)
                }
            }
        }
        return ret
    }

    /**********************************************************************************************
    * @method checkIndiceCreation
     *********************************************************************************************/
     public async checkIndiceCreation(
        indexSid: number,
        roundSid: number
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.checkIndiceCreation(indexSid, roundSid, roundInfo.year)
    }

    /**********************************************************************************************
    * @method calcAllIndices
     *********************************************************************************************/
     public async calcAllIndices(
        indexSid: number,
        roundSid: number,
        entrySid: number,
        countryId: string
    ): Promise<number> {
        //define fn for calculating the formulas
        function calcFormula(fn) {
            return new Function('return ' + fn)() === 'NaN' ? 0 : new Function('return ' + fn)();
        }
        const ret = 0
        //check if index has additional attributes
        const addAttributes = await this.dbService.getIndiceAddAttributes(indexSid)
        const addAttrResult: number[] = []

        //if the index has additional attributes, get those attributes first
        for (const attr of addAttributes) {
                //should get all the values corresponding to the question
                const qInfo = await this.questionInfo(Number(attr.ACCESSOR))
                const questType = await this.questionType(qInfo.type)
                const values = await Promise.all(await this.getAttributeValues(
                    entrySid, Number(attr.ACCESSOR), questType.accessor, true))
                //update the value for that attribute in the indice table
                for (const value of values) {
                    const valueId = await this.dbService.getLovId(Number(value))
                    const res = await this.setIndiceMultiAttrValue(indexSid, entrySid,
                    attr.ATTR_ID, valueId, roundSid, countryId).catch(
                        (err: IError) => {
                            err.method = 'SharedService.setIndiceMultiAttrValue'
                            throw err
                        })
                    if (res > 0) addAttrResult.push(1)
                }
                
            
        }
        // if (addAttributes.length !== addAttrResult.length) return -1

        // get Indices configuration
        const allIndicesCfg = await this.dbService.getIndicesCfg(indexSid).catch(
            (err: IError) => {
                err.method = 'IndicesController.getIndicesCfg'
                throw err
            }
        )
        const dbIndicesCfg = allIndicesCfg.filter(cfg => cfg.INDICE_TYPE_SID !== 6)
        const multiIndicesCfg = allIndicesCfg.filter(cfg => cfg.INDICE_TYPE_SID === 6)

        //get the latest scores for that entry
        const entryScores = await this.dbService.getLatestScores(entrySid, indexSid, roundSid).catch(
            (err: IError) => {
                err.method = 'IndicesController.getLatestScores'
                throw err
            }
        )
        
        let result: RegExpExecArray
        for (const cfg of dbIndicesCfg) {
            //if the accessor is CFG_INDEX_CRITERIA calculate those indices first, regex=/CR/gi
            if (cfg.ACCESSOR === 'CFG_INDEX_CRITERIA') {
                const criteriaPositions = []
                const regex=/CR/gi
                //find positions of all the regex
                while ( (result = regex.exec(cfg.CRITERION_VALUE)) ) {
                    criteriaPositions.push(result.index)
                }
                let computedValue = ''
                entryScores.forEach(entryScore => {
                    criteriaPositions.forEach(crPos => {
                        //the number after the regex is the criterion_sid
                        const criterionPos = crPos + 'CR'.length
                        const crNumber = Number(cfg.CRITERION_VALUE.substring(criterionPos, criterionPos + 2))

                        if (crNumber === entryScore.CRITERION_SID) {
                            if (computedValue === '') {
                                //replace the regex and number with the score value of that criterion
                                computedValue = cfg.CRITERION_VALUE.replace('CR'+crNumber, String(entryScore.SCORE))
                            } else (
                                computedValue = computedValue.replace('CR'+crNumber, String(entryScore.SCORE))
                            )
                        }
                    })
                })

                const res = await this.setIndiceValue(entrySid,indexSid, cfg.IND_CRITERION_SID,
                    String(calcFormula(computedValue.length > 0 ? computedValue : 0)), roundSid, countryId)
                if (res < 0) return res

            } 
            for (const cfg of dbIndicesCfg) {
                if (cfg.ACCESSOR === 'FUNCTION_BASED') {
                    if (cfg.CRITERION_VALUE === 'getComplianceBonus') {
                        // get OutputGap value first
                        const ogData = await GridsApi.getIndicatorsForCSV(EApps.DBP, {
                            roundSids: [roundSid],
                            countryIds: [countryId],
                            lineIds: [],
                            calculated: [],
                            ameco: ['1.0.0.0.AVGDGP']
                        })
                        
                        // 4th element is the start year
                        // 5th element is the vector
                        // 1st element is current year
                        
                        const complianceBonus = await this.dbService.getComplianceBonus(countryId, roundSid,
                            Number(ogData[0][3]), String(ogData[0][4]), Number(ogData[0][0]) )
                        const res = await this.setIndiceValue(entrySid, indexSid,
                            cfg.IND_CRITERION_SID, String(complianceBonus), roundSid, countryId)
                        if (res < 0) return res
                    } else if (cfg.CRITERION_VALUE === 'getCoverage') {
                        const coverages = await this.dbService.getCoverages(entrySid)
                        const res = []
                        coverages.forEach(async cov => {
                            const rest = await this.setIndiceCoverage(
                                entrySid, indexSid, cfg.IND_CRITERION_SID, String(cov.COVERAGE), cov.RESPONSE_ID, roundSid
                            )
                            res.push(rest)
                        })
                        if (res.indexOf(-1) >= 0) return -1
                        
                    } else if (cfg.CRITERION_VALUE === 'getComplianceScoring') {
                        const complianceScoring = await this.dbService.getComplianceScoring(entrySid, roundSid)
                        const res = await this.setIndiceValue(entrySid, indexSid, cfg.IND_CRITERION_SID,
                            String(complianceScoring), roundSid, countryId)
                        if (res < 0) return res
                    } else if (cfg.CRITERION_VALUE === 'getRanking') {
                        const coverages = await this.dbService.getCoverages(entrySid)
                        const res = []
                        coverages.forEach(async cov => {
                            const rank = await this.getEntryRanking(
                                entrySid, cov.RESPONSE_ID, roundSid
                            )
                            if (rank >= 1) {
                                const ret = await this.setIndiceValue(entrySid, indexSid, cfg.IND_CRITERION_SID,
                                    String(rank), roundSid, countryId, cov.RESPONSE_ID)
                                res.push(ret)
                            } else {
                                const ret = await this.setIndiceValue(entrySid, indexSid, cfg.IND_CRITERION_SID,
                                    String(1), roundSid, countryId, cov.RESPONSE_ID)
                                res.push(ret)
                            }    
                        })
                        if (res.indexOf(-1) >= 0) return -1
                    } else {
                        const inForce = await this.dbService.isInForce(entrySid)
                        const res = await this.setIndiceValue(entrySid, indexSid, cfg.IND_CRITERION_SID,
                            String(inForce), roundSid, countryId)
                        if (res < -1) return res
                    }
                }
            }
            // for (const cfg of dbIndicesCfg) {
            //     if (cfg.ACCESSOR === 'RANKING2') {
            //         //get already calculated values from the db in order to calculate ranking
            //         const data = (await this.dbService.getIndiceData(indexSid, roundSid, countryId)).reduce( (acc, q) => {
            //             if (q.SECTOR !== null) {
            //             if (!acc[q.SECTOR] ) acc[q.SECTOR] = []
            //             acc[q.SECTOR].push({ENTRY_SID: q.ENTRY_SID, COVERAGE: q.SDIM16, RANK: 0})
            //         }
            //             return acc
            //         }, {})
            //         for (const dKey of Object.keys(data)) {
            //             if (dKey !== null) {
            //                 const arrSort = data[dKey].sort( (a, b) => {
            //                     return a.COVERAGE - b.COVERAGE
            //                 })
            //                 let rank = 1
            //                 for (let i = 0; i < arrSort.length; i++) {
            //                     arrSort[i].RANK = rank 
            //                 const res = await this.dbService.setIndiceRankValue(arrSort[i].ENTRY_SID,
            //                         indexSid, cfg.IND_CRITERION_SID,
            //                         String(rank), roundSid, countryId, dKey)
            //                         rank++
            //                     if (res < 0) return -1
            //                 }
            //             }
                        
            //         }
            //     }
            // }
            for (const cfg of dbIndicesCfg.sort( a => a.INDICE_TYPE_SID)) {
                if (cfg.ACCESSOR === 'CFG_INDICE_CRITERIA') {
                    let sumValue = 0
                    // if the accessor is CFG_INDICE_CRITERIA, calculate the indices based on intermediary calculated values
                    // regex=/SDIM/gi
                    const dimPositions = []
                    const regex=/SDIM/gi
                    //find positions of all the regex
                    while ( (result = regex.exec(cfg.CRITERION_VALUE)) ) {
                        dimPositions.push(result.index)
                    }
                    const data = (await this.getIndiceData(indexSid, roundSid,
                        countryId)).filter(e => e.ENTRY_SID === entrySid)
                        
                        data.forEach(async dataEntry => {
                            let computedValue = cfg.CRITERION_VALUE
                            dimPositions.forEach(async dimPos => {
                                //the number after the regex is the ind_criterion_sid(dimension_sid)
                                const dimensionPos  = dimPos + 'SDIM'.length
                                const dimNumber = Number(cfg.CRITERION_VALUE.substring(dimensionPos, dimensionPos + 2))
                                
                                    for (const [k, v] of Object.entries(dataEntry)) {
                                        if (k === 'SDIM'+dimNumber) {
                                            //replace the regex and number with the intermediate value of the dimension
                                        computedValue = computedValue.replace(k, v)
                                        }
                                    }
                                
                                
                            })
                            sumValue = calcFormula(computedValue)
                            const res = await this.setIndiceValue(entrySid, indexSid, cfg.IND_CRITERION_SID,
                                String(sumValue), roundSid, countryId, dataEntry.SECTOR)
                            if (res < -1) return -1
                        })
                            
                }
             }
             for (const cfg of dbIndicesCfg) {
                if (cfg.ACCESSOR === 'RANKING') {
                    //get already calculated values from the db in order to calculate ranking
                    const data = (await this.getIndiceData(indexSid, roundSid, countryId)).reduce( (acc, q) => {
                        if (q.SECTOR !== null) {
                        if (!acc[q.SECTOR] ) acc[q.SECTOR] = []
                        acc[q.SECTOR].push({ENTRY_SID: q.ENTRY_SID, RANK_CR: q.SDIM9, COVERAGE: q.SDIM7, RANK: 0})
                    }
                        return acc
                    }, {})
                    for (const dKey of Object.keys(data)) {
                        if (dKey !== null) {
                            const arrSort = data[dKey].sort( (a, b) => {
                                return (b.RANK_CR * b.COVERAGE * 10) - (a.RANK_CR * a.COVERAGE * 10)
                            })
                            let rank = 1
                            for (let i = 0; i < arrSort.length; i++) {
                                arrSort[i].RANK = rank 
                            const res = await this.setIndiceRankValue(arrSort[i].ENTRY_SID,
                                indexSid, cfg.IND_CRITERION_SID,
                                    String(rank), roundSid, countryId, dKey)
                                    rank++
                                if (res < -1) return -1
                            }
                        }
                        
                    }
                }
            }
                
            for (const cfg of dbIndicesCfg) {
                if (cfg.ACCESSOR === 'FINAL') {
                    let computedValue = cfg.CRITERION_VALUE
                    // if the accessor is CFG_INDICE_CRITERIA, calculate the indices based on intermediary calculated values
                    // regex=/SDIM/gi
                    const dimPositions = []
                    const regex=/SDIM/gi
                    //find positions of all the regex
                    while ( (result = regex.exec(cfg.CRITERION_VALUE)) ) {
                        dimPositions.push(result.index)
                    }
                    const data = await this.getIndiceData(indexSid, roundSid, countryId)
                    data.forEach(async indiceEntry => {
                        dimPositions.forEach(dimPos => {
                            //the number after the regex is the ind_criterion_sid(dimension_sid)
                            const dimensionPos  = dimPos + 'SDIM'.length
                            const dimNumber = Number(cfg.CRITERION_VALUE.substring(dimensionPos, dimensionPos + 2))
                            for (const [k, v] of Object.entries(indiceEntry)) {
                                if (k === 'SDIM'+dimNumber) {
                                    //replace the regex and number with the intermediate value of the dimension
                                computedValue = computedValue.replace(k, v)
                                }
                            }
                        })
                        const res = await this.setIndiceValue(entrySid, indexSid, cfg.IND_CRITERION_SID,
                            String(calcFormula(computedValue)), roundSid, countryId, indiceEntry.SECTOR )
                        if (res < -1) return -1
                    })
                }
            }
        }

        for (const cfg of multiIndicesCfg) {
            // regex=/SDIM/gi
            const dimPositions = []
            const regex=/SDIM/gi
            //find positions of all the regex
            while ( (result = regex.exec(cfg.CRITERION_VALUE)) ) {
                dimPositions.push(result.index)
            }
            let sum = 0
            
            const data = await this.getIndiceData(indexSid, roundSid, countryId)
            data.filter(e => e.ENTRY_SID !== 0).forEach(indiceEntry => {
                let computedValue = cfg.CRITERION_VALUE
                dimPositions.forEach(dimPos => {
                    //the number after the regex is the ind_criterion_sid(dimension_sid)
                    const dimensionPos  = dimPos + 'SDIM'.length
                    const dimNumber = Number(cfg.CRITERION_VALUE.substring(dimensionPos, dimensionPos + 2))
                    for (const [k, v] of Object.entries(indiceEntry)) {
                        if (k === 'SDIM'+dimNumber ) {
                            //replace the regex and number with the intermediate value of the dimension
                            computedValue = computedValue.replace(k, v)
                        }
                    }
                })

                sum = Number(sum) + Number(eval(computedValue))
            })
            const res = await this.setIndiceValue(0, indexSid, cfg.IND_CRITERION_SID, 
                String(sum), roundSid, countryId, null)
                if (res < -1) return -1
        }
        
        return ret
    }

    /**********************************************************************************************
    * @method getIndiceData
     *********************************************************************************************/
    public async getIndiceData(
        indexSid: number,
        roundSid: number,
        countryId: string        
    ) {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        return this.dbService.getIndiceData(indexSid, roundSid, roundInfo.year, countryId)
    }

    /**********************************************************************************************
    * @method getIndiceEntryData
     *********************************************************************************************/
    public async getIndiceEntryData(
        indexSid: number,
        year: number,
        countryId: string
    ) {
        return this.dbService.getIndiceEntryData(indexSid, year, countryId)
    }

    /**********************************************************************************************
    * @method setCountryIdxCalculationStage
     *********************************************************************************************/
    public setCountryIdxCalculationStage(
        indexSid: number, countryId: string, roundSid: number, versionSid: number,
        iteration: string, user: string, organisation: string
    ) {
        return this.dbService.setCountryIdxCalculationStage(
            indexSid,
            countryId,
            roundSid,
            versionSid,
            iteration,
            user,
            organisation
        ).catch(
            (err: IError) => {
                err.method = 'SharedService.setCountryIdxCalculationStage'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method isAttributeInHeader
     *********************************************************************************************/
    public async isAttributeInHeader(
        attrSid: number, questionnaireSid: number
    ) {
        const headerAttrs = await this.getHeaderAttributes(questionnaireSid, 'questionnaire')

        const res = headerAttrs.find(attr => {
            return attr.QUESTION_VERSION_SID === attrSid
        })

        return res ? true : false
    }

    /**********************************************************************************************
    * @method getDependentAttributes
     *********************************************************************************************/
    public getDependentAttributes(
        attrSid: number
    ) {
        return this.dbService.getDependentAttributes(attrSid).catch(
            (err: IError) => {
                err.method = 'SharedService.getDependentAttributes'
                throw err
            }
        )

    }

    /**********************************************************************************************
     * @method getAssessmentResponseDetails
     *********************************************************************************************/
     public getAssessmentResponseDetails(
        ruleSid: number, attrSid: number, periodSid: number, roundSid: number
    ) {
        return this.dbService.getAssessmentResponseDetails(ruleSid, attrSid, periodSid, roundSid).catch(
            (err: IError) => {
                err.method = 'EntriesController.getAssessmentResponseDetails'
                throw err
            }
        )
    }

    /**********************************************************************************************
    * @method getResponseChoices
     *********************************************************************************************/
    public async getResponseChoices(grouped = false) {
        if (Object.keys(this._responseChoices.single).length !== 0 ||
        Object.keys(this._responseChoices.grouped).length !== 0) {
            if (grouped) {
                return this._responseChoices.grouped
            } else {return this._responseChoices.single}
        }

        const query = await this.dbService.getResponseChoices().catch(
            (err: IError) => {
                err.method = 'SharedService.getResponseChoices'
                throw err
            }
        )
        const ret = {single: {}, grouped: {}}
        query.forEach(row => {
            ret.single[row.RESPONSE_SID] = {
                id: row.RESPONSE_ID,
                descr: row.DESCR,
                group_sid: row.RESPONSE_GROUP_SID,
                needsDetails: row.PROVIDE_DETAILS
            }
            if (!ret.grouped[row.RESPONSE_GROUP_SID]) {
                ret.grouped[row.RESPONSE_GROUP_SID] = []
            }
            const resp = {
                sid: row.RESPONSE_SID,
                descr: row.DESCR,
                needsDetails: row.PROVIDE_DETAILS,
                respType: row.RESPONSE_TYPE_SID,
                helpText: row.HELP_TEXT,
                choiceLimit: row.CHOICE_LIMIT,
                detailsText: row.DETS_TXT,
                infoIcon: row.INFO_ICON,
                infoTxt: row.INFO_TXT
            }
            ret.grouped[row.RESPONSE_GROUP_SID].push(resp)
        })
        if (grouped) {
            return ret.grouped
        } else {
            return ret.single
        }
    }

    /**********************************************************************************************
    * @method getDisagreedCriteria
     *********************************************************************************************/
    public getDisagreedCriteria(
        ruleSid: number, roundSid: number, versionSid: number, indexSid: number, countryId: string
    ) {
        return this.dbService.getDisagreedCriteria(ruleSid, roundSid, versionSid, indexSid, countryId).catch(
            (err: IError) => {
                err.method = 'SharedService.getDisagreedCriteria'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
