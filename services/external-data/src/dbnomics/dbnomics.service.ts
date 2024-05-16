import { IRawNomicsDatasets, IRawNomicsProvider, IRawNomicsSerie, IRawNomicsTree } from '.'
import { Level, LoggingService } from '../../../lib/dist'
import { FastopError } from '../../../shared-lib/dist/prelib/error'
import { RequestService } from '../../../lib/dist/request.service'


export class DbNomicsService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly NOMICS_URL = 'https://api.db.nomics.world/v22'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private _logs: LoggingService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviders
     *********************************************************************************************/
    public async getProviders(): Promise<IRawNomicsProvider> {
        return this.callDbNomics<IRawNomicsProvider>(`${DbNomicsService.NOMICS_URL}/providers`)
    }

    /**********************************************************************************************
     * @method getProviderTree
     *********************************************************************************************/
    public async getProviderTree(provider: string): Promise<IRawNomicsTree> {
        return this.callDbNomics<IRawNomicsTree>(`${DbNomicsService.NOMICS_URL}/providers/${provider}`)
    }

    /**********************************************************************************************
     * @method getDataset
     *********************************************************************************************/
    public async getDataset(provider: string, dataset: string): Promise<IRawNomicsDatasets> {
        return this.callDbNomics<IRawNomicsDatasets>(
            `${DbNomicsService.NOMICS_URL}/datasets/${provider}/${dataset}`
        )
    }

    /**********************************************************************************************
     * @method getSeries
     *********************************************************************************************/
    public async getSeries(provider: string, dataset: string, limit = 1000): Promise<IRawNomicsSerie> {
        return this.callDbNomics<IRawNomicsSerie>(
            `${DbNomicsService.NOMICS_URL}/series/${provider}/${dataset}` +
            `?observations=false&metadata=false&format=json&limit=${limit}`
        )
    }

    /**********************************************************************************************
     * @method getDataByQuery
     *********************************************************************************************/
    public async getDataByQuery(
        provider: string, dataset: string, query: string, limit: number, offset: number,
    ): Promise<IRawNomicsSerie> {
        const params = this.getLimitAndOffsetQueryParams(limit, offset)

        return this.callDbNomics<IRawNomicsSerie>(
            `${DbNomicsService.NOMICS_URL}/series/${provider}/${dataset}/${query}` +
            `?observations=true&metadata=true&align_periods=true&format=json${ params }`
        )
    }

    /**********************************************************************************************
     * @method getDataBySeries
     *********************************************************************************************/
    public async getDataBySeries(
        provider: string, dataset: string, series: string[], limit: number, offset: number,
    ): Promise<IRawNomicsSerie> {
        const params = this.getLimitAndOffsetQueryParams(limit, offset)
        const prefix = encodeURIComponent(`${provider}/${dataset}/`)
        const series_ids = series.map(serie => `${prefix}${serie}`).join(',')

        return this.callDbNomics<IRawNomicsSerie>(
            `${ DbNomicsService.NOMICS_URL }/series?series_ids=${ series_ids }` +
            `&observations=true&metadata=true&align_periods=true&format=json${ params }`
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method callDbNomics
     *********************************************************************************************/
    private async callDbNomics<T>(uri: string): Promise<T> {
        this._logs.log(`Calling DbNomics url: ${uri}`, Level.INFO)
        return RequestService.requestUri(
            uri,
            'get', undefined, undefined, undefined, true
        ).then(response => {
            if (response?.errors && response?.errors.length > 0) {
                throw new FastopError(undefined, response.errors[0].message)
            }
            return response
        })
    }

    /**********************************************************************************************
     * @method getLimitAndOffsetQueryParams
     *********************************************************************************************/
    private getLimitAndOffsetQueryParams(limit: number, offset: number): string {
        const params: string[] = []
        if (limit) params.push(`limit=${limit}`)
        if (offset) params.push(`offset=${offset}`)
        return params.length ? `&${params.join('&')}` : ''
    }

}
