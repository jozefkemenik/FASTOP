export interface IHeaderCol {
    header: string
    colSpan?: number
    rowSpan?: number
}

export interface ITableRow {
    values: Array<string|number>
    colSpans?: number[]
    rowType?: string
    styles?: string
    indicators?: string[]
}

export interface ICountryTable {
    header: Array<Array<IHeaderCol>>
    data: ITableRow[]
    dataColumnOffset: number
    tableNumber: string
    title: string
    footer: string
    ogFull?: boolean
}

export interface IDetailedTable {
    TABLE_SID: number
    TABLE_ID: string
    DESCR: string
    FOOTER: string
}

export interface IValidationTable {
    header: Array<string|number>
    data: Array<Array<string|number>>
}

export interface IValidationStepIndicator {
    indicatorId: string
    indicatorName: string
    labels: string[]
    actual: number[]
    validation1: number[]
    validation2: number[]
    failed: boolean[]
}

export interface IProvider {
    PROVIDER_ID: string
    DESCR: string
}

export interface ITcePartnerData {
    ctyId: string
    value: number
}

export interface ITceMatrixData {
    expCtyId: string
    partners: ITcePartnerData[]
}

export interface IIndicatorReport {
    INDICATOR_ID: string
    INDICATOR_DESCR: string
    ORDER_BY: number
}

export interface IIndicatorScale {
    INDICATOR_ID: string
    COUNTRY_ID: string
    SCALE_ID: string
    DESCR: string
    EXPONENT: number
}

export interface IIndicatorDataWithoutTimeserie {
    COUNTRY_ID: string
    INDICATOR_ID: string
    SCALE_ID: string
    START_YEAR: number
    PERIODICITY_ID: string
    COUNTRY_DESCR: string
    SCALE_DESCR: string
    DATA_SOURCE: string
    UPDATE_DATE: Date
}

export interface IIndicatorData extends IIndicatorDataWithoutTimeserie {
    TIMESERIE_DATA: number[]
    DATA_TYPE?: string
}

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type RawValue = any
export type IDBRaw = RawValue[]

export interface ICompressedColumn {
    name: string
    dictionary?: IDBRaw
    timeserie?: boolean
}

export interface ICompressedData {
    columns: ICompressedColumn[]
    data: IDBRaw[]
}

export interface IIndicator {
    INDICATOR_ID: string
    DESCR: string
}

export interface IIndicatorCodeMapping {
    INDICATOR_ID: string
    SOURCE_CODE: string
    SOURCE_DESCR: string
}

export interface IIndicatorTreeNode {
    CODE: string
    DESCR: string
    ORDER_BY: number
    LEVEL: number
    PARENT_CODE?: string
    INDICATOR_ID?: string
}

export interface IXferAmeco {
    countries: string[]
    indicators: string[]
    yearsRange: [number, number]
    data: {[cty: string]: {[indicator: string]: number[]}}
}

export const enum AmecoXferType {
    CF = 'AMECOCF',
    BRICS = 'AMECOBRC'
}

export interface IBudgData {
    country: string
    scale: string
    vector: number[]
}

export interface IBudgReport {
    indicatorId: string
    descr: string
    startYear: number
    endYear: number
    data: IBudgData[]
}
