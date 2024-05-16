export interface IEerIndicatorData {
    indicatorId: string
    geoGroupId?: string
    countryId: string
    startYear: number
    timeserie: number[]
}

export interface IEerMatrixData {
    geoGroupId?: string
    expCtyId: string
    impCtyId: string
    year: number
    value: number
}

export interface IEerProviderIndicatorData {
    [periodicityId: string]: IEerIndicatorData[]
}

export interface IEerCountry {
    COUNTRY_ID: string
    DESCR: string
    ORDER_BY: number
}

export interface IEerGeoGroup {
    geoGrpId: string
    descr: string
    alias: string
    isActive: number
    isDefault: number
}

export interface IEerIndicatorDataUpload {
    indicatorId: string
    periodicityId: string
    geoGrpId?: string
    startYear: number
    countries: string[]
    timeseries: string[]
}

export interface IEerMatrixDataUpload {
    geoGrpId?: string
    year: number
    exporters: string[]
    importers: string[]
    values: string[]
}

export interface IEerMatrixUploadResult {
    [year: number]: number
}

export interface IPublicationWeightData {
    geoGroupAlias?: string
    expCtyId: string
    impCtyId: string
    year: number
    value: number
}

export interface IPublicationEertData {
    geoGroupAlias?: string
    countryId: string
    startYear: number
    timeserie: number[]
    periodicityId: string
    providerId: string
}

export interface IXlsxFile {
    name: string
    sheets: IXlsxSheet[]
}

export interface ICsvFile {
    name: string
    header: string
    rows: string[]
}

export interface IXlsxValue {
    t: 'n' | 's' // type, n - numeric, s - string (SheetJS standard)
    v?: string | number // value
    f?: string // formula
}

export interface IXlsxRow {
    [key: string]: IXlsxValue
}

export interface IXlsxSheet {
    name: string
    header: string[]
    rows: IXlsxRow[]
}

export const enum EerProviders {
    EXCHANGE_RATE = 'EXCHANGE_RATE',
    DEFLATOR_HICP = 'DEFLATOR_HICP',
    DEFLATOR_GDP = 'DEFLATOR_GDP',
    DEFLATOR_XPI = 'DEFLATOR_XPI',
    DEFLATOR_ULC = 'DEFLATOR_ULC',
    WEIGHTS = 'WEIGHTS',
    WEIGHTS_RESULT = 'WEIGHTS_RSLT',
    NEER = 'NEER',
    REER = 'REER', // groups all REER_<Deflator> providers
    REER_HICP = 'REER_HICP',
    REER_GDP = 'REER_GDP',
    REER_XPI = 'REER_XPI',
    REER_ULC = 'REER_ULC',
}

