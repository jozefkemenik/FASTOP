import {
    IDeskUploadDataWithoutVector,
    IDeskUserUpload,
    IFdmsIndicator,
    IFdmsIndicatorMapping,
    IFdmsScale,
    IProviderUpload
} from './shared-interfaces'

export * from './shared-interfaces'

export type IDBFdmsIndicator = IFdmsIndicator
export type IDBFdmsScale = IFdmsScale
export type IDBProviderUpload = IProviderUpload
export type IDBFdmsIndicatorMapping = IFdmsIndicatorMapping

export interface IFdmsIndicatorUploadParam {
    countryId: string
    indicatorSids: number[]
    scaleSids: number[]
    startYears: number[]
    timeSeries: string[]
}

export interface IDBDeskUploadData extends IDeskUploadDataWithoutVector {
    TIMESERIE_DATA: string
}

export interface IDBDeskUpload extends IDeskUserUpload {
    annual: IDBDeskUploadData[]
    quarterly: IDBDeskUploadData[]
}

export interface ITceUploadParam {
    matrixSid: number
    expCtyId: string
    expLineNr: number
    prntCtyIds: string[]
    prntColNrs: number[]
    values: string[]
}

export interface IDBIndicatorUploadData extends IDBDeskUploadData {
    COUNTRY_ID: string
    COUNTRY_DESCR: string
    SCALE_DESCR: string
}

export interface IDBIndicatorUpload extends IDeskUserUpload  {
    data: IDBIndicatorUploadData[]
}

export interface IDBCtyIndicatorScale {
    CTY_IND: string
    SCALE_SID: number
}

export interface IDBEerIndicatorData {
    periodicityId: string
    indicatorSid: number
    scaleSid: number
    seriesUnit: string
    countryId: string
    startYear: number
    timeserieData: string
    code: string
}
