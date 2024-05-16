import { BIND_OUT, CURSOR, DATE, ISPOptions, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { EStatementTypes } from '../db'
import { SumDbService } from '../db/sum.db.service'

import { ILdapInfo } from '.'
import { config } from '../../../config/config'

export class UserService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly dbService: SumDbService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getLdapInfo
     *********************************************************************************************/
    public async getLdapInfo(email: string): Promise<ILdapInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'p_ldap_host', type: STRING, value: config.ldap.ldapHost},
                { name: 'p_ldap_port', type: STRING, value: config.ldap.ldapPort},
                { name: 'p_ldap_user', type: STRING, value: config.ldap.ldapUser},
                { name: 'p_ldap_passwd', type: STRING, value: config.ldap.ldapPass },
                { name: 'p_ldap_base', type: STRING, value: config.ldap.ldapBase },
                { name: 'p_email', type: STRING, value: email },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ]
        }
        const dbResult = await DataAccessApi.execSP(`um_authz_accessors.getLdapUser`, options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method searchProvisioned
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async searchProvisioned(ecasId: string): Promise<any[]> {
        const options: ISPOptions = {
            params: [
                { name: 'USER_ID', type: STRING, value: ecasId},
            ]
        }
        const dbResult = await this.dbService.execStat(EStatementTypes.SELECT, 'CUD.ECFIN_EXT_USERS_T', 'USER_ID',
            options)
        return dbResult
    }

    /**********************************************************************************************
     * @method addUser
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async addUser(user: ILdapInfo): Promise<any> {
        const options: ISPOptions = {
            params: [
                { name: 'USER_ID', type: STRING, value: user.ecasUid},
                { name: 'ORG_CD', type: STRING, value: 'ECFIN-EXT.PUBLIC.MS'},
                { name: 'FIRST_NAME', type: STRING, value: user.firstName},
                { name: 'LAST_NAME', type: STRING, value: user.lastName},
                { name: 'EMAIL', type: STRING, value: user.email},
                { name: 'LAST_UPDATED', type: DATE, value: new Date()}
            ],
            skipLogs: false
        }

        const dbResult = await this.dbService.execStat(EStatementTypes.INSERT, 'CUD.ECFIN_EXT_USERS_T', null, options)
        return dbResult
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
