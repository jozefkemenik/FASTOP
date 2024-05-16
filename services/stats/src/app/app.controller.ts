import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { AppService } from './app.service'
import { IAccessInfo } from 'stats'


export class AppController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appService: AppService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method storeStatistics
     *********************************************************************************************/
    public async storeStatistics(stats: IAccessInfo): Promise<void> {
        // for 'accessToken' request split also by '?', e.g. '/api/accessToken?ip=false'
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        const [_, api, app, ...rest] = stats.url.split(/[/,?]/)

        // wq, fpapi and sdmx don't have the /api/ in url
        const appId = (['wq', 'fpapi', 'sdmx'].includes(api) ? api : app).toLowerCase()

        // endpoints that provide ameco data
        if (['ameco', 'wq', 'fpapi', 'addin'].includes(appId)) {
            const amecoType = this.getAmecoType(appId, stats.url)
            if (amecoType !== undefined) this.appService.logAmecoStats(appId, amecoType, stats)
        }

        this.appService.logAccessStats(stats.user, appId, stats.url, stats.ip, stats.intragate)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoType
     *********************************************************************************************/
    private getAmecoType(appId: string, url: string): AmecoType {
        // 'fpapi' is the new alias for 'wq'
        const isWqAmeco = (urlPart: string) => (appId === 'wq' || appId === 'fpapi') && url.includes(`/ameco${urlPart}`)

        if (url.includes('/restricted/seriesData') ||
            isWqAmeco('/restricted') ||
            isWqAmeco('/restricted_series')
        ) {
            return AmecoType.RESTRICTED
        } else if (url.includes('/public/seriesData') ||
            isWqAmeco('/public') ||
            isWqAmeco('/annex_series')
        ) {
            return AmecoType.PUBLIC
        } else if (url.includes('/current/seriesData') ||
            isWqAmeco('/current') ||
            isWqAmeco('/?') ||
            isWqAmeco('?') ||
            isWqAmeco('/series')
        ) {
            return AmecoType.CURRENT
        }
        else if (isWqAmeco('/online')) return AmecoType.ONLINE
        else return undefined
    }
}
