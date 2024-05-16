import { ITcePartner, ITceTradeItem } from '../../../../fdms/src/report/tce/shared-interfaces'
import { FdmsController } from '../shared/fdms.controller'
import { ICountry } from '../../../../lib/dist/addin/shared-interfaces'
import { IFdmsAddinData } from '../shared/shared-interfaces'
import { TceApi } from '../../../../lib/dist/api/tce.api'
import { catchAll } from '../../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class TceController extends FdmsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTceCountries
     *********************************************************************************************/
    public async getTceCountries(): Promise<ICountry[]> {
        return TceApi.getCountries().then(
            countries => countries.map(c => ({ COUNTRY_ID: c.COUNTRY_ID, NAME: c.DESCR }))
        )
    }

    /**********************************************************************************************
     * @method getTradeItems
     *********************************************************************************************/
    public async getTradeItems(): Promise<ITceTradeItem[]> {
        return TceApi.getTradeItems()
    }

    /**********************************************************************************************
     * @method getPartners
     *********************************************************************************************/
    public async getPartners(): Promise<ITcePartner[]> {
        return TceApi.getPartners()
    }

    /**********************************************************************************************
     * @method getTceDataByTradeItems
     *********************************************************************************************/
    public async getTceDataByTradeItems(
        countries: string[], tradeItemIds: string[],
        roundSid: number, storageSid: number, textSid: number
    ): Promise<IFdmsAddinData> {

        return this.getData(
            TceApi.getDataCompressedByTradeFlows(
                countries, tradeItemIds, roundSid, storageSid, textSid,
            ),
            undefined, roundSid, storageSid, textSid
        )
    }

    /**********************************************************************************************
     * @method getTceData
     *********************************************************************************************/
    public async getTceData(
        countryIds: string[], indicatorIds: string[], partnerIds: string[],
        roundSid: number, storageSid: number, textSid: number
    ): Promise<IFdmsAddinData> {
        return this.getData(
            TceApi.getDataCompressed(
                countryIds, indicatorIds, partnerIds, roundSid, storageSid, textSid,
            ),
            undefined, roundSid, storageSid, textSid
        )
    }
}
