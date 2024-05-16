import { BIND_OUT, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { Level, LoggingService } from '../../../lib/dist'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { DataAccessApi } from '../../../lib/dist/api'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { IAccessInfo } from 'stats'


export class AppService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly logs: LoggingService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logAmecoStats
     *********************************************************************************************/
    public logAmecoStats(appId: string, amecoType: AmecoType, stats: IAccessInfo) {
        ExternalDataApi.logStatistics({
            userId: stats.user,
            source: `fastop-${appId}`,
            agent: stats.agent,
            addr: stats.ip,
            amecoType: amecoType,
            uri: stats.url,
        }).catch(err => {
            this.logs.log(`Error when logging ameco stats: ${err}`, Level.ERROR)
        })
    }

    /**********************************************************************************************
     * @method logAccessStats
     *********************************************************************************************/
    public logAccessStats(userId: string, appId: string, uri: string, ip: string, intragate: boolean) {
        this.logStats(userId, appId, uri, ip, Number(intragate)).catch(err => {
            this.logs.log(`Error when logging access stats: ${err}`, Level.ERROR)
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logStats
     *********************************************************************************************/
    private async logStats(
        userId: string, appId: string, uri: string, ip: string, intragate: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: userId || 'anonymous'},
                { name: 'p_app', type: STRING, value: appId },
                { name: 'p_uri', type: STRING, value: uri },
                { name: 'p_ip', type: STRING, value: ip },
                { name: 'p_intragate', type: NUMBER, value: intragate },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        return DataAccessApi.execSP('stats_access.logAccess', options).then(dbResult => dbResult.o_res)
    }
}
