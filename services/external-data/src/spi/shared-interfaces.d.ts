export interface ISpiParams {
    domain: string
    indicators: string[]
    countries: string[]
    years: string[]
    startYear: number
    endYear: number
    nomenclature: string
    nomenclatureCodes: string[]
    destor: string[]
}

export interface ISpiData {
    indicator_id: string
    indicator_descr: string
    country_id: string
    partner_id?: string
    nomenclature_id: string
    nomenclature_desc: string
    data: { [year: string]: number }
}

export type IDictionary = {[key: string]: string}

export interface ISpiDictionary {
    countries: IDictionary
}

export interface ISpi {
    years: string[]
    update_date: string
    type_prod: string
    data: ISpiData[]
    dictionary: ISpiDictionary
}

export interface ISpiMatrixDictionary {
    industries: IDictionary
    products: IDictionary
}

export interface ISpiMatrixData {
    country_id: string
    year: number
    product: string
    values: { [industry: string]: number }
}

export interface ISpiMatrix {
    industries: string[]
    update_date: string
    data: ISpiMatrixData[]
    dictionary: ISpiMatrixDictionary
}

export interface ISpiMatrixParams {
    countries: string[]
    indicator: string
    industries: string[]
    products: string[]
    years: string[]
    startYear: number
    endYear: number
}
