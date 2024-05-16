import { IDict, IDictCollection, ObservationValue } from './shared-interfaces'

export interface IRawProviderDoc {
    code: string
    name: string
    region: string
    website: string
    indexed_at: string
    slug?: string
    terms_of_use: string
}
export interface IRawProvider {
    docs: IRawProviderDoc[]
}

export interface IRawNomicsProvider {
    providers: IRawProvider
}

export interface IRawSerieDoc {
    indexed_at: string
    series_code: string
    series_name: string
    dimensions: IDict
    period: string[]
    value: ObservationValue[]
}

export interface IRawSerie {
    docs: IRawSerieDoc[]
    limit: number
    num_found: number
    offset: number
}

export interface IRawNomicsDataset {
    code: string
    name: string
    provider_code: string
    provider_name :string
    dimensions_codes_order: string[]
    dimensions_labels: IDict
    dimensions_values_labels: IDictCollection
}

export interface IRawDatasetDoc {
    docs: IRawNomicsDataset[]
}

export interface IRawNomicsDatasets {
    datasets: IRawDatasetDoc
}

export interface IRawNomicsSerie {
    series: IRawSerie
    dataset?: IRawNomicsDataset
    datasets?: {[dataset_key: string]: IRawNomicsDataset}
}

export interface IRawNomicsTreeItem {
    code: string
    name: string
    doc_href?: string
    children?: IRawNomicsTreeItem[]
}

export interface IRawNomicsTree {
    provider: IRawProviderDoc
    category_tree: IRawNomicsTreeItem[]
}
