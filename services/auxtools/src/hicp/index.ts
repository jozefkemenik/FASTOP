import { IBaseHicpIndicator, IHicpCountry, IHicpIndexRange } from './shared-interfaces'
import { IFastopPiplineParams } from '../../../lib/dist/mongo/shared-interfaces'

export * from './shared-interfaces'

export interface IDBHicpIndicator extends IBaseHicpIndicator {
    indicatorSid: number
    dataType: string
    startYear: number
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    timeserieData: any
}

export interface IDBHicpCategory {
    CATEGORY_SID: number
    CATEGORY_ID:  string
    DESCR: string
    CHILD_SIDS?: string
    ROOT_INDICATOR_ID?: string
    BASE_INDICATOR_ID?: string
    IS_DEFAULT: number
    INDICATOR_IDS: string
    ORDER_BY?: number
}

export interface IDBHicpIndicatorCode {
    INDICATOR_CODE_SID: number
    INDICATOR_ID: string
    DESCR: string
    PARENTS: string
}

export type IDBHicpIndexRange = IHicpIndexRange

export interface IDBHicpIndicatorData {
    INDICATOR_CODE_SID: number
    START_YEAR: number
    TIMESERIE_DATA: string
    DATA_TYPE: string
}

export type IDBHicpCountry = IHicpCountry

export interface IDBHicpEstat {
    INDICATOR_CODE_SID: number
    INDICATOR_ID: string
    INDICATOR_SID: number
    DESCR: string
    PERIODICITY_ID: string
    DATA_TYPE: string
    EUROSTAT_CODE: string
}

export interface IDBHicpEstatData extends IDBHicpEstat {
    START_YEAR: number
    TIMESERIE_DATA: string
    LAST_UPDATED?: Date
}

export interface IEstatToIndicatorMap {
    [estatCode: string]: IDBHicpEstat
}

export type IDBDataType = 'I' | 'W' | 'T'

export interface IHicpPipelineParams {
    collection: string
    pipelineId: string
    params: IFastopPiplineParams
}

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type IHicpRaw = any
