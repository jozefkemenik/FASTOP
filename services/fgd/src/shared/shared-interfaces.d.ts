export interface IQuestion {
    type: number
    table: string
    qstnnr: number
}

export interface IQQuestion extends ISectionQuestion {
    LOV_TYPE_SID: number
    MAP_TO_RESP_CHOICES: boolean
    MASTER_SID: number
    ADD_INFO: boolean
    INDEX_ATTR: boolean
    MANDATORY: number
    HELP_TEXT: string
}

export interface ICondResp {
    COND_SID: number
    LOV_SID: number
}

export interface ICondAttr {
    [COND_QUESTION_VERSION_SID: number]: ICondResp
}

export interface IQuestionTypeAccessor {
    mapToRC: number
    multiple: number
    accessor: string
    options: string
}

export interface IQuestionnaire {
    QUESTIONNAIRE_SID: number
    APP_ID: string
    DESCR: string
}

export interface IQuestionnaireQuestions {
    SECTION_SID: number
    SECTION_DESCR: string
    SECT_ORDER_BY: number
    SUB_SECTION_SID?: number
    SUB_SECTION_DESCR?: string
    SUB_SECT_ORDER_BY?: number
    QUESTION_VERSION_SID: number
    QUESTION: string
    QUESTION_ORDER_BY: number
    QUESTION_TYPE_SID: number
    MANDATORY?: number
    ACCESSOR?: string
    ASSESSMENT_PERIOD: number
    RESPONSE_VALUES?: number[]
    CONDITIONAL_QUESTIONS?: any    /* eslint-disable-line @typescript-eslint/no-explicit-any */
    COND_QUESTION_VERSION_SID?: number
    COND_SID?: number
}

export interface IEntry {
    ENTRY_SID: number
    ENTRY_VERSION: number
    COUNTRY_ID: string
    APP_ID: string
    EDIT_STEP_SID: number
    EDIT_STEP_ID: string
    PREV_STEP_ID: string
    LAST_MODIF_DATE: string
    AVAILABILITY?: string
    IS_AMBITIOUS?: boolean
    ENTRY_NUMBER?: number
    DESCR?: string
    IFI_MAIN_ABRV?: string
}

export interface ISectionSubsection {
    SECTION_VERSION_SID: number
    DESCR: string
    SECTION_ID: number
    ASSESSMENT_PERIOD: number
    NO_HELP: number
    INFO_MSG: string
    WORKFLOW_STEPS: number[]
    questions: any[]    /* eslint-disable-line @typescript-eslint/no-explicit-any */
}

export interface IComplianceOption {
    COMPLIANCE_SOURCE_SID: number
    DESCR: string
}

export interface IComplianceValue {
    VALUE: number
}

export interface IIndexCalcStage {
    SCORE_VERSION_SID: number
    DESCR: string
    AUTOMATIC: number
    ITERABLE: number
    MS_SHARED: number
    READ_ONLY: number
}

export interface ISingleRespChoice {
    id: string
    descr: string
    group_sid: number
    needsDetails: number
}

export interface IGroupedRespChoice {
    sid: number
    descr: string
    needsDetails: number
    respType: number
    helpText: string
    detailsText: string
    infoIcon: number
    infoTxt: string
}

export interface IHeaderAttribute {
    QUESTION_VERSION_SID: number
    SHORT: string
    WIDTH: number
    MAPPING_TYPE: string
    MAP_TO_RESP_CHOICES: boolean
    ACCESSOR: string
}

export interface ICriterionQuestion {
    QUESTION_VERSION_SID: number
    QUESTION_TYPE_SID: number
    UPD_ROLES: string
    PERIOD_SID: number
}

export interface ISectionQuestion {
    QUESTION_VERSION_SID: number
    QUESTION_TYPE_SID: number
    COND_SID: number
    UPD_ROLES: string[]
    refresh: boolean
    allowModify: boolean
    PERIOD_SID?: number
    ALWAYS_MODIFY: number
    DESCR?: string
}

export interface IEditStep {
    EDIT_STEP_SID: number
    EDIT_STEP_ID: string
    DESCR: string
}

export interface IEditSteps {
    [key: number]: IEditStep
}

export interface IDisagreedCriterion {
    CRITERION_SID: number
    CRITERIA_NAME: string
}

export interface ISection {
    SECTION_VERSION_SID: number
    SECTION_ID: string
    DESCR: string
    ASSESSMENT_PERIOD: number
    NO_HELP: number
    INFO_MSG: string
    WORKFLOW_STEPS: number[]
}

export interface IResponseDetail {
    RESPONSE_SID: number
    DESCR?: string
    NUMERIC_VALUE?: number
}

export interface IUpdateInfo {
    LDAP_LOGIN: string
    ORGANISATION: string
    DATETIME: string
}

