export interface ICompliance {
    COMPLIANCE_SOURCE_SID: number
    VALUE?: number
    DESCR?: string
}

export interface IComplianceCfg {
    COMPLIANCE_SOURCE_SID: number
    COMPLIANCE_SOURCE_ID: string
    YEAR: number
    APP_SID: number
    PERIOD_SID: number
    ENTRY_TYPE_SID: number
    BUDG_AGG_SID: number
    TARGET_UNIT_SID: number
    COVERAGE_SID: number
    INDICATOR_ID: string
    LINE_ID: string
    IS_LEVEL: number
    YEAR_VALUE: number
}