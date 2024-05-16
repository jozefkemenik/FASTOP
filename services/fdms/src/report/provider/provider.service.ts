import { BIND_OUT, CURSOR, ISPOptions, STRING } from '../../../../lib/dist/db'
import { IDBIndicator, IDBIndicatorCodeMapping } from '../index'
import { CacheMap } from '../../../../lib/dist/cache-map'
import { DataAccessApi } from '../../../../lib/dist/api'
import { IDBCountry } from '../../../../lib/dist/menu'


export class ProviderService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _providerCountries = new CacheMap<string, IDBCountry[]>()
    private _providerIndicators = new CacheMap<string, IDBIndicator[]>()
    private _providerIndicatorsMappings = new CacheMap<string, IDBIndicatorCodeMapping[]>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviderCountries
     *********************************************************************************************/
    public async getProviderCountries(providerIds: string[]): Promise<IDBCountry[]> {
        const key = providerIds.sort().join('_')
        if (!this._providerCountries.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_provider_ids', type: STRING, value: providerIds },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getProviderCountries', options)
            this._providerCountries.set(key, dbResult.o_cur)
        }
        return this._providerCountries.get(key)
    }

    /**********************************************************************************************
     * @method getProviderIndicators
     *********************************************************************************************/
    public async getProviderIndicators(providerIds: string[], periodicity = 'A'): Promise<IDBIndicator[]> {
        const key = `${providerIds.sort().join('_')}_${periodicity}`
        if (!this._providerIndicators.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_provider_ids', type: STRING, value: providerIds },
                    { name: 'p_periodicity_id', type: STRING, value: periodicity },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getProviderIndicators', options)
            this._providerIndicators.set(key, dbResult.o_cur)
        }
        return this._providerIndicators.get(key)
    }


    /**********************************************************************************************
     * @method getProviderIndicatorsMappings
     *********************************************************************************************/
    public async getProviderIndicatorsMappings(
        providerIds: string[], periodicity = 'A'
    ): Promise<IDBIndicatorCodeMapping[]> {
        const key = `${providerIds.sort().join('_')}_${periodicity}`
        if (!this._providerIndicatorsMappings.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_provider_ids', type: STRING, value: providerIds },
                    { name: 'p_periodicity_id', type: STRING, value: periodicity },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getProviderIndicatorsMappings', options)
            this._providerIndicatorsMappings.set(key, dbResult.o_cur)
        }
        return this._providerIndicatorsMappings.get(key)
    }
}
