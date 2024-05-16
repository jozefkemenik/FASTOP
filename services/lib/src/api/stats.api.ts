import { EApps } from 'config'
import { IAccessInfo } from 'stats'
import { RequestService } from '../request.service'

export class StatsApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logStats
     *********************************************************************************************/
    public static logStats(stats: IAccessInfo): Promise<number> {
        return RequestService.request(EApps.STATS, '/', 'post', stats)
    }
}
