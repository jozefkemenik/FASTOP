import {
    IDetailedTable,
    IIndicator, IIndicatorCodeMapping, IIndicatorData,
    IIndicatorDataWithoutTimeserie,
    IIndicatorReport,
    IIndicatorScale,
    IProvider, RawValue,
} from './shared-interfaces'

export type IDBDetailedTable = IDetailedTable
export type IDBProvider = IProvider

export interface IDBTableCol {
    COL_TYPE_ID: string
    DESCR: string
    YEAR_VALUE: number
    QUARTER: number
    USE_CTY_SCALE: number
}

export interface IDBTableIndicator {
    PERIODICITY_ID: string
    INDICATOR_ID: string
}

export interface IDBTableLine {
    LINE_TYPE_ID: string
    LINE_ID: string
    DESCR: string
    ESA_CODE: string
    LINE_SPAN: number
    COL_TYPE_SPAN: string
    SPAN_YEARS_OFFSET: number
    DATA: string
    ALT_DATA: string
    ALT2_DATA: string
    USE_CTY_SCALE: number
    STYLES: string
}

export interface ICtyScale {
    id: string
    name: string
    exponent: number
}

export interface IDBIndicatorData extends IIndicatorDataWithoutTimeserie {
    TIMESERIE_DATA: string
    DATA_TYPE?: string
}

export type IDBIndicatorReport = IIndicatorReport
export type IDBIndicatorScale = IIndicatorScale
export type IDBIndicator = IIndicator
export type IDBIndicatorCodeMapping = IIndicatorCodeMapping

export const enum ProviderDataLocation {
    INDICATOR_DATA = 'FDMS_INDICATOR_DATA',
    TCE_RESULTS_DATA = 'FDMS_TCE_RESULTS',
}

export interface ITempValues {
    set: Set<RawValue>
    reverse: Map<RawValue, number>
}

export interface ITempDictionary {
    [index: number]: ITempValues
}

export interface IBudgIndicator {
    startYear: number
    endYear: number
    data: {[cty: string]: IIndicatorData}
}

export type INumericString = string | number
