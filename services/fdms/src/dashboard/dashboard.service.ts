import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { IDBUploadDate } from '.'


export class DashboardService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryUploads
     *********************************************************************************************/
    public async getCountryUploads(
        appId: string, countries: string[], roundSid?: number, storageSid?: number
    ): Promise<IDBUploadDate[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_country_ids', type: STRING, value: countries ?? []},
                { name: 'p_round_sid', type: NUMBER, value: roundSid || null},
                { name: 'p_storage_sid', type: NUMBER, value: storageSid || null },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`fdms_upload.getCountryUploadsInfo`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method transferAmecoIndicatorsToScopax
     *********************************************************************************************/
     public async transferAmecoIndicatorsToScopax(roundSid: number, storageSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid},
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`fdms_indicator.transferAmecoToScopax`, options)
        return dbResult.o_res
    }
}
