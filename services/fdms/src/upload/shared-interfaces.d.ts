export interface IIndicatorsidData {
    startYear: number
    indicatorSid: number
    timeSerie: number[]
    scaleSid: number

    // used for copying data into fdms (like eer exchange rates)
    code?: string
    periodicityId?: string
    seriesUnit?: string
}

export interface IIndicatorsidsData {
    indicatorData: IIndicatorsidData[]
}

export type IIndicatorDataUpload = Record<number | string, IIndicatorsidsData>
export type IDataUploadResult = Record<number | string, number> // <indicatorSid: db o_res (number of updated records)>

export interface IFdmsIndicator {
    indicatorSid: number
    indicatorId: string
    periodicityId: string
    indicatorDescr: string
}

export interface IFdmsScale {
    scaleSid: number
    scaleId: string
    descr: string
}

export interface IProviderUpload {
    providerId: string
    providerDescr: string
    lastUpdated: Date
    updatedBy: string
}

export interface IDeskUploadDataWithoutVector {
    INDICATOR_ID: string
    SCALE_ID: string
    START_YEAR: number
}

export interface IDeskUploadData extends IDeskUploadDataWithoutVector {
    timeSerie: number[]
}

export interface IDeskUserUpload {
    user: string
    date: string
}

export interface IDeskUpload extends IDeskUserUpload {
    annual: IDeskUploadData[]
    quarterly: IDeskUploadData[]
}

export interface ITcePartnerUpload {
    prtColNr: number
    prtCtyId: string
    value: string
}

export interface ITceUpload {
    expLineNr: number
    expCtyId: string
    partners: ITcePartnerUpload[]
}

export interface IIndicatorUploadData extends IDeskUploadData {
    COUNTRY_ID: string
    COUNTRY_DESCR: string
    SCALE_DESCR: string
}

export interface IIndicatorUpload extends IDeskUserUpload {
    data: IIndicatorUploadData[]
}

export interface IIndicatorResult {
    annual: IIndicatorUploadData[]
    quarterly?: IIndicatorUploadData[]
}

export interface ICopyFromFDMSStorage {
    countryIds: string[]
    providerIds: string[]
    indicatorIds?: string[]
    roundSid: number
    storageSid: number
}

export interface IFileInfo {
    fileSid: number
    fileName: string
    country: string
    changeDate: Date
    changeUser: string
    providerName: string
}

export interface IFileContent {
    fileName: string
    contentType: string
    content: Buffer
}

export type IFdmsCtyIndicatorScaleMap = Record<string, number> // <ctyId_indicatorSid, scaleSid>

export interface IFdmsIndicatorMapping {
    indicatorSid: number
    indicatorId: string
    scaleSid: number
    sourceCode: string
    sourceDescr: string
}
