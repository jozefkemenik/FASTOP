import {
    ICompressedData,
    IIndicator, IIndicatorCodeMapping,
    IIndicatorData,
    IIndicatorReport,
    IIndicatorScale,
    IIndicatorTreeNode,
} from '../../../fdms/src/report/shared-interfaces'
import {
    IDataUploadResult,
    IFdmsIndicator, IFdmsIndicatorMapping,
    IFdmsScale,
    IIndicatorDataUpload, IIndicatorUpload
} from '../../../fdms/src/upload/shared-interfaces'
import { EApps } from 'config'
import { EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { EStatusRepo } from 'country-status'
import { ForecastType } from '../../../fdms/src/forecast/shared-interfaces'
import { ICountry } from '../menu'
import { ICtyActionResult } from '../dashboard'
import { IRoundStorage } from '../../../fdms/src/shared/shared-interfaces'
import { IWQCountryIndicators } from '../../../web-queries/src/shared/shared-interfaces'
import { RequestService } from '../request.service'

export class FdmsApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProvidersIndicatorData
     *********************************************************************************************/
    public static getProvidersIndicatorData(
        appId: EApps.FDMS | EApps.FDMSIE,
        providerId: string,
        countryIds: string[],
        indicatorIds: string[],
        periodicity = 'A',
        ctyGroup?: string,
        yearsRange?: number[],
        roundSid?: number,
        storageSid?: number,
    ): Promise<IWQCountryIndicators> {
        let url = `/wq/indicators?providerId=${providerId}&periodicity=${periodicity}`
        if (countryIds?.length) url += `&countryIds=${countryIds.join(',')}`
        if (indicatorIds?.length) url += `&indicatorIds=${indicatorIds.join(',')}`
        if (ctyGroup) url += `&ctyGroup=${ctyGroup}`
        if (yearsRange) url += `&yearsRange=${yearsRange.join(',')}`
        if (roundSid && storageSid) url += `&roundSid=${roundSid}&storageSid=${storageSid}`

        return RequestService.request(appId, url,)
    }

    /**********************************************************************************************
     * @method getHorizontalIndicator
     *********************************************************************************************/
    public static getHorizontalIndicator(
        appId: EApps.FDMS | EApps.FDMSIE,
        indicatorId: string,
        providerId: string,
        query: never,
    ): Promise<IWQCountryIndicators> {
        const url = `/wq/horizontalIndicator/${indicatorId}/${providerId}`
        return RequestService.request(appId, url, 'get', undefined, {}, {qs: query})
    }

    /**********************************************************************************************
     * @method getReportIndicators
     *********************************************************************************************/
    public static getReportIndicators(reportId: string): Promise<IIndicatorReport[]> {
        return RequestService.request(EApps.FDMS, `/reports/reportIndicators/${reportId}`)
    }

    /**********************************************************************************************
     * @method getBaseYear
     *********************************************************************************************/
    public static getBaseYear(roundSid?: number): Promise<number> {
        return RequestService.request(EApps.FDMS, `/reports/baseYear/${roundSid}`)
    }

    /**********************************************************************************************
     * @method getProviderCountryIndicatorData
     *********************************************************************************************/
    public static getProviderCountryIndicatorData(
        providerId: string,
        periodicityId: string,
        countryIds?: string[],
        indicatorIds?: string[],
        roundSid?: number,
        storageSid?: number,
        custTextSid?: number,
    ): Promise<IIndicatorData[]> {
        const url = `/reports/indicators/${providerId}/${periodicityId}/${roundSid}/${storageSid}/${custTextSid}`
        return RequestService.request(
            EApps.FDMS, url, 'post', { countryIds, indicatorIds }
        )
    }

    /**********************************************************************************************
     * @method getProviderDataCompressed
     *********************************************************************************************/
    public static getProviderDataCompressed(
        providerIds: string[],
        periodicity = 'A',
        countryIds: string[],
        indicatorIds: string[],
        roundSid?: number,
        storageSid?: number,
        textSid?: number,
    ): Promise<ICompressedData> {
        const url = `/reports/provider/data/${periodicity}/${roundSid}/${storageSid}/${textSid ? textSid : ''}`
                + `?compress=true`

        return RequestService.request(EApps.FDMS, url, 'post', { providerIds, countryIds, indicatorIds })
    }

     /**********************************************************************************************
     * @method getProviderDataByKeysCompressed
     *********************************************************************************************/
     public static getProviderDataByKeysCompressed(
        providerIds: string[],
        keys: string[],
        roundSid: number,
        storageSid: number,
        textSid: number,
    ): Promise<ICompressedData> {
        const url = `/reports/provider/data/keys/${roundSid}/${storageSid}/${textSid ? textSid : ''}`
                + `?compress=true`

        return RequestService.request(EApps.FDMS, url, 'post', { providerIds, keys })
    }

    /**********************************************************************************************
     * @method getProviderIndicators
     *********************************************************************************************/
    public static getProviderIndicators(providerIds: string[], periodicity: string): Promise<IIndicator[]> {
        return RequestService.request(
            EApps.FDMS,
            `/reports/provider/indicators?providerIds=${providerIds.join(',')}&periodicity=${periodicity}`,
        )
    }

    /**********************************************************************************************
     * @method getFdmsIndicatorsMappings
     *********************************************************************************************/
    public static getFdmsIndicatorsMappings(
        providerIds: string[], periodicity: string
    ): Promise<IIndicatorCodeMapping[]> {
        return RequestService.request(
            EApps.FDMS,
            `/reports/provider/indicatorsMappings?providerIds=${providerIds.join(',')}&periodicity=${periodicity}`,
        )
    }

    /**********************************************************************************************
     * @method getProviderCountries
     *********************************************************************************************/
    public static getProviderCountries(providerIds: string[]): Promise<ICountry[]> {
        return RequestService.request(
            EApps.FDMS, `/reports/provider/countries?providerIds=${providerIds.join(',')}`,
        )
    }

    /**********************************************************************************************
     * @method getIndicatorsTree
     *********************************************************************************************/
    public static getIndicatorsTree(): Promise<IIndicatorTreeNode[]> {
        return RequestService.request(EApps.FDMS, '/reports/indicatorsTree',)
    }

    /**********************************************************************************************
     * @method getIndicatorScales
     *********************************************************************************************/
    public static getIndicatorScales(
        providerId: string, periodicityId: string, countryIds: string[], indicatorIds: string[],
    ): Promise<IIndicatorScale[]> {
        const url = `/reports/indicatorScales/${providerId}/${periodicityId}`
        return RequestService.request(
            EApps.FDMS, url, 'post', { countryIds, indicatorIds }
        )
    }

    /**********************************************************************************************
     * @method acceptForecastAggregation
     *********************************************************************************************/
    public static acceptForecastAggregation(currentStatusId: EStatusRepo, user: string): Promise<ICtyActionResult> {
        const url = `/dashboard/action/${EDashboardActions.ACCEPT}/AGG`
        return RequestService.request(
            EApps.FDMS, url, 'post', { currentStatusId, comment: 'Automated acceptance during round activation' },
            { authLogin: user }
        )
    }

    /**********************************************************************************************
     * @method getForecastRoundAndStorage
     *********************************************************************************************/
    public static getForecastRoundAndStorage(forecastType: ForecastType): Promise<IRoundStorage> {
        return RequestService.request(EApps.FDMS, `/forecast/${forecastType}`,)
    }

    /**********************************************************************************************
     * @method getScales
     *********************************************************************************************/
    public static getScales(): Promise<IFdmsScale[]> {
        return RequestService.request(EApps.FDMS, `/uploads/scales`)
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public static getIndicators(providerId: string): Promise<IFdmsIndicator[]> {
        return RequestService.request(EApps.FDMS, `/uploads/indicators?providerId=${providerId}`)
    }

    /**********************************************************************************************
     * @method getIndicatorsMappings
     *********************************************************************************************/
    public static getIndicatorsMappings(providerId: string): Promise<IFdmsIndicatorMapping[]> {
        return RequestService.request(EApps.FDMS, `/uploads/indicatorsMappings?providerId=${providerId}`)
    }

    /**********************************************************************************************
     * @method uploadIndicatorData
     *********************************************************************************************/
    public static uploadIndicatorData(
        roundSid: number,
        storageSid: number,
        providerId: string,
        data: IIndicatorDataUpload,
        user?: string
    ): Promise<IDataUploadResult> {
        return RequestService.request(EApps.FDMS,
            `/uploads/indicatorData/${roundSid}/${storageSid}/${providerId}`, 'post', data,
            FdmsApi.getAuthHeader(user),
        )
    }

    /**********************************************************************************************
     * @method getOutputGapUpload
     *********************************************************************************************/
    public static getOutputGapUpload(
        providerId: string, roundSid: number, storageSid: number, sendData: boolean
    ): Promise<IIndicatorUpload> {
        return RequestService.request(EApps.FDMS,
            `/uploads/outputGap/${providerId}?roundSid=${roundSid}&storageSid=${storageSid}&sendData=${sendData}`
        )
    }

    /**********************************************************************************************
     * @method uploadFile
     *********************************************************************************************/
    public static uploadFile(
        file: Express.Multer.File,
        countryId: string, providerId: string,
        roundSid: number, storageSid: number, custTextSid: number, user: string
    ): Promise<number> {
        const formData = new FormData()
        formData.append(file.fieldname, new Blob([Buffer.from(file.buffer)]), file.originalname)

        const ctyParam = countryId ? `?countryId=${countryId}` : ''
        return RequestService.request(EApps.FDMS,
            `/uploads/file/${providerId}/${roundSid}/${storageSid}/${custTextSid}${ctyParam}`,
            'post',
            formData,
            FdmsApi.getAuthHeader(user),
            undefined, true
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAuthHeader
     *********************************************************************************************/
    private static getAuthHeader(user: string): Record<string, string> {
        return user ? { authLogin: user } : undefined
    }
}
