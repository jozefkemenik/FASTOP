import { EApps } from 'config'

import { BIND_OUT, DATE, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'

export class FiscDashboardService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDashboardGlobalDates
     *********************************************************************************************/
    public async getDashboardGlobalDates(): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'o_ameco', type: DATE, dir: BIND_OUT },
                { name: 'o_linked_tables', type: DATE, dir: BIND_OUT },
                { name: 'o_fiscal_parameters', type: DATE, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_country_status.getDashboardGlobalDates', options)
        return [dbResult.o_ameco, dbResult.o_linked_tables, dbResult.o_fiscal_parameters]
    }

    /**********************************************************************************************
     * @method presubmitCheck
     *********************************************************************************************/
    public async presubmitCheck(countryId: string, roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`gd_commons.hasAnyGridData`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method hasMissingData
     *********************************************************************************************/
    public async hasMissingData(countryId: string, roundSid: number): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`gd_commons.hasMissingData`, options)
        return dbResult.o_res > 0
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
