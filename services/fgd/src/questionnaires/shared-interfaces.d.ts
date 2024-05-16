import { ISection, ISectionQuestion, ISectionSubsection } from '../shared/shared-interfaces'

export interface IQuestionnaireIndex {
    INDEX_SID: number
    INDEX_ID: string
    DESCR?: string
    QUESTIONNAIRE_SID?: number
    IS_ANNUAL?: boolean
}

export interface ISubmit {
    STATUS_SID: number
    SUBMIT_DATE: string
}

export interface IInvalidSection extends ISection {
    subsections: ISectionSubsection[]
    questions: ISectionQuestion[]
}

export interface ICompleteRule {
    invalidStep: boolean
    result: number
    invalidSections: IInvalidSection[]
}

export interface IQuestionnaireElement {
    ELEMENT_TYPE_ID: string
    ELEMENT_TEXT: string
    EDIT_STEP_ID: string
}

export interface ICustomHeaderAttr {
    CUSTOM_ATTR_ID: string
    IN_QUESTIONNAIRE?: string
    IN_SCORES?: string
    IN_INDEXES?: string
    WIDTH: number
    ORDER_BY: number
}
