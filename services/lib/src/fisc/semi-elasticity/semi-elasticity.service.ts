import { EApps } from 'config'

import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { ISemiElasticityData } from '../shared/shared-interfaces'
import { SharedLibService } from '../shared/shared-lib.service'

export class SemiElasticityService extends SharedLibService {

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
     * @method storeElasticity
     *********************************************************************************************/
    public async storeElasticity(roundSid: number, countries: string[], values: number[]): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: this.appId },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_countries', type: STRING, dir: BIND_IN, value: countries },
                { name: 'p_values', type: NUMBER, dir: BIND_IN, value: values },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_semi_elasticity.storeSemiElasticity', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getElasticityData
     *********************************************************************************************/
     public async getElasticityData(): Promise<ISemiElasticityData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_semi_elasticity.getLatestSemiElasticity', options)
        return dbResult.o_cur
    }

}
