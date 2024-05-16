import { Query } from 'express-serve-static-core'

import { ICurrentRoundInfo } from '../../../dashboard/src/config/shared-interfaces'

export interface IWQIndicator {
    indicatorId: string
    descr: string
    vector: number[]
}

export interface IWQImpactIndicators extends IWQIndicator {
    aggregationType: string                   
    country: string
    countryId: string
    isTotalImpact: boolean
    isOneOff: boolean
    isEuFunded: boolean
    isExpenditure: boolean
}

export interface IWQIndicators {
    countryId: string
    scale: string
    startYear: number
    yearsCount: number
    indicators: IWQIndicator[]
}

export interface IWQCountryIndicator {
    indicatorId: string
    scale: string
    countryId: string
    vector: number[]
    updateDate?: Date
    dataType?: string
    name?: string
    countryDesc?: string
}

export interface IWQCountryIndicators {
    startYear: number
    vectorLength: number
    indicators: IWQCountryIndicator[]
}

export interface IWQParams {
    countryIds: string[]
    ctyGroup: string
    yearsRange: number[]
    periodicity: string
    providerId?: string
    indicatorIds?: string[]
    roundSid?: number
    storageSid?: number
}

export interface IWQImpactParams {
    aggregationType: string
    countryId?: string
    oneOff?: number
    isEuFunded?: boolean
    euFundedIds?: number[]
    totalImpact?: number
    baseYear?: number
    isLight?: boolean
}

export interface ITplColumn {
    label: string
    field: string
    observation?: boolean
}

export interface ITplData {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    [key: string]: any
}

export interface ITplIndicators {
    columns: ITplColumn[]
    data: ITplData[]
}

export interface IVector {
    data: string[]
    indicatorId: string
    countryId: string
}

export interface ITransformation {
    type: TransformationType
    params: ITTConvertParams | ITTDoubleParams | string
}

export interface ITTConvertParams {
    inputPeriodicity: string
    outputPeriodicity: string
}

export interface ITTDoubleParams {
    serieA: string
    serieB: string
}

export const enum TransformationType {
    CONVERT= 'convert',
    ADD = 'add',
    MINUS = 'minus',
    PCT = 'pct',
}

export interface IWQInputParams {
    countries?: string[]
    countryGroup?: string
    periodicity: string
    indicators: string[]
    yearRange: number[]
    nullValue: string
    showRound: boolean
    showUpdated: boolean
    transformation?: ITransformation
    customColumns?: ITplColumn[]
    json?: boolean
    roundSid?: number
    storageSid?: number
    sortYearsDesc?: boolean
    showFullCode?: boolean
    showScale: boolean
    legendPosition: number
    transpose?: boolean

    query: Query
}

export interface IWQRequestParams extends IWQInputParams {
    ctyGroupCountries?: string[]
    roundInfo?: ICurrentRoundInfo
}

export interface IWQTplLegend {
    name: string
    value: string
}
