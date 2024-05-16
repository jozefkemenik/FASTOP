import { OGCalculationSource } from '../../../../../shared-lib/dist/prelib/shared-interfaces/fisc-grids'

export interface IIndicatorValidation {
    hasError: boolean
    indicatorId: string
    indicatorDesc: string
}

export interface IAmecoValidation {
    hasErrors: boolean
    lastUpdated: Date
    indicators: IIndicatorValidation[] // sorted by indicatorId ASC
}

export interface IDBCalculatedIndicator {
    INDICATOR_ID: string
    DESCR: string
    SOURCE: OGCalculationSource
    VECTOR: string
    START_YEAR: number
    ORDER_BY: number
}

export interface ICalculatedIndicator {
    indicator_sid: number
    startYear: number
    vector: string
}

export interface IVectorRange {
    startYear: number
    yearsCount: number
}

export interface IVector {
    startYear: number
    values: string[]
}

export interface ICalcIndicDataParams {
    p_round_sid: number
    p_indicator_sid: number
    p_country_id: string
    p_start_year: number
    p_vector: string
    p_last_change_user: string
    p_source?: string
}

export interface ISemiElasticity {
    VALUE: number
    ROUND_SID: number
    YEAR: number
    DESCR: string 
    PERIOD_DESCR: string
}
