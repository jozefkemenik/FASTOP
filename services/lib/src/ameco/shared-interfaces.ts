// country_index, indicator_sid, unit_index, vector
export type AmecoArrayData = [number, number, number, string]

export interface IAmecoDataDict {
    countries: string[]
    units: string[]
}

export interface IAmecoIndexedData {
    startYear: number
    dict: IAmecoDataDict
    data: AmecoArrayData[]
}

export interface IAmecoSerie {
    SERIE_SID: number
    SERIE_ID: string
    DESCR: string
}

export interface IAmecoChapter {
    SID: number
    CODE: string
    DESCR: string
    LEVEL: number
    NODE_TYPE: string
    ORDER_BY: number
    PARENT_CODE: string
}

export interface IAmecoSeriesData {
    COUNTRY_ID: string
    SERIE_SID: number
    UNIT: string
    TIME_SERIE: string
    START_YEAR: number
}

export interface IAmecoSdmxData {
    GEO: string
    INDICATOR: string
    TRN: string
    AGG: string
    UNIT: string
    REF: string
    TIME_SERIE: string
    START_YEAR: number
}
