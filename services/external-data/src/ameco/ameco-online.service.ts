import { IDBAmecoData, IDBAmecoSeriesData } from './index'
import { ISPOptions, STRING } from '../../../lib/dist/db'
import { BaseAmecoService } from './base-ameco-service'
import { IAmecoLastUpdate } from './shared-interfaces'


export class AmecoOnlineService extends BaseAmecoService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSeriesData
     * @param countries comma separated list of 3-letter country codes
     * @param series comma separated list of series ids
     *********************************************************************************************/
    public async getSeriesData(countries: string, series: string): Promise<IDBAmecoSeriesData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_ids', type: STRING, value: countries || null },
                { name: 'p_serie_ids', type: STRING, value: series || null },
            ],
        }
        return this.execAmecoSP<IDBAmecoSeriesData[]>('getSeriesData', options)
    }

    /**********************************************************************************************
     * @method getAmecoFullData
     *********************************************************************************************/
    public async getAmecoFullData(
        indicators: string[], countryIds: string[], defaultCountries?: boolean
    ): Promise<IDBAmecoData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_indicator_ids', type: STRING, value: indicators?.join(',') ?? null },
                { name: 'p_country_ids',
                  type: STRING,
                  value: !defaultCountries && countryIds ? countryIds.join(',') : null
                },
                { name: 'p_default_countries', type: STRING, value: defaultCountries ? 'Y' : null },
            ],
        }
        return this.execAmecoSP<IDBAmecoData[]>('getAmecoSeries', options)
    }

    /**********************************************************************************************
     * @method logStats
     *********************************************************************************************/
    public async logStats(
        userid: string, agent: string, addr: string, uri: string, source: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: userid || 'anon.'},
                { name: 'p_agent', type: STRING, value: agent || null},
                { name: 'p_addr', type: STRING, value: addr || null},
                { name: 'p_uri', type: STRING, value: uri || null},
                { name: 'p_source', type: STRING, value: source || null},
            ],
        }
        return this.execAmecoSP<number>('logStatistics', options)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertLastUpdate
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected convertLastUpdate(data: any): IAmecoLastUpdate {
        return this.convertToDate(data.lastupdate)
    }
}
