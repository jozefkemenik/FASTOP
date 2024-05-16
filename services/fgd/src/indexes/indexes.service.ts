import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'

import { IDBCountryIdxCalcStage, IDBHorizontalColumn, IDBHorizontalStage } from '.'
import { FgdDbService } from '../db/db.service'

export class IndexesService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getCountryStages
     *********************************************************************************************/
    public async getCountryStages(
        indexSid: number, countryId: string, roundSid: number
    ): Promise<IDBCountryIdxCalcStage[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getCountryIdxCalculationStages' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getHorizontalStages
     *********************************************************************************************/
    public async getHorizontalStages(
        appId: string, indexSid: number, roundSid: number, roundYear: number
    ): Promise<IDBHorizontalStage[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId},
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getHorizontalIdxCalcStages' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method refreshHorizView
     *********************************************************************************************/
     public async refreshHorizView(
        appId: string, indexSid: number, roundSid: number, roundYear: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId},
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_round_year', type: NUMBER, value: roundYear },
                { name: 'o_ret', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.refreshHorizView' , options)
        return dbResult.o_ret
    }

    /**********************************************************************************************
     * @method getHorizontalColumns
     *********************************************************************************************/
    public async getHorizontalColumns(
        indexSid: number, roundSid: number
    ): Promise<IDBHorizontalColumn[]> {
        const options: ISPOptions = {
            params: [
                { name: 'pi_index', type: NUMBER, value: indexSid },
                { name: 'pi_round', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.getHorizontalColumns' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method deleteCountryIdxCalculationStage
     *********************************************************************************************/
    public async deleteCountryIdxCalculationStage(
        indexSid: number, countryId: string, roundSid: number, stageSid: number
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_index_sid', type: NUMBER, value: indexSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_stage_sid', type: NUMBER, value: stageSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_scores.delCountryIdxCalculationStage' , options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
