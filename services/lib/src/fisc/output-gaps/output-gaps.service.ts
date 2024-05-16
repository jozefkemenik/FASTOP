import { EApps } from 'config'

import { BIND_IN, BIND_OUT, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { SharedCalcService } from '../shared/calc/shared-calc.service'

export class LibOutputGapsService extends SharedCalcService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkBaselineData
     *********************************************************************************************/
    public async checkBaselineData(roundSid: number, countryId: string): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.hasBaselineData', options)
        return dbResult.o_res && dbResult.o_res > 0
    }

    /**********************************************************************************************
     * @method checkCountryParamsData
     *********************************************************************************************/
    public async checkCountryParamsData(roundSid: number, countryId: string): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.hasCountryParamsData', options)
        return dbResult.o_res && dbResult.o_res > 0
    }

    /**********************************************************************************************
     * @method updateYearsRange
     *********************************************************************************************/
    public async updateYearsRange(yearsRange: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_years_range', type: NUMBER, value: yearsRange },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.updateYearsRange', options)
        return dbResult.o_res
    }
}
