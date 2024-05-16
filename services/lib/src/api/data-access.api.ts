import { DAType, EApps } from 'config'

import { ISPOptions } from '../db'
import { RequestService } from '../request.service'

export class DataAccessApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method execSP execute stored procedure
     *********************************************************************************************/
    public static execSP(sp: string, options: ISPOptions, daApp: DAType = EApps.DA) {
        return RequestService.request(daApp, `/exec/${sp}`, 'post', options)
    }

    /**********************************************************************************************
     * @method getDbServer
     *********************************************************************************************/
    public static getDbServer() {
        return RequestService.request(EApps.DA, `/config/dbServer`)
    }
}
