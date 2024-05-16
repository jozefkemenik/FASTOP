import { ILabelValue } from '../shared/shared-interfaces'

export interface IIndicatorCode {
    indicator_code_sid: number
    indicator_id: string
    descr: string
    eurostat_code: string
    forecast: number
    ameco_code: number
    ameco_trn: number
    ameco_agg: number
    ameco_unit: number
    ameco_ref: number
}

export interface IIndicator {
    indicator_sid: string
    indicator_id: string
    indicator_descr: string
    periodicity_id: string
    provider_id: string
    provider_descr: string
}

export interface ISearchCriteria {
    indicators: number[]
    providers: number[]
    periodicities: string[]
    forecast?: boolean
}

export interface IDictionary {
    indicators: ILabelValue[]
    providers: ILabelValue[]
    periodicities: ILabelValue[]
}

