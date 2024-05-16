import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'

import { ICompliance, IComplianceCfg } from '.'
import { FgdDbService } from '../db/db.service'

export class ConfigService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getEstatValues
     *********************************************************************************************/
    public async getEstatValues(
        entrySid: number, periodSid: number, roundSid: number
    ): Promise<ICompliance[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await this.execSP(`cfg_accessors.getEurostatValues`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getComplianceCfg
     *********************************************************************************************/
    public async getComplianceCfg(
        entrySid: number
    ): Promise<IComplianceCfg[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await this.execSP(`cfg_accessors.getComplianceConfiguration`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getComplianceOptions
     *********************************************************************************************/
    public async getComplianceOptions(
        entrySid: number, periodSid: number, roundSid: number, year: number, periodDescr: string
    ): Promise<ICompliance[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_entry_sid', type: NUMBER, value: entrySid },
                { name: 'p_period_sid', type: NUMBER, value: periodSid },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_year', type: NUMBER, value: year },
                { name: 'p_period_descr', type: STRING, value: periodDescr },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await this.execSP(`cfg_accessors.getComplianceOptions`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getUserRule
     *********************************************************************************************/
    public async getUserRule(
        user: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getUserRule', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getUserApp
     *********************************************************************************************/
    public async getUserApp(
        user: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_accessors.getUserApp', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getIfis
     *********************************************************************************************/
    public async getIfis(): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getIfis', options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
