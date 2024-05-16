import { ISpi, ISpiMatrix } from '../../../external-data/src/spi/shared-interfaces'

export interface IWQSpi extends ISpi {
    domain: string
    noNomenclatureCode: boolean
    partner: boolean
}

export type IWQMatrixSpi = ISpiMatrix

export interface IWQSpiParams {
    domain: string
    indicator: string
    country: string
    year: string
    start_year: number
    end_year: number
    nomenclature: string
    nomenclature_code: string
    no_nomenclature_code?: string
    destor?: string
    decimal?: PrecisionType
}

export interface IWQMatrixParams {
    country: string
    indicator: string
    industry: string
    product: string
    year: string
    start_year: number
    end_year: number
    decimal?: PrecisionType
}

export enum QueryType {
    DOMAIN = 'domain',
    GEO = 'geo',
    MATRIX = 'matrix',
}

export type PrecisionType = 'None' | 'All' | number
