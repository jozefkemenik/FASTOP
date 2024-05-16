import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { FDSharedService } from '../../../lib/dist/measure/fisc-drm/shared/fd-shared.service'
import { ICountryCurrencyInfo } from '../../../lib/dist/measure/config'
import { LibMenuService } from '../../../lib/dist/menu/menu.service'

export class SharedService extends FDSharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly _menuService: LibMenuService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this._menuService = new LibMenuService(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get menuService() {
        return this._menuService
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getLatestRound
     *********************************************************************************************/
    public async getLatestRound(roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: this.menuService.app },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('CORE_GETTERS.getLatestApplicationRound', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method isApplicationInRound
     * TODO: This is wrong approach. Apps should not look into other apps specifics.
     * Instead the other app should expose an api call which could provide the necessary information.
     *********************************************************************************************/
     public async isApplicationInRound(appId: EApps, roundSid: number): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: appId },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('CORE_COMMONS.isApplicationInRound', options)
        return dbResult.o_res === 1
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fetchCountryCurrencyInfo
     *********************************************************************************************/
    protected async fetchCountryCurrencyInfo(
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        countryId: string, roundSid: number, version: number
    ): Promise<ICountryCurrencyInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('drm_getters.getCountryCurrency', options)
        return dbResult.o_cur[0]
    }
}
