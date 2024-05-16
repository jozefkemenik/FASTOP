import { IError } from '../../../lib/dist'

import { ILdapInfo } from './shared-interfaces'
import { UserService } from './user.service'

export class UserController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private userService: UserService) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
    * @method getLdapInfo
     *********************************************************************************************/
    public async getLdapInfo(
        email: string
    ) {
        return this.userService.getLdapInfo(email).catch(
            (err: IError) => {
                err.method = 'SumUserController.getLdapInfo'
                throw err
            })
    }

    /**********************************************************************************************
    * @method searchProvisioned
     *********************************************************************************************/
    public async searchProvisioned(
        ecasId: string
    ) {
        const result = await this.userService.searchProvisioned(ecasId).catch(
            (err: IError) => {
                err.method = 'SumUserController.searchProvisioned'
                throw err
            })
        if (result.length) {
            if (result[0].USER_ID === ecasId) {
                return 2
            } else {
                return -1
            }
        } else return 0
    }

    /**********************************************************************************************
    * @method addUser
     *********************************************************************************************/
    public async addUser(
        user: ILdapInfo
    ) {
        return this.userService.addUser(user).catch(
            (err: IError) => {
                err.method = 'SumUserController.addUser'
                throw err
            })
    }
}
