import { BIND_OUT, CURSOR, ISPOptions, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { IDBAccessLog } from '.'


export class LogService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

     /**********************************************************************************************
     * @method getAccessLogs
     *********************************************************************************************/
     public async getAccessLogs(): Promise<IDBAccessLog[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            fetchInfo: { URI: { type: STRING } }
        }

        const dbResult = await DataAccessApi.execSP('fpadmin_log.getAccessLogs', options)
        return dbResult.o_cur
    }
}
