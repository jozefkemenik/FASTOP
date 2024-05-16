import { ITcePartner, ITceTradeItem } from '../../../fdms/src/report/tce/shared-interfaces'
import { EApps } from 'config'
import { ICompressedData } from '../../../fdms/src/report/shared-interfaces'
import { ICountry } from '../menu'
import { RequestService } from '../request.service'

export class TceApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public static methods //////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public static getCountries(roundSid?: number, storageSid?: number): Promise<ICountry[]> {
        const params = roundSid && storageSid ? `${roundSid}/${storageSid}` : ''
        return RequestService.request(
            EApps.FDMS, `/reports/tce/countries/${params}`,
        )
    }

    /**********************************************************************************************
     * @method getTradeItems
     *********************************************************************************************/
    public static getTradeItems(): Promise<ITceTradeItem[]> {
        return RequestService.request(
            EApps.FDMS, `/reports/tce/tradeItems`,
        )
    }

    /**********************************************************************************************
     * @method getPartners
     *********************************************************************************************/
    public static getPartners(): Promise<ITcePartner[]> {
        return RequestService.request(
            EApps.FDMS, `/reports/tce/partners`,
        )
    }

    /**********************************************************************************************
     * @method getDataCompressedByTradeFlows
     *********************************************************************************************/
    public static getDataCompressedByTradeFlows(
        countryIds: string[], tradeItemIds: string[],
        roundSid: number, storageSid: number, textSid: number
    ): Promise<ICompressedData> {

        const url = `/reports/tce/data/tradeItems/${roundSid}/${storageSid}/${textSid ? textSid : ''}`
            + `?compress=true`

        return RequestService.request(EApps.FDMS, url, 'post', { countryIds, tradeItemIds })
    }

    /**********************************************************************************************
     * @method getDataCompressed
     *********************************************************************************************/
    public static getDataCompressed(
        countryIds: string[], indicatorIds: string[], partnerIds: string[],
        roundSid: number, storageSid: number, textSid: number
    ): Promise<ICompressedData> {

        const url = `/reports/tce/data/${roundSid}/${storageSid}/${textSid ? textSid : ''}`
            + `?compress=true`

        return RequestService.request(EApps.FDMS, url, 'post', { countryIds, indicatorIds, partnerIds })
    }
}
