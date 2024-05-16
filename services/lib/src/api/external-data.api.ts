import { IAmecoChapter, IAmecoSerie, IAmecoSeriesData } from '../ameco/shared-interfaces'
import {
    IAmecoData,
    IAmecoInternalMetadataTree,
    IAmecoLastUpdate,
    IAmecoMetadataCountry,
    IAmecoMetadataDimension,
} from '../../../external-data/src/ameco/shared-interfaces'
import {
    INomicsDataset,
    INomicsDatasetSeries,
    INomicsProvider,
    INomicsTreeItem
} from '../../../external-data/src/dbnomics/shared-interfaces'
import { ISpi, ISpiMatrix, ISpiMatrixParams, ISpiParams } from '../../../external-data/src/spi/shared-interfaces'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { EApps } from 'config'
import { IAmecoStats } from 'stats'
import { ICountry } from '../addin/shared-interfaces'
import { IImfData } from '../../../external-data/src/imf/shared-interfaces'
import { ISdmxData } from '../sdmx/shared-interfaces'
import { RequestService } from '../request.service'

export class ExternalDataApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isAmecoInternalForecastPeriod
     *********************************************************************************************/
    public static isAmecoInternalForecastPeriod(): Promise<boolean> {
        return RequestService.request(EApps.ED, `/ameco/internal/forecastPeriod`)
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataCountries
     *********************************************************************************************/
    public static getAmecoInternalMetadataCountries(): Promise<IAmecoMetadataCountry[]> {
        return RequestService.request(EApps.ED, `/ameco/internal/metadata/countries`)
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataTransformations
     *********************************************************************************************/
    public static getAmecoInternalMetadataTransformations(): Promise<IAmecoMetadataDimension[]> {
        return RequestService.request(EApps.ED, `/ameco/internal/metadata/trn`)
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataAggregations
     *********************************************************************************************/
    public static getAmecoInternalMetadataAggregations(): Promise<IAmecoMetadataDimension[]> {
        return RequestService.request(EApps.ED, `/ameco/internal/metadata/agg`)
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataUnits
     *********************************************************************************************/
    public static getAmecoInternalMetadataUnits(): Promise<IAmecoMetadataDimension[]> {
        return RequestService.request(EApps.ED, `/ameco/internal/metadata/unit`)
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataSeries
     *********************************************************************************************/
    public static getAmecoInternalMetadataSeries(): Promise<IAmecoMetadataDimension[]> {
        return RequestService.request(EApps.ED, `/ameco/internal/metadata/serie`)
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadataTree
     *********************************************************************************************/
    public static getAmecoInternalMetadataTree(): Promise<IAmecoInternalMetadataTree[]> {
        return RequestService.request(EApps.ED, `/ameco/internal/metadata/tree`)
    }

    /**********************************************************************************************
     * @method getAmecoFullData
     *********************************************************************************************/
    public static getAmecoFullData (
        amecoType: AmecoType, countryIds: string[], indicatorIds: string[], defaultCountries?: boolean
    ): Promise<IAmecoData[]> {
        return RequestService.request(EApps.ED,
            `/ameco/${amecoType}?countryIds=${countryIds?.join(',')}&indicatorIds=${indicatorIds.join(',')}` +
            `&defaultCountries=${defaultCountries ? 'Y' : 'N'}`,
        )
    }

    /**********************************************************************************************
     * @method getAmecoLastUpdate
     *********************************************************************************************/
    public static getAmecoLastUpdate(amecoType: AmecoType): Promise<IAmecoLastUpdate> {
        return RequestService.request(EApps.ED,
            `/ameco/${amecoType}/lastUpdate`,
        )
    }

    /**********************************************************************************************
     * @method getImfData
     *********************************************************************************************/
    public static getImfData(
        dataset: string, queryKey: string, startPeriod: number, endPeriod: number
    ): Promise<IImfData> {
        return RequestService.request(EApps.ED,
            `/imf?ds=${dataset}&key=${queryKey}&startPeriod=${startPeriod}&endPeriod=${endPeriod}`)
    }

    /**********************************************************************************************
     * @method getSpiData
     *********************************************************************************************/
    public static getSpiData(params: ISpiParams): Promise<ISpi> {
        return RequestService.request(EApps.ED, '/spi', 'post', params)
    }

    /**********************************************************************************************
     * @method getSpiMatrixData
     *********************************************************************************************/
    public static getSpiMatrixData(params: ISpiMatrixParams): Promise<ISpiMatrix> {
        return RequestService.request(EApps.ED, '/spi/matrix', 'post', params)
    }

    /**********************************************************************************************
     * @method getNsiData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static getNsiData(nsiType: string, countryId: string, params: any): Promise<any> {
        const queryParams = Object.keys(params).map(k => `${k}=${params[k]}`).join('&')
        return RequestService.request(EApps.ED, `/nsi/${nsiType}/${countryId}?${queryParams}`, )
    }

    /**********************************************************************************************
     * @method getAmecoCountries
     *********************************************************************************************/
    public static getAmecoCountries(amecoType: AmecoType): Promise<ICountry[]> {
        return RequestService.request(EApps.ED, `/ameco/${amecoType}/countries`)
    }

    /**********************************************************************************************
     * @method getAmecoSeries
     *********************************************************************************************/
    public static getAmecoSeries(amecoType: AmecoType): Promise<IAmecoSerie[]> {
        return RequestService.request(EApps.ED, `/ameco/${amecoType}/series`)
    }

    /**********************************************************************************************
     * @method getAmecoChapters
     *********************************************************************************************/
    public static getAmecoChapters(amecoType: AmecoType): Promise<IAmecoChapter[]> {
        return RequestService.request(EApps.ED, `/ameco/${amecoType}/chapters`)
    }

    /**********************************************************************************************
     * @method getAmecoSeriesData
     *********************************************************************************************/
    public static getAmecoSeriesData(
        amecoType: AmecoType,
        countries: string,
        series: string,
    ): Promise<IAmecoSeriesData[]> {
        return RequestService.request(EApps.ED,
            `/ameco/${amecoType}/seriesData?countries=${countries}&series=${series}`
        )
    }

    /**********************************************************************************************
     * @method getAmecoSdmxData
     *********************************************************************************************/
    public static getAmecoSdmxData(
        dataset: string, queryKey: string, startPeriod?: string, endPeriod?: string,
    ): Promise<ISdmxData> {
        return RequestService.request(EApps.ED,
            `/ameco/sdmx/data/${dataset}/${queryKey}?startPeriod=${startPeriod}&endPeriod=${endPeriod}`
        )
    }

    /**********************************************************************************************
     * @method logStatistics
     *********************************************************************************************/
    public static logStatistics(stats: IAmecoStats): Promise<number> {
        return RequestService.request(EApps.ED, '/ameco/logStats', 'post', stats)
    }

    /**********************************************************************************************
     * @method getDbNomicsProviders
     *********************************************************************************************/
    public static getDbNomicsProviders(): Promise<INomicsProvider[]> {
        return RequestService.request(EApps.ED, '/nomics/providers')
    }

    /**********************************************************************************************
     * @method getDbNomicsProviderTree
     *********************************************************************************************/
    public static getDbNomicsProviderTree(provider: string): Promise<INomicsTreeItem[]> {
        return RequestService.request(EApps.ED, `/nomics/providers/${provider}`)
    }

    /**********************************************************************************************
     * @method getDbNomicsDataset
     *********************************************************************************************/
    public static getDbNomicsDataset(provider: string, dataset: string): Promise<INomicsDataset> {
        return RequestService.request(EApps.ED, `/nomics/dataset/${provider}/${dataset}`)
    }

    /**********************************************************************************************
     * @method getDbNomicsDataByQuery
     *********************************************************************************************/
    public static getDbNomicsDataByQuery(
        provider: string, dataset: string, query: string, limit = 1000, offset = 0
    ): Promise<INomicsDatasetSeries> {
        const params = `?${ExternalDataApi.getDbNomicsParams(limit, offset)}`
        return RequestService.request(
            EApps.ED, `/nomics/data/query/${provider}/${dataset}${params}`, 'put',
            { query }
        )
    }

    /**********************************************************************************************
     * @method getDbNomicsDataBySeries
     *********************************************************************************************/
    public static getDbNomicsDataBySeries(
        provider: string, dataset: string, series: string[], limit = 1000, offset = 0
    ): Promise<INomicsDatasetSeries> {
        const params = `?${ExternalDataApi.getDbNomicsParams(limit, offset)}`
        return RequestService.request(
            EApps.ED, `/nomics/data/series/${provider}/${dataset}${params}`, 'put',
            { series }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Static Methods /////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDbNomicsParams
     *********************************************************************************************/
    private static getDbNomicsParams(limit = 1000, offset = 0): string {
        return `limit=${limit}&offset=${offset}`
    }
}
