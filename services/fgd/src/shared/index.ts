export * from './shared-interfaces'
import {
    IComplianceOption,
    IComplianceValue,
    ICriteriaConditions,
    ICriteriaScoreTypes,
    ICriterionQuestion,
    IDisagreedCriterion,
    IHeaderAttribute,
    IIndexCalcStage,
    IIndiceAddAttribute,
    IQQuestion,
    IQuestionnaire,
    ISection,
    ISectionHdrAttr,
    ISectionQuestion,
    ISectionSubsection
} from './shared-interfaces'

export interface IDBQuestion {
    QUESTION_VERSION_SID: number
    QUESTION_TYPE_SID: number
    QSTNNR_VERSION_SID: number
}

export interface IDBConditionalQuestion {
    COND_SID: number
    QUESTION_VERSION_SID: number
    COND_QUESTION_VERSION_SID: number
    LOV_SID: number
}

export interface IDBCondAttrLvl {
    QUESTION_VERSION_SID: number
    COND_SID: number
    COND_QUESTION_VERSION_SID: number
    LOV_SID: number
    LVL: number
}

export interface IDBQuestionTypeAccessor {
    QUESTION_TYPE_SID: number
    MAP_TO_RESP_CHOICES: number
    MULTIPLE: number
    ACCESSOR: string
    OPTIONS: string
}

export interface IDBResponseChoice {
    RESPONSE_SID: number
    RESPONSE_ID: number
    DESCR: string
    RESPONSE_GROUP_SID: number
    RESPONSE_TYPE_SID: number
    HELP_TEXT: string
    PROVIDE_DETAILS: number
    CHOICE_LIMIT: number
    DETS_TXT: string
    INFO_ICON: number
    INFO_TXT: string
}

export interface IDBSection extends ISection {
    SUBSECTIONS?: any[],    /* eslint-disable-line @typescript-eslint/no-explicit-any */
    QUESTIONS?: any[]       /* eslint-disable-line @typescript-eslint/no-explicit-any */
}

export type IDBQuestionnaire = IQuestionnaire
export type IDBSectionQuestion = ISectionQuestion
export type IDBSectionSubsection = ISectionSubsection
export type IDBComplianceOption = IComplianceOption
export type IDBComplianceValue = IComplianceValue
export type IDBIndexCalcStage = IIndexCalcStage
export type IDBHeaderAttribute = IHeaderAttribute
export type IDBCriterionQuestion = ICriterionQuestion
export type IDBDisagreedCriterion = IDisagreedCriterion
export type IDBQQuestion = IQQuestion
export type IDBSectionHdrAttr = ISectionHdrAttr
export type IDBCriteriaScoreTypes = ICriteriaScoreTypes
export type IDBCriteriaConditions = ICriteriaConditions
export type IDBIndiceAddAttribute = IIndiceAddAttribute
