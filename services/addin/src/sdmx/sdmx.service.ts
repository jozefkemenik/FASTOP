import { ISdmxCode, ISdmxData, ISdmxStructure, SdmxProvider } from '../../../lib/dist/sdmx/shared-interfaces'
import { CacheMap } from '../../../lib/dist'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { FplmApi } from '../../../lib/dist/api/fplm.api'
import { ISdmxDatasetData } from './shared-interfaces'
import { SdmxApi } from '../../../lib/dist/api/sdmx.api'

export class SdmxService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _datasets: ISdmxCode[]
    private _datasetStructure = new CacheMap<string, ISdmxStructure>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(private readonly provider: SdmxProvider) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDatasets
     *********************************************************************************************/
    public async getDatasets(): Promise<ISdmxCode[]> {
        if (!this._datasets) {
            this._datasets = await SdmxApi.getDatasets(this.provider)
            // for 'ECFIN' provider filter the datasets according to dataflows published in fplakes
            if (this.provider.toUpperCase() === 'ECFIN') {
                const lakeDataflows: Set<string> = await FplmApi.getDataflows(this.provider).then(
                    dataflows => new Set<string>(dataflows.map(df => df.toUpperCase()))
                )

                this._datasets = this._datasets.filter(ds => lakeDataflows.has(ds.id.toUpperCase()))
            }
        }
        return this._datasets
    }

    /**********************************************************************************************
     * @method getDatasetStructure
     *********************************************************************************************/
    public async getDatasetStructure(dataset: string): Promise<ISdmxStructure> {
        if (!this._datasetStructure.has(dataset)) {
            this._datasetStructure.set(dataset, await SdmxApi.getDatasetStructure(this.provider, dataset))
        }
        return this._datasetStructure.get(dataset)
    }

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    public async getData(dataset: string, queryKey: string, startPeriod?: string): Promise<ISdmxDatasetData> {

        if (this.provider === SdmxProvider.ECB) {
            queryKey = this.fixHexKeywordForECB(queryKey)
        }

        const promise: Promise<ISdmxData> = dataset.toUpperCase() === 'AMECO' ?
            ExternalDataApi.getAmecoSdmxData(dataset, queryKey, startPeriod) :
            SdmxApi.getData(this.provider, dataset, queryKey, false, startPeriod, undefined, false)

        return  promise.then(sdmx => ({ sdmx, dataset }))
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////// Private Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fixHexKeywordForECB
     * @see https://citnet.tech.ec.europa.eu/CITnet/jira/browse/FASTOP-1233
     * @ ECB blocks any request containing "HEX" in the url
     * @ If the dimension contains 'HEX' as a query key, then remove all keys and query for all possible values
     * @ This is a temporary workaround until ECB solves the problem on their side.
     *********************************************************************************************/
    private fixHexKeywordForECB(queryKey: string): string {
        return queryKey.toUpperCase().includes('HEX') ? queryKey.split('.')
                       .map(dimQuery => dimQuery.toUpperCase().includes('HEX') ? '' : dimQuery)
                       .join('.') : queryKey
    }

}
