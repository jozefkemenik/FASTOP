import { ISdmxData } from '../../../lib/dist/sdmx/shared-interfaces'

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type IRaw = any

export type IFrequency = 'A' | 'S' | 'Q' | 'M' | 'D' | string

export interface IPeriodInfo {
    regexp: RegExp
    months: number
}

export interface IDatePeriod {
    raw: string // raw input
    freq: IFrequency
    date: Date
}

export enum EProvider {
    EUROSTAT = 'estat',
    ECB = 'ecb',
    BCS = 'bcs',
    ECFIN = 'ecfin',
}

export enum EOutputFormat {
    JSON = 'json',
    SDMX_CSV = 'sdmx-csv',
}

export interface IFpapiParams {
    dataset: string // dataset name
    query: string // query in sdmx format
    startPeriod?: IDatePeriod
    endPeriod?: IDatePeriod
    obsFlags?: boolean // true means that the observation flags should be returned in response
    format: EOutputFormat // output format
}

export type IObservations = IRaw | string | ISdmxData
export type IOutput = IRaw | string
