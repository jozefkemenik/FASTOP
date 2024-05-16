import {
    IDict,
    IDictArray,
    INomicsDataset,
    INomicsDatasetSeries,
    INomicsProvider,
    INomicsSerie,
    INomicsSeriesData,
    INomicsTreeItem,
} from './shared-interfaces'
import { IRawNomicsDataset, IRawNomicsSerie, IRawNomicsTreeItem } from '.'
import { DbNomicsService } from './dbnomics.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class DbNomicsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    public constructor(private dbnomicsService: DbNomicsService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviders
     *********************************************************************************************/
    public async getProviders(): Promise<INomicsProvider[]> {
        return this.dbnomicsService.getProviders().then(raw => raw.providers.docs.map(data => ({
                code: data.code,
                name: data.name,
                region: data.region,
                website: data.website,
                termsOfUse: data.terms_of_use,
                indexedAt: new Date(data.indexed_at),
            }))
        )
    }

    /**********************************************************************************************
     * @method getProviderTree
     *********************************************************************************************/
    public async getProviderTree(provider: string): Promise<INomicsTreeItem[]> {
        return this.dbnomicsService.getProviderTree(provider).then(raw => this.mapTreeItems(raw.category_tree))
    }

    /**********************************************************************************************
     * @method getDataset
     *********************************************************************************************/
    public async getDataset(provider: string, dataset: string): Promise<INomicsDataset> {
        return this.dbnomicsService.getDataset(provider, dataset).then(
            raw => this.mapDataset(raw.datasets.docs[0])
        )
    }

    /**********************************************************************************************
     * @method getDataByQuery
     *********************************************************************************************/
    public async getDataByQuery(
        provider: string, dataset: string, query: string, limit: number, offset: number,
    ): Promise<INomicsDatasetSeries> {
        return this.dbnomicsService.getDataByQuery(
            provider, dataset, query, limit, offset
        ).then(this.mapSeriesValues.bind(this))
    }

    /**********************************************************************************************
     * @method getSeries
     *********************************************************************************************/
    public async getSeries(
        provider: string, dataset: string, limit: number
    ): Promise<INomicsSerie[]> {
        return this.dbnomicsService.getSeries(provider, dataset, limit).then(this.mapSeries.bind(this))
    }

    /**********************************************************************************************
     * @method getDataBySeries
     *********************************************************************************************/
    public async getDataBySeries(
        provider: string, dataset: string, series: string[], limit: number, offset: number
    ): Promise<INomicsDatasetSeries> {
        return this.dbnomicsService.getDataBySeries(
            provider, dataset, series, limit, offset
        ).then(this.mapSeriesValues.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method mapDataset
     *********************************************************************************************/
    private mapDataset(dataset: IRawNomicsDataset): INomicsDataset {
        return dataset ? {
            code: dataset.code,
            name: dataset.name,
            providerCode: dataset.provider_code,
            providerName: dataset.provider_name,
            dimensions: dataset.dimensions_codes_order.map(dimId => ({
                id: dimId,
                name: dataset.dimensions_labels[dimId],
                dict: this.extractDictionary(dataset.dimensions_values_labels[dimId]),
                isFreq: ['FREQ', 'FREQUENCY'].includes(dimId.toUpperCase())
            }))
        } : undefined
    }

    /**********************************************************************************************
     * @method extractDictionary
     *********************************************************************************************/
    private extractDictionary(raw: IDict | IDictArray): IDict {
        if (!Array.isArray(raw)) return raw as IDict
        // raw is array of arrays, each array has two elements, first is the code, second is the label
        return raw.reduce(
            (acc, [code, label]) => (acc[code] = label, acc), {} as IDict
        )
    }

    /**********************************************************************************************
     * @method mapSeriesValues
     *********************************************************************************************/
    private mapSeriesValues(raw: IRawNomicsSerie): INomicsDatasetSeries {
        if (!raw || (!raw.dataset && !raw.datasets) || !raw.series) return undefined

        const rawDataset = raw.dataset || raw.datasets[Object.keys(raw.datasets)[0]]
        const dataset: INomicsDataset = this.mapDataset(rawDataset)

        const periods = raw.series.docs.reduce(
            (acc, doc) => doc.period.length > acc.length ? doc.period : acc, []
        )
        const series: INomicsSeriesData[] = raw.series.docs.map(doc => ({
            code: doc.series_code,
            name: doc.series_name,
            indexedAt: new Date(doc.indexed_at),
            dimensions: dataset.dimensions.map(dim => doc.dimensions[dim.id]),
            values: doc.value.concat(Array.from({ length: periods.length - doc.period.length}, () => null))
        }))

        return {
            dataset,
            periods,
            series,
            limit: raw.series.limit,
            num_found: raw.series.num_found,
            offset: raw.series.offset,
        }
    }

    /**********************************************************************************************
     * @method mapSeries
     *********************************************************************************************/
    private mapSeries(raw: IRawNomicsSerie): INomicsSerie[] {
        if (!raw || !raw.series) return undefined

        return raw.series.docs.map(doc => ({
            code: doc.series_code,
            name: doc.series_name,
        }))
    }

    /**********************************************************************************************
     * @method mapTreeItems
     *********************************************************************************************/
    private mapTreeItems(rawItems: IRawNomicsTreeItem[]): INomicsTreeItem[] {
        return !rawItems ? undefined : rawItems.map(item => ({
            code: item.code,
            name: item.name,
            children: this.mapTreeItems(item.children)
        }))
    }
}
