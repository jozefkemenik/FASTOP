import { ICompressedData, IIndicatorData, ITceMatrixData } from '../shared-interfaces'
import { ITcePartner, ITceTradeItem } from './shared-interfaces'
import { ICountry } from '../../../../lib/dist/menu'
import { TceService } from './tce.service'
import { catchAll } from '../../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class TceController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly tceService: TceService,
    ) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(roundSid?: number, storageSid?: number, ): Promise<ICountry[]> {
        return this.tceService.getTceResultsCountries(roundSid, storageSid)
    }

    /**********************************************************************************************
     * @method getPartners
     *********************************************************************************************/
    public async getPartners(): Promise<ITcePartner[]> {
        return this.tceService.getPartners()
    }

    /**********************************************************************************************
     * @method getTradeItems
     *********************************************************************************************/
    public async getTradeItems(): Promise<ITceTradeItem[]> {
        return this.tceService.getTradeItems().then(
            (dbItems) => dbItems.map(dbItem =>
                ({
                    name: dbItem.DESCR.replace('{CURRENCY}', 'National currency'),
                    goods: { indicatorId: dbItem.GN_INDICATOR_ID, partner: dbItem.GN_DATA_TYPE },
                    services: { indicatorId: dbItem.SN_INDICATOR_ID, partner: dbItem.SN_DATA_TYPE },
                    goodsAndServices: { indicatorId: dbItem.GS_INDICATOR_ID, partner: dbItem.GS_DATA_TYPE },
                })
            )
        )
    }

    /**********************************************************************************************
     * @method getMatrixData
     *********************************************************************************************/
    public async getMatrixData(
        providerId: string, roundSid: number, storageSid: number,
    ): Promise<ITceMatrixData[]> {
        return this.tceService.getMatrixData(providerId, roundSid, storageSid).then(
            dbData => Array.from(
                dbData.reduce((curr, val) => {
                    const expCtyId = val.EXPORTER_CTY_ID
                    if (!curr.has(expCtyId)) curr.set(expCtyId, { expCtyId, partners: [] })
                    curr.get(expCtyId).partners.push({ ctyId: val.PARTNER_CTY_ID, value: Number(val.VALUE) })

                    return curr
                }, new Map<string, ITceMatrixData>()).values()
            )
        )
    }

    /**********************************************************************************************
     * @method getTceData
     *********************************************************************************************/
    public async getTceData(
        countryIds: string[], indicatorIds: string[], partnerIds: string[],
        roundSid: number, storageSid: number, compress?: boolean
    ): Promise<IIndicatorData[] | ICompressedData> {
        return this.tceService.getTceResultsData(
            countryIds, indicatorIds, partnerIds, 'A', roundSid, storageSid, compress,
        )
    }

    /**********************************************************************************************
     * @method getTceTradeItemsData
     *********************************************************************************************/
    public async getTceTradeItemsData(
        countryIds: string[], tradeItemIds: string[],
        roundSid: number, storageSid: number, compress?: boolean
    ): Promise<IIndicatorData[] | ICompressedData> {
        return this.tceService.getTceTradeItemsData(
            countryIds, tradeItemIds, 'A', roundSid, storageSid, compress,
        )
    }

}
