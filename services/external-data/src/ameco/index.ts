import {
    IAmecoChapter,
    IAmecoSdmxData,
    IAmecoSerie,
    IAmecoSeriesData,
} from '../../../lib/dist/ameco/shared-interfaces'
import {
    IAmecoInternalMetadataTree,
    IAmecoMetadataCountry,
    IAmecoMetadataDimension
} from './shared-interfaces'
import { ICountry } from '../../../lib/dist/addin/shared-interfaces'

export interface IDBAmecoData {
    indicator_id: string
    descr: string
    unit: string
    start_year: number
    vector: string
    country_id_iso3: string
    country_id_iso2: string
    country_descr: string
}

export interface IDBForecastPeriod {
    forecast_period: number
}

export type IDBCountry = ICountry
export type IDBAmecoSerie = IAmecoSerie
export type IDBAmecoChapter = IAmecoChapter
export type IDBAmecoSeriesData = IAmecoSeriesData
export type IDBAmecoSdmxData = IAmecoSdmxData
export type IDBAmecoMetadataCountry = IAmecoMetadataCountry
export type IDBAmecoMetadataDimension = IAmecoMetadataDimension
export type IDBAmecoInternalMetadataTree = IAmecoInternalMetadataTree
