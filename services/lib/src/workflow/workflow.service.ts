import { EApps } from 'config'

import { BIND_OUT, ISPOptions, NUMBER, STRING } from '../db'
import { DataAccessApi } from '../api'

export class LibWorkflowService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(protected readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method openApplication
     *********************************************************************************************/
    public async openApplication(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_app_status.setApplicationOpen', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method closeApplication
     *********************************************************************************************/
    public async closeApplication(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_app_status.setApplicationClosed', options)
        return dbResult.o_res
    }
}