export interface IComment extends IUpdateInfo {
    COMMENT_SID: number
    DESCR: string
}

export interface IScoreDetail {
    SCORE_VERSION_SID: number
    SCORE: number
    LDAP_LOGIN?: string
    ORGANISATION?: string
    DATETIME?: string
    ENTRY_CRITERIA_SID?: number
    comments?: IComment[]

    ACC_LDAP_LOGIN?: string
    ACC_ORGANISATION?: string
    ACC_DATETIME?: string
}

export interface IScore extends IScoreDetail {
    CRITERION_SID: number
}

export interface IColumn {
    COL_NAME: string
    COL_DESCR: string
}

export interface ISectionHdrAttr {
    ATTR_SID: number
    SHORT: string
    WIDTH: number
    MAPPING_TYPE: string
    MAP_TO_RESP_CHOICES: number
}

export interface IIdxCalcStage {
    SCORE_VERSION_SID: number
    DESCR: string
    AUTOMATIC: number
    ITERABLE: number
    MS_SHARED: number
    READ_ONLY: number
}

export interface ICriteriaScoreTypes {
    CRITERION_SID: number
    SCORE_TYPE_SID: number
    ACCESSOR: string
}

export interface ICriteriaConditions extends IChoiceScore {
    COND_QUESTION_VERSION_SID: number
    COND_LOV_SID: number
    CUSTOM_CONDITION: string
    AND_CHOICE_SCORE_SID: number
    OR_CHOICE_SCORE_SID: number
}

export interface IChoiceScore {
    CHOICE_SCORE_SID: number
}

export interface ITargetEntryConfig {
    APP_ID: string
    DEPENDENT_QUESTION: number
    YEARS_PREV_COUNT: number
    YEAR_CURR_ROUND: number
    YEARS_FORW_COUNT: number
}

export const enum EFgdAppId {
    NFR = 'NFR',
    IFI = 'IFI',
    MTBF = 'MTBF',
    GBD = 'GBD',
}

export const enum EQuestionType {
    SINGLE_CHOICE = 1,
    MULTIPLE_CHOICE,
    SINGLE_DROPDOWN,
    MULTIPLE_DROPDOWN,
    FREE_TEXT,
    SINGLE_LINE,
    NUMBER,
    LINKED_ENTRIES,
    NO_ANSWER,
    NUMERICAL_TARGET,
    DATE,
    NO_CHOICE,
    ASSESSMENT_TEXT,
    ASSESSMENT_SINGLE_CHOICE,
    ASSESSMENT_MULTIPLE_CHOICE,
    ASSESSMENT_MULTIPLE_TEXT,
    ASSESSMENT_COMPLIANCE,
}

export interface IIndiceScore {
    CRITERION_SID: number
    SCORE: number
    ENTRY_NO?: number
    ENTRY_VERSION?: number
}

export interface IIndiceDataCfg {
    ENTRY_SID: number
    IND_CRITERION_SID: number
    CRITERION_VALUE: string
    DISPLAY_NAME: string
    ORDER_BY: number
    ENTRY_NO?: number
    ENTRY_VERSION?: number
    SECTOR_SID?: number
}

export interface ICoverage {
    ENTRY_SID: number
    COVERAGE: number
    RESPONSE_ID: string
}

export interface IIndiceDimensions {
    IND_CRITERION_SID: number
    VALUE: string
    DISPLAY_NAME: string
    ORDER_BY: number
}

export interface ILatestScore extends IIndiceScore {
    ENTRY_SID: number
}

export interface IIndiceAddAttribute {
    ACCESSOR: string
    ATTR_ID: string
}

export interface IIndicesData {
    COUNTRY_ID: string
    ENTRY_SID: number
    SECTOR?: string
    SDIM1?: string
    SDIM2?: string
    SDIM3?: string
    SDIM4?: string
    SDIM5?: string
    SDIM6?: string
    SDIM7?: string
    SDIM8?: string
    SDIM9?: string
    SDIM10?: string
    SDIM11?: string
    SDIM12?: string
    SDIM13?: string
    SDIM14?: string
    SDIM15?: string
    SDIM16?: string
    SDIM17?: string
    SDIM18?: string
    SDIM19?: string
    SDIM20?: string
    SDIM21?: string
    SDIM22?: string
    SDIM23?: string
    SDIM24?: string
    SDIM25?: string
    SDIM26?: string
    SDIM27?: string
    SDIM28?: string
    SDIM29?: string
    SDIM30?: string
    SDIM31?: string
    SDIM32?: string
    SDIM33?: string
    SDIM34?: string
    SDIM35?: string
    SDIM36?: string
    SDIM37?: string
    SDIM38?: string
    SDIM39?: string
}