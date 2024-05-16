import { EApps } from 'config'
import { ICountryStatus } from 'country-status'

import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'
import { catchAll } from '../../../lib/dist/catch-decorator'

import { IRoundKeys } from '../config'
import { StatusService } from './status.service'

@catchAll('StatusController')
export class StatusController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly statusService: StatusService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getApplicationStatus
     *********************************************************************************************/
    public getApplicationStatus(appId: EApps) {
        return this.statusService.getApplicationStatusId(appId)
    }

    /**********************************************************************************************
     * @method getCountryComments
     *********************************************************************************************/
    public getCountryComments(appId: EApps, countryId: string, roundSid: number) {
        return CountryStatusApi.getCountryComments(appId, countryId, roundSid)
    }

    /**********************************************************************************************
     * @method getCountryStatus
     *********************************************************************************************/
    public getCountryStatus(appId: EApps, countryId: string, roundKeys: IRoundKeys) {
        return CountryStatusApi.getCountryStatusId(appId, countryId, roundKeys)
    }

    /**********************************************************************************************
     * @method getMultiCountryStatuses
     *********************************************************************************************/
    public getMultiCountryStatuses(appId: EApps, countries: string[]): Promise<Array<Partial<ICountryStatus>>> {
        return CountryStatusApi.getCountryStatuses(appId, countries).then(
            statuses => statuses.map(({countryId, countryDescr, statusId}) => ({countryId, countryDescr, statusId})),
        )
    }
}
