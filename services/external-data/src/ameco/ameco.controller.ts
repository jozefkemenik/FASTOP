import {
    IAmecoData,
    IAmecoInternalMetadataTree,
    IAmecoLastUpdate,
    IAmecoMetadataCountry,
    IAmecoMetadataDimension
} from './shared-interfaces'
import { IDBAmecoChapter, IDBAmecoData, IDBAmecoSdmxData, IDBAmecoSerie, IDBAmecoSeriesData, IDBCountry } from '.'
import { ISdmxData, SdmxProvider } from '../../../lib/dist/sdmx/shared-interfaces'
import { AmecoInternalService } from './ameco-internal.service'
import { AmecoOnlineService } from './ameco-online.service'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { BaseAmecoService } from './base-ameco-service'
import { IAmecoStats } from 'stats'
import { SdmxApi } from '../../../lib/dist/api/sdmx.api'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class AmecoController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private amecoInternalService: AmecoInternalService,
        private amecoOnlineService: AmecoOnlineService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoData
     *********************************************************************************************/
    public async getAmecoData(
        amecoType: AmecoType, indicators: string[], countryIds: string[],
        defaultCountries?: boolean
    ): Promise<IAmecoData[]> {
        const data: IDBAmecoData[] = await this.getAmecoFullData(amecoType, indicators, countryIds, defaultCountries)

        return data.map(d => ({
            indicatorId: d.indicator_id,
            countryIdIso3: d.country_id_iso3,
            countryIdIso2: d.country_id_iso2,
            countryDesc: d.country_descr,
            name: d.descr,
            scale: d.unit,
            startYear: d.start_year,
            vector: d.vector ? d.vector.split(',').map(Number) : []
        }))
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(amecoType: AmecoType): Promise<IDBCountry[]> {
        return this.getAmecoService(amecoType).getCountries()
    }

    /**********************************************************************************************
     * @method getSeries
     *********************************************************************************************/
    public async getSeries(amecoType: AmecoType): Promise<IDBAmecoSerie[]> {
        return this.getAmecoService(amecoType).getNomSeries()
    }

    /**********************************************************************************************
     * @method getChapters
     *********************************************************************************************/
    public async getChapters(amecoType: AmecoType): Promise<IDBAmecoChapter[]> {
        return this.getAmecoService(amecoType).getChapters()
    }

    /**********************************************************************************************
     * @method getSeriesData
     *********************************************************************************************/
    public async getSeriesData(
        amecoType: AmecoType, countries: string, series: string,
    ): Promise<IDBAmecoSeriesData[]> {
        switch (amecoType) {
            case AmecoType.ONLINE: return this.amecoOnlineService.getSeriesData(countries, series)
            case AmecoType.CURRENT: return this.amecoInternalService.getCurrentSeriesData(countries, series)
            case AmecoType.PUBLIC: return this.amecoInternalService.getPublicSeriesData(countries, series)
            case AmecoType.RESTRICTED: return this.amecoInternalService.getRestrictedSeriesData(countries, series)
            default: return this.notAvailable()
        }
    }

    /**********************************************************************************************
     * @method getSdmxData
     *********************************************************************************************/
    public async getSdmxData(
        dataset: string, queryKey: string, startPeriod?: string, endPeriod?: string
    ): Promise<ISdmxData> {
        this.checkDataset(dataset)

        const parseDim = (v: string) => !v || v.trim() === '' ? null :
                                                               (v.includes('+') ? v.split('+') :
                                                                                  v.split(','))

        const names = dataset.toUpperCase() === 'AMECO' ?
            await SdmxApi.getDatasetStructure(SdmxProvider.ECFIN, dataset).then(
                struct => struct.dimensions.map(dim => dim.id)
            ) : ['GEO', 'INDICATOR', 'TRN', 'AGG', 'UNIT', 'REF', 'FREQ']

        // eslint-disable-next-line @typescript-eslint/no-unused-vars
        const [countries, codes, trns, aggs, units, refs, ...rest] = queryKey.split('.')
                                                                             .map(parseDim)

        const seriesData: IDBAmecoSdmxData[] = await this.getAmecoSdmxData(dataset, countries, codes, trns, aggs, units, refs)
        const startPeriodNumber = Number(startPeriod)
        const startYear = !isNaN(startPeriodNumber) ? startPeriodNumber : 0
        const endPeriodNumber = Number(endPeriod)
        const endYear = !isNaN(endPeriodNumber) ? endPeriodNumber : Number.MAX_VALUE

        const freq = 'A'
        return {
            names,
            labels: null,
            data: seriesData.map(serie => {
                const vector = serie.TIME_SERIE.split(',')
                return {
                    index: names.map(name => name !== 'FREQ' ? serie[name] : freq),
                    item: Array.from({ length: vector.length }, (_, index) => serie.START_YEAR + index)
                        .reduce((acc, year, index) => {
                            if (year >= startYear && year <= endYear) acc[year] = vector[index]
                            return acc
                        }, {})
                }
            })
        }
    }

    /**********************************************************************************************
     * @method getLastUpdate
     *********************************************************************************************/
    public async getLastUpdate(amecoType: AmecoType): Promise<IAmecoLastUpdate> {
        return this.getAmecoService(amecoType).getLastUpdate()
    }

    /**********************************************************************************************
     * @method isAmecoInternalForecastPeriod
     *********************************************************************************************/
    public async isAmecoInternalForecastPeriod(): Promise<boolean> {
        return this.amecoInternalService.isForecastPeriod()
    }

    /**********************************************************************************************
     * @method logStats
     *********************************************************************************************/
    public async logStats(stats: IAmecoStats): Promise<number> {
        if (stats.amecoType === AmecoType.ONLINE) {
            return this.amecoOnlineService.logStats(
                stats.userId, stats.agent, stats.addr, stats.uri, stats.source,
            )
        } else {
            return this.amecoInternalService.logStats(
                stats.userId, stats.source, stats.addr, this.getStatsType(stats.amecoType), stats.uri
            )
        }
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataCountries
     *********************************************************************************************/
    public async getAmecoInternalMetadataCountries(): Promise<IAmecoMetadataCountry[]> {
        return this.amecoInternalService.getMetadataCountries()
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataTransformations
     *********************************************************************************************/
    public async getAmecoInternalMetadataTransformations(): Promise<IAmecoMetadataDimension[]> {
        return this.amecoInternalService.getMetadataTransformations()
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataAggregations
     *********************************************************************************************/
    public async getAmecoInternalMetadataAggregations(): Promise<IAmecoMetadataDimension[]> {
        return this.amecoInternalService.getMetadataAggregations()
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataUnits
     *********************************************************************************************/
    public async getAmecoInternalMetadataUnits(): Promise<IAmecoMetadataDimension[]> {
        return this.amecoInternalService.getMetadataUnits()
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataSeries
     *********************************************************************************************/
    public async getAmecoInternalMetadataSeries(): Promise<IAmecoMetadataDimension[]> {
        return this.amecoInternalService.getMetadataSeries()
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataTree
     *********************************************************************************************/
    public async getAmecoInternalMetadataTree(): Promise<IAmecoInternalMetadataTree[]> {
        return this.amecoInternalService.getMetadataTree()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getStatsType
     *********************************************************************************************/
    private getStatsType(amecoType: AmecoType): string {
        switch (amecoType) {
            case AmecoType.CURRENT: return 'C'
            case AmecoType.PUBLIC: return 'A'
            case AmecoType.RESTRICTED: return 'R'
            case AmecoType.ONLINE: return 'O'
            default: return ''
        }
    }

    /**********************************************************************************************
     * @method getAmecoService
     *********************************************************************************************/
    private getAmecoService(amecoType: AmecoType): BaseAmecoService {
        return amecoType === AmecoType.ONLINE ? this.amecoOnlineService : this.amecoInternalService
    }

    /**********************************************************************************************
     * @method getAmecoFullData
     *********************************************************************************************/
    private getAmecoFullData(
        amecoType: AmecoType, indicators: string[], countryIds: string[], defaultCountries?: boolean
    ): Promise<IDBAmecoData[]> {
        switch (amecoType) {
            case AmecoType.ONLINE:
                return this.amecoOnlineService.getAmecoFullData(indicators, countryIds, defaultCountries)
            case AmecoType.CURRENT:
            case AmecoType.PUBLIC:
            case AmecoType.RESTRICTED:
                return this.amecoInternalService.getAmecoFullData(
                    this.getProcedureName(amecoType), indicators, countryIds, defaultCountries
                )
            default: return this.notAvailable()
        }
    }

    /**********************************************************************************************
     * @method getProcedureName
     *********************************************************************************************/
    private getProcedureName(amecoType: AmecoType): string {
        switch (amecoType) {
            case AmecoType.CURRENT: return 'getAmecoCurrent'
            case AmecoType.PUBLIC: return 'getAmecoPublic'
            case AmecoType.RESTRICTED: return 'getAmecoRestricted'
            case AmecoType.ONLINE: return 'getAmecoSeries'
            default: return undefined
        }
    }

    /**********************************************************************************************
     * @method checkDataset
     *********************************************************************************************/
    private checkDataset(dataset: string) {
        const ds = dataset?.toLowerCase()
        if (!ds || (ds.toUpperCase() !== 'AMECO' && !['public', 'current', 'restricted'].includes(ds))) {
            throw Error(`Unknown dataset: ${dataset}!`)
        }
    }

    /**********************************************************************************************
     * @method getAmecoSdmxData
     *********************************************************************************************/
    private async getAmecoSdmxData(
        dataset: string, countries: string[], codes: string[],
        trns: string[], aggs: string[], units: string[], refs: string[]
    ): Promise<IDBAmecoSdmxData[]> {
        const ds = dataset.toLowerCase()
        if (dataset.toUpperCase() === 'AMECO' ||  ds === 'public') {
            return this.amecoInternalService.getPublicSeriesDataSdmx(countries, codes, trns, aggs, units, refs)
        } else if (ds === 'current') {
            return this.amecoInternalService.getCurrentSeriesDataSdmx(countries, codes, trns, aggs, units, refs)
        } else if (ds === 'restricted') {
            return this.amecoInternalService.getRestrictedSeriesDataSdmx(countries, codes, trns, aggs, units, refs)
        }

        return []
    }

    /**********************************************************************************************
     * @method notAvailable
     *********************************************************************************************/
    private notAvailable<T>(): T {
        throw Error('Not available!')
        return null
    }
}
