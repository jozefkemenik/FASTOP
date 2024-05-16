import { AdminService } from './admin.service'
import { SharedService } from '../shared/shared.service'

import { EApps } from 'config'
import { IError } from '../../../lib/dist'

export class AdminController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private appId: EApps, private adminService: AdminService, private sharedService: SharedService) { }

    /**********************************************************************************************
    * @method getAbolishedEntries
    *********************************************************************************************/
    public getAbolishedEntries(
    appId: string
    ) {
        return this.adminService.getAbolishedEntries(appId).catch(
            (err: IError) => {
                err.method = 'EntriesController.getCountryByEntry'
                throw err
            }
        )
    }
}