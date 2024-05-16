import {
    INomicsDataset,
    INomicsProvider,
    INomicsTreeItem,
} from 'external-data/src/dbnomics/shared-interfaces'
import { CacheMap } from '../../../lib/dist'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { INomicsData } from './shared-interfaces'


export class NomicsService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _providers: INomicsProvider[]
    private _providerTree = new CacheMap<string, INomicsTreeItem[]>()
    private _dataset = new CacheMap<string, INomicsDataset>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviders
     *********************************************************************************************/
    public async getProviders(): Promise<INomicsProvider[]> {
        if (!this._providers) {
            this._providers = await ExternalDataApi.getDbNomicsProviders()
        }
        return this._providers
    }

    /**********************************************************************************************
     * @method getProviderTree
     *********************************************************************************************/
    public async getProviderTree(provider: string): Promise<INomicsTreeItem[]> {
        if (!this._providerTree.has(provider)) {
            this._providerTree.set(provider, await ExternalDataApi.getDbNomicsProviderTree(provider))
        }
        return this._providerTree.get(provider)
    }

    /**********************************************************************************************
     * @method getDataset
     *********************************************************************************************/
    public async getDataset(provider: string, dataset: string): Promise<INomicsDataset> {
        const key = `${provider}_${dataset}`
        if (!this._dataset.has(key)) {
            this._dataset.set(key, await ExternalDataApi.getDbNomicsDataset(provider, dataset))
        }
        return this._dataset.get(key)
    }

    /**********************************************************************************************
     * @method getDataByQuery
     *********************************************************************************************/
    public async getDataByQuery(
        provider: string, dataset: string, query: string, limit?: number, offset?: number
    ): Promise<INomicsData> {
        return ExternalDataApi.getDbNomicsDataByQuery(
            provider, dataset, query, limit, offset
        )
    }

    /**********************************************************************************************
     * @method getDataBySeries
     *********************************************************************************************/
    public async getDataBySeries(
        provider: string, dataset: string, series: string[], limit: number
    ): Promise<INomicsData> {
        return ExternalDataApi.getDbNomicsDataBySeries(
            provider, dataset, series, limit
        )
    }
}


