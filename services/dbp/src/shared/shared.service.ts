import { EApps } from 'config'

import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { FDSharedService } from '../../../lib/dist/measure/fisc-drm/shared/fd-shared.service'
import { ICountryCurrencyInfo } from '../../../lib/dist/measure'
import { MenuService } from '../../../lib/dist/fisc'

import { IDictionaries } from '.'
import { IMeasureDetails } from '../measure'

export class SharedService extends FDSharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly _menuService: MenuService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this._menuService = new MenuService(appId)
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
     * @method getColumnValue
     *********************************************************************************************/
    public getColumnValue(
        column: string, row: IMeasureDetails, dictionaries: IDictionaries
    ): string | number {
        switch (column) {
            case 'SOURCE_DESCR':
                return dictionaries.dbpSources[row.SOURCE_SID]
            default:
                return super.getColumnValue(column, row, dictionaries)
        }
    }

    /**********************************************************************************************
     * @method getDictionaries
     *********************************************************************************************/
    public getDictionaries(roundSid: number): Promise<IDictionaries> {
        roundSid = roundSid || 0
        return Promise.all([
            super.getDictionaries(roundSid),
            this.getDbpSources(),
        ]).then( ([baseDictionary, dbpSources]) =>
            ({...baseDictionary, dbpSources}))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fetchCountryCurrencyInfo
     *********************************************************************************************/
    protected async fetchCountryCurrencyInfo(
        countryId: string, roundSid: number, version: number
    ): Promise<ICountryCurrencyInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_version', type: NUMBER, value: !isNaN(version) && version > 0 ? version : undefined },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dbp_getters.getCountryCurrency', options)
        return dbResult.o_cur[0]
    }
}
