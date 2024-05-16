import { IWQImpactParams, IWQIndicators } from '../../../web-queries/src/shared/shared-interfaces'
import { EApps } from 'config'
import { EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

import { IMeasuresRange, ITransparencyReport } from '../measure'
import { ICtyActionResult } from '../dashboard'
import { RequestService } from '../request.service'

export class DfmApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archiveCountryMeasures
     *********************************************************************************************/
    public static archiveCountryMeasures(
        countryId: string, user: string, roundKeys: IRoundKeys,
    ): Promise<ICtyActionResult> {
        return RequestService.request(
            EApps.DFM,
            `/dashboard/action/${EDashboardActions.ARCHIVE}/${countryId}`,
            'post',
            { roundKeys },
            { authLogin: user },
        )
    }

    /**********************************************************************************************
     * @method getCountryTransferMatrix
     *********************************************************************************************/
    public static getCountryTransferMatrix(countryId: string): Promise<IWQIndicators> {
        return RequestService.request(EApps.DFM, `/reports/wqTransferMatrix?countryId=${countryId}`,)
    }

    /**********************************************************************************************
     * @method getCountryAdditionalImpact
     *********************************************************************************************/
    public static getCountryAdditionalImpact(countryId: string): Promise<IWQIndicators> {
        return RequestService.request(EApps.DFM, `/reports/wqAdditionalImpact?countryId=${countryId}`,)
    }

    /**********************************************************************************************
     * @method getImpact
     *********************************************************************************************/
    public static getImpact(params: IWQImpactParams): Promise<IWQIndicators> {
        const query =
            (params.countryId ? `&countryId=${params.countryId}` : '') +
            `&totalImpact=${params.totalImpact}` +
            `&oneOff=${params.oneOff}` +
            (params.euFundedIds?.length ? `&fIsEuFunded=${params.euFundedIds.join(',')}` : '') +
            (params.baseYear ? `&baseYear=${params.baseYear}` : '') 
        return RequestService.request(EApps.DFM, 
            `/reports/wqImpact?groupBy=${params.aggregationType}${query}`,)
    }

    /**********************************************************************************************
     * @method getTransparencyReport
     *********************************************************************************************/
    public static getTransparencyReport(
        countryId: string, range: IMeasuresRange, roundSid?: number
    ): Promise<ITransparencyReport> {
        const query = roundSid ? `?roundSid=${roundSid}` : ''
        return RequestService.request(EApps.DFM, `/measures/tr/excel/${countryId}${query}`, 'post', range)
    }
}
