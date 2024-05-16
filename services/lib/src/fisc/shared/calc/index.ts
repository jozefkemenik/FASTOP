import { IIndicator } from '..'

export * from './shared-interfaces'

export type IDBIndicator = IIndicator

export interface ICalculatedIndicatorValidation {
    hasError: boolean
    code: string
    line_id: string
    descr: string
}

export interface ILineVector {
    startYear: number
    values: {[year: number]: string}
}

export interface IDBLineData {
    YEAR: number
    YEAR_VALUE: number
    VALUE_N: string
    VALUE_P: string
    VALUE_CD: string
}

export interface IDBGridLine {
    LINE_ID: string
    DESCR: string
    INDICATOR_ID: string
}

export interface ILine {
    lineId: string
    lineDesc: string
}
