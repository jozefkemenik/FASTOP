export interface IIdxCriterion {
    CRITERION_SID: number
    CRITERION_ID: number
    SUB_CRITERION_ID: string
    DESCR: string
    HELP_TEXT: string
    SCORES: number[]
}

export interface IIndex {
    INDEX_SID: number
    INDEX_ID: string
    DESCR?: string
    QUESTIONNAIRE_SID?: number
    IS_ANNUAL?: boolean
}

export interface IEmailParams {
    ENTRY_SID: number
    CRITERION_SID: number
    INDEX_SID: number
}
