import { BIND_OUT, CURSOR, ISPOptions } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

import { IDBAuthzCountry, IDBAuthzGroup } from '.'

export class AuthzService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAuthzCountries
     *********************************************************************************************/
    public async getAuthzCountries(): Promise<IDBAuthzCountry[]> {
        const options: ISPOptions = {
            params: [
                {name: 'o_res', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('um_authz_accessors.getAuthzCountries', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getAuthzGroups
     *********************************************************************************************/
    public async getAuthzGroups(): Promise<IDBAuthzGroup[]> {
        const options: ISPOptions = {
            params: [
                {name: 'o_res', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('um_authz_accessors.getAuthzGroups', options)
        return dbResult.o_res
    }
}
