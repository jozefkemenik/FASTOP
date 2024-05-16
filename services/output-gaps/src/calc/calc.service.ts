import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { SharedCalcService } from '../../../lib/dist/fisc/shared/calc/shared-calc.service'

export class CalcService extends SharedCalcService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getOutputGapParams
     *********************************************************************************************/
    public async getOutputGapParam(roundSid: number, paramId: string): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_parameter_id', type: STRING, value: paramId },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getParameter', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getOgBaselineParams
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async getOgBaselineParamsData(roundSid: number, countries: string[]): Promise<any[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_country_ids', type: STRING, value: countries },

            ],
            arrayFormat: true,
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getBaselineData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getOgCountryParams
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async getOgCountryParamsData(roundSid: number, countries: string[]): Promise<any[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_country_ids', type: STRING, value: countries },

            ],
            arrayFormat: true,
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getCountryParamsData', options)
        return dbResult.o_cur
    }
}
