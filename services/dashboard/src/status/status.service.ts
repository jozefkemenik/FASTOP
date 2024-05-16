import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import { BIND_OUT, ISPOptions, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

export class StatusService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getApplicationStatusId
     *********************************************************************************************/
    public async getApplicationStatusId(appId: EApps): Promise<EStatusRepo> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'o_status_id', type: STRING, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getApplicationStatus', options)
        return dbResult.o_status_id
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
