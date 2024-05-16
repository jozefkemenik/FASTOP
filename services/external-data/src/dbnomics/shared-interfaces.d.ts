export interface INomicsProvider {
    code: string
    name: string
    region: string
    website: string
    termsOfUse: string
    indexedAt: Date
}

export interface INomicsTreeItem {
    code: string
    name: string
    children?: INomicsTreeItem[]
}

export interface IDict {
    [key: string]: string
}

export type IDictArray = Array<[string, string]>

export interface IDictCollection {
    [key: string]: IDict
}

export interface INomicsDimension {
    id: string
    name: string
    dict: IDict | IDictArray
    isFreq: boolean
}

export interface INomicsDataset {
    code: string
    name: string
    providerCode: string
    providerName: string
    dimensions: INomicsDimension[]
}

export type ObservationValue = string | number

export interface INomicsSeriesData {
    code: string
    name: string
    indexedAt: Date
    dimensions: string[]
    values: ObservationValue[]
}

export interface INomicsDatasetSeries {
    dataset: INomicsDataset
    periods: string[]
    series: INomicsSeriesData[]
    limit: number
    num_found: number
    offset?: number
}

export interface INomicsSerie {
    code: string
    name: string
}
