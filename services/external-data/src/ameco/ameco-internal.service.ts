import {
    IDBAmecoData,
    IDBAmecoInternalMetadataTree,
    IDBAmecoMetadataCountry,
    IDBAmecoMetadataDimension,
    IDBAmecoSdmxData,
    IDBAmecoSeriesData,
    IDBForecastPeriod
} from '.'
import { ISPOptions, STRING } from '../../../lib/dist/db'
import { BaseAmecoService } from './base-ameco-service'
import { IAmecoLastUpdate } from './shared-interfaces'


export class AmecoInternalService extends BaseAmecoService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoFullData
     *********************************************************************************************/
    public async getAmecoFullData(
        procedureName: string, indicators: string[], countryIds: string[], defaultCountries?: boolean
    ): Promise<IDBAmecoData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_indicator_ids', type: STRING, value: indicators.join(',') },
                { name: 'p_country_ids',
                    type: STRING,
                    value: !defaultCountries && countryIds ? countryIds.join(',') : null
                },
                { name: 'p_default_countries', type: STRING, value: defaultCountries ? 'Y' : null },
            ],
        }
        return this.execAmecoSP<IDBAmecoData[]>(procedureName, options)
    }

    /**********************************************************************************************
     * @method getCurrentSeriesData
     *********************************************************************************************/
    public async getCurrentSeriesData(countries: string, series: string): Promise<IDBAmecoSeriesData[]> {
        return this.getSeriesData('getCurrentSeriesData', countries, series)
    }

    /**********************************************************************************************
     * @method getPublicSeriesData
     *********************************************************************************************/
    public async getPublicSeriesData(countries: string, series: string): Promise<IDBAmecoSeriesData[]> {
        return this.getSeriesData('getAnnexSeriesData', countries, series)
    }

    /**********************************************************************************************
     * @method getPublicSeriesDataSdmx
     *********************************************************************************************/
    public async getPublicSeriesDataSdmx(
        countries: string[], codes: string[], trns: string[], aggs: string[], units: string[], refs: string[]
    ): Promise<IDBAmecoSdmxData[]> {
        return this.getSeriesDataSdmx(
            'getAnnexSeriesDataSdmx', countries, codes, trns, aggs, units, refs
        )
    }

    /**********************************************************************************************
     * @method getCurrentSeriesDataSdmx
     *********************************************************************************************/
    public async getCurrentSeriesDataSdmx(
        countries: string[], codes: string[], trns: string[], aggs: string[], units: string[], refs: string[]
    ): Promise<IDBAmecoSdmxData[]> {
        return this.getSeriesDataSdmx(
            'getCurrentSeriesDataSdmx', countries, codes, trns, aggs, units, refs
        )
    }

    /**********************************************************************************************
     * @method getRestrictedSeriesDataSdmx
     *********************************************************************************************/
    public async getRestrictedSeriesDataSdmx(
        countries: string[], codes: string[], trns: string[], aggs: string[], units: string[], refs: string[]
    ): Promise<IDBAmecoSdmxData[]> {
        return this.getSeriesDataSdmx(
            'getRestrictedSeriesDataSdmx', countries, codes, trns, aggs, units, refs
        )
    }

    /**********************************************************************************************
     * @method getRestrictedSeriesData
     *********************************************************************************************/
    public async getRestrictedSeriesData(countries: string, series: string): Promise<IDBAmecoSeriesData[]> {
        return this.getSeriesData('getRestrictedSeriesData', countries, series)
    }

    /**********************************************************************************************
     * @method isForecastPeriod
     *********************************************************************************************/
    public async isForecastPeriod(): Promise<boolean> {
        return this.execAmecoSP<IDBForecastPeriod>(
            'isForecastPeriod', {params: []}
        ).then(data => data[0].forecast_period > 0)
    }

    /**********************************************************************************************
     * @method logStats
     *********************************************************************************************/
    public async logStats(
        userid: string, agent: string, addr: string, type: string, uri: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: userid || 'anon.'},
                { name: 'p_agent', type: STRING, value: agent || null},
                { name: 'p_addr', type: STRING, value: addr || null},
                { name: 'p_type', type: STRING, value: type || null},
                { name: 'p_uri', type: STRING, value: uri || null},
            ],
        }
        return this.execAmecoSP<number>('logStatistics', options)
    }

    /**********************************************************************************************
     * @method getMetadataCountries
     *********************************************************************************************/
    public async getMetadataCountries(): Promise<IDBAmecoMetadataCountry[]> {
        return this.execAmecoSP<IDBAmecoMetadataCountry[]>('getMetadataCountries', { params: [] })
    }

    /**********************************************************************************************
     * @method getMetadataTransformations
     *********************************************************************************************/
    public async getMetadataTransformations(): Promise<IDBAmecoMetadataDimension[]> {
        return this.execAmecoSP<IDBAmecoMetadataDimension[]>('getMetadataTransformations', { params: [] })
    }

    /**********************************************************************************************
     * @method getMetadataAggregations
     *********************************************************************************************/
    public async getMetadataAggregations(): Promise<IDBAmecoMetadataDimension[]> {
        return this.execAmecoSP<IDBAmecoMetadataDimension[]>('getMetadataAggregations', { params: [] })
    }

    /**********************************************************************************************
     * @method getMetadataUnits
     *********************************************************************************************/
    public async getMetadataUnits(): Promise<IDBAmecoMetadataDimension[]> {
        return this.execAmecoSP<IDBAmecoMetadataDimension[]>('getMetadataUnits', { params: [] })
    }

    /**********************************************************************************************
     * @method getMetadataTree
     *********************************************************************************************/
    public async getMetadataTree(): Promise<IDBAmecoInternalMetadataTree[]> {
        return this.execAmecoSP<IDBAmecoInternalMetadataTree[]>('getMetadataTreeNodes', { params: [] })
    }

    /**********************************************************************************************
     * @method getMetadataSeries
     *********************************************************************************************/
    public async getMetadataSeries(): Promise<IDBAmecoMetadataDimension[]> {
        return this.execAmecoSP<IDBAmecoMetadataDimension[]>('getMetadataSeries', { params: [] })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSeriesData
     * @param countries comma separated list of 3-letter country codes
     * @param series comma separated list of series ids
     *********************************************************************************************/
    private async getSeriesData(
        procedureName: string, countries: string, series: string
    ): Promise<IDBAmecoSeriesData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_ids', type: STRING, value: countries || null },
                { name: 'p_serie_ids', type: STRING, value: series || null },
            ],
        }
        return this.execAmecoSP<IDBAmecoSeriesData[]>(procedureName, options)
    }

    /**********************************************************************************************
     * @method getSeriesDataSdmx
     *********************************************************************************************/
    private async getSeriesDataSdmx(
        procedureName: string, countries: string[], codes: string[],
        trns: string[], aggs: string[], units: string[], refs: string[]
    ): Promise<IDBAmecoSdmxData[]> {
        const arrayParam = (arr: string[]) => arr?.length ? arr.join(',') : null

        const options: ISPOptions = {
            params: [
                { name: 'p_country_ids', type: STRING, value: arrayParam(countries) },
                { name: 'p_codes', type: STRING, value: arrayParam(codes) },
                { name: 'p_trns', type: STRING, value: arrayParam(trns) },
                { name: 'p_aggs', type: STRING, value: arrayParam(aggs) },
                { name: 'p_units', type: STRING, value: arrayParam(units) },
                { name: 'p_refs', type: STRING, value: arrayParam(refs) },
            ],
        }
        return this.execAmecoSP<IDBAmecoSdmxData[]>(procedureName, options)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertLastUpdate
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected convertLastUpdate(data: any): IAmecoLastUpdate {
        return {
            current: this.convertToDate(data.current),
            annex: this.convertToDate(data.annex),
            restricted: this.convertToDate(data.restricted),
        }
    }
}
