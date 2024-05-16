import {
    INomicsData,
    INomicsDataset,
    INomicsProvider,
    INomicsSeriesData,
    INomicsTreeItem,
    ObservationValue
} from './shared-interfaces'
import { ILimits } from '.'
import { NomicsService } from './dbnomics.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class NomicsController {

    private static MAX_LIMIT = 3000

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly nomicsService: NomicsService,
    ) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public async getProviders(): Promise<INomicsProvider[]> {
        return this.nomicsService.getProviders()
    }

    /**********************************************************************************************
     * @method getProviderTree
     *********************************************************************************************/
    public async getProviderTree(provider: string): Promise<INomicsTreeItem[]> {
        return this.nomicsService.getProviderTree(provider)
    }

    /**********************************************************************************************
     * @method getDataset
     *********************************************************************************************/
    public async getDataset(provider: string, dataset: string): Promise<INomicsDataset> {
        return this.nomicsService.getDataset(provider, dataset)
    }

    /**********************************************************************************************
     * @method getDataByQuery
     *********************************************************************************************/
    public async getDataByQuery(provider: string, dataset: string, query: string): Promise<INomicsData> {
        const data: INomicsData = await this.nomicsService.getDataByQuery(provider, dataset, query, 100)
        if (!data || data.num_found <= data.limit || data.series.length >= NomicsController.MAX_LIMIT) {
            return data
        }
        const fetchCount = Math.min(data.num_found, NomicsController.MAX_LIMIT) - data.limit
        const numberOfCalls = Math.floor(fetchCount / data.limit)
        const params: ILimits[] = Array.from(
            { length: numberOfCalls }, (_, idx) => ({
                limit: data.limit,
                offset: data.limit * (idx + 1)
            })
        )
        const restCount = fetchCount - (numberOfCalls * data.limit)
        if (restCount > 0) {
            params.push({
                limit: restCount,
                offset: (numberOfCalls + 1) * data.limit
            })
        }

        const results = await Promise.all(
            params.map(param => this.nomicsService.getDataByQuery(
                provider, dataset, query, param.limit, param.offset
            ))
        )
        return this.combineResults([data].concat(results), data.num_found)
    }

    /**********************************************************************************************
     * @method getDataBySeries
     *********************************************************************************************/
    public async getDataBySeries(provider: string, dataset: string, series: string[]): Promise<INomicsData> {
        const chunks = this.getChunks(series, 50)
        const results = await Promise.all(
            chunks.map(series => this.nomicsService.getDataBySeries(
                provider, dataset, series, undefined
            ))
        )

        return this.combineResults(results)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getChunks
     *********************************************************************************************/
    private getChunks(series: string[], chunkSize: number): string[][] {
        const chunks = []
        for (let i = 0; i < series.length; i += chunkSize) {
            chunks.push(series.slice(i, i + chunkSize))
        }
        return chunks
    }

    /**********************************************************************************************
     * @method combineResults
     *********************************************************************************************/
    private combineResults(results: INomicsData[], num_found?: number): INomicsData {
        let combined: INomicsData
        if (results && results.length) {
            const periods = Array.from(
                results.reduce((acc, dataSerie) => (
                    dataSerie.periods.forEach(acc.add, acc), acc
                ), new Set<string>())
            ).sort()
            const periodMap = periods.reduce((acc, period, index) => (acc[period] = index, acc), {})

            const emptyValues = new Array(periods.length).fill(null)
            const series: INomicsSeriesData[] = results.reduce(
                (acc, dataSerie) => (acc.push(...dataSerie.series.map(serie => {
                    const newValues: ObservationValue[] = [].concat(emptyValues)
                    dataSerie.periods.forEach((period, index) => {
                        newValues[periodMap[period]] = serie.values[index]
                    })

                    return Object.assign(serie, { values: newValues })
                })), acc), [])

            combined = {
                dataset: results[0].dataset,
                periods,
                series,
                limit: NomicsController.MAX_LIMIT,
                num_found: num_found || series.length,
            }
        }
        return combined?.num_found > 0 ? combined : undefined
    }

}
