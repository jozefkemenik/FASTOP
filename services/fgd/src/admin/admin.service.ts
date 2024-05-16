import { BIND_OUT, CURSOR,  ISPOptions, NUMBER } from '../../../lib/dist/db'

import { FgdDbService } from '../db/db.service'

export class AdminService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
    * @method getAbolishedEntries
    *********************************************************************************************/
    public async getAbolishedEntries(
        appId: string
    ): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: NUMBER, value: appId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getAbolishedEntries',
        options)
        return dbResult.o_cur
    }
}