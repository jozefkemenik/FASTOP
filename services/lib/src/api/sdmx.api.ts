import { ISdmxBag, ISdmxCode, ISdmxData, ISdmxStructure, SdmxProvider } from '../sdmx/shared-interfaces'
import { EApps } from 'config'
import { RequestService } from '../request.service'

export class SdmxApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getFpapiData
     *********************************************************************************************/
    public static getFpapiData(
        provider: string, dataset: string, query: string,
        startPeriod: string, endPeriod: string, flags?: boolean
    ): Promise<ISdmxData> {

        let url = `/fpapi/${provider}/series/${dataset}/${query}`
        const params = []
        if (startPeriod) params.push(`start_period=${startPeriod}`)
        if (endPeriod) params.push(`end_period=${endPeriod}`)
        if (flags) params.push('flags=True')

        if (params.length) url += `?${params.join('&')}`

        return RequestService.request(EApps.SDMX, url,)
    }

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    public static getData(
        provider: SdmxProvider, dataset: string, seriesCode: string, fetchLabels: boolean,
        startPeriod: string, endPeriod: string, forceJson?: boolean
    ): Promise<ISdmxData> {
        return SdmxApi.getSdmxData(
            `/${provider}/series`, dataset, seriesCode, fetchLabels, startPeriod, endPeriod, forceJson
        )
    }

    /**********************************************************************************************
     * @method exportToSdmx
     *********************************************************************************************/
    public static async exportToSdmx(dataset: string, freq: string, data: ISdmxBag): Promise<Buffer> {
        return RequestService.request(
            EApps.SDMX, `/convert/sdmxml/${dataset}/${freq}`, 'post', data, {}, { encoding: null }, true,
        ).then(Buffer.from)
    }

    /**********************************************************************************************
     * @method getDatasets
     *********************************************************************************************/
    public static getDatasets(provider: SdmxProvider): Promise<ISdmxCode[]> {
        return RequestService.request(EApps.SDMX, `/${provider}/datasets`)
    }

    /**********************************************************************************************
     * @method getDatasetStructure
     *********************************************************************************************/
    public static getDatasetStructure(provider: SdmxProvider, dataset: string): Promise<ISdmxStructure> {
        return RequestService.request(EApps.SDMX, `/${provider}/dataset/${dataset}`)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSdmxData
     *********************************************************************************************/
    private static getSdmxData(
        serviceUrl: string, dataset: string, seriesCode: string, fetchLabels: boolean,
        startPeriod: string, endPeriod: string, forceJson?: boolean, flags?: boolean
    ): Promise<ISdmxData> {
        let url = `${serviceUrl}/${dataset}/${seriesCode}`
        const params = []
        if (fetchLabels) params.push(`metadata=${fetchLabels}`)
        if (startPeriod) params.push(`start_period=${startPeriod}`)
        if (endPeriod) params.push(`end_period=${endPeriod}`)
        if (forceJson) params.push('force_json=True')
        if (flags) params.push('flags=True')

        if (params.length) url += `?${params.join('&')}`

        return RequestService.request(EApps.SDMX, url,)
    }
}
