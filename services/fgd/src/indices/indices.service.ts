import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'

import { IIndicatorColumn } from '.'

import { FgdDbService } from '../db/db.service'

export class IndicesService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public async getIndicators(
        indexSid: number,
        multiEntry: number
    ): Promise<IIndicatorColumn[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_multi_entry', type: NUMBER, value: multiEntry},
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getIndicators' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method refreshIndView
     *********************************************************************************************/
     public async refreshIndView(
        indexSid: number, roundSid: number, countryId: string, roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.refreshIndView' , options)
        return dbResult.o_ret
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
