export interface ISingleResponseChoice {
    id: string
    descr: string
    group_sid: number
    needsDetails: number
}

export interface SelectItem {
    label?: string
    value: any  /* eslint-disable-line @typescript-eslint/no-explicit-any */
    styleClass?: string
    icon?: string
    title?: string
}

export interface IGroupedResponseChoice {
    sid: number
    id: string
    descr: string
    needsDetails: number
    respType: number
    helpText: string
    detailsText: string
    infoIcon: number
    infoTxt: string
}

export interface IUpdateResult {
    updatedRecords: number
    refreshAttrs: number[]
    refreshHeader: boolean
}

export interface ICreateReform {
    p_ret: number
    o_sid: number
}

export interface IDuplicateEntry {
    p_out_entry_sid: number
    p_ret: number
}

export interface IAbolishEntry {
    p_ret: number
}

export interface IQuestionnaireEntries {
    appId: string
    countryCode: string
    country: string
    year: number
    entryNo: number
    entryVersion: number
    entries: any[]  /* eslint-disable-line @typescript-eslint/no-explicit-any */
}

export interface IPdfChoice {
    sid: number
    descr: string
    needsDetails?: number
    respType?: number
    helpText?: string
    choiceLimit?: number
    institution?: string
    provideDetails?: IPdfProvidedetails[]
    SELECTED?: number
    detailsText?: string
    // infoTxt: string if this info is needed in pdf, a new jira ticket should be requested
}

export interface IPdfColumn {
    image?: string
    width: string | number
    height?: number
    text?: string | number
}

export interface IPdfCompliance {
    complianceSource: string
    complianceValue?: string
}

export interface IPdfNumericalTarget {
    RESPONSE_SID: number
    NUMERIC_VALUE?: number
    NOT_APPLICABLE?: number
}

export interface IPdfLinkedEntry {
    entrySid: number
    linkedEntrySummary: any   /* eslint-disable-line @typescript-eslint/no-explicit-any */
}

export interface IPdfProvidedetails {
    RESPONSE_SID: number
    DESCR: string
    NUMERIC_VALUE?: number
}

export interface IPdfQuestionStack {
    text?: string
    style?: string
    margin: Array<number>
    columns?: IPdfColumn[]
    columnGap?: number
}

export interface IPdfQuestionnaireMetaStack {
    text: string
    style?: string
    tocStyle?: string
    tocMargin?: Array<number>
    margin: Array<number>
}

export const enum EResponseType {
    SINGLE_VALUE = 'SINGLE_VALUE',
    SINGLE_CHOICE = 'SINGLE_CHOICE',
    MULTIPLE_CHOICE = 'MULTIPLE_CHOICE',
    NO_CHOICE = 'NO_CHOICE',
    LINKED_ENTRIES = 'LINKED_ENTRIES',
    NUMERICAL_TARGET = 'NUMERICAL_TARGET',
    ASSESSMENT_COMPLIANCE = 'ASSESSMENT_COMPLIANCE',
}
