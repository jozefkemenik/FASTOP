import { EApps } from 'config'

import { BIND_OUT, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { DxmDashboardService } from '../../../lib/dist/dxm'

import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

export class DashboardService extends DxmDashboardService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super(EApps.DFM)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archiveCountry
     *********************************************************************************************/
     public async archiveCountry(countryId: string, roundKeys: IRoundKeys, user: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundKeys.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: roundKeys.storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: null },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_country_status.archiveCountryMeasures', options)
        return  dbResult.o_res
    }
}
