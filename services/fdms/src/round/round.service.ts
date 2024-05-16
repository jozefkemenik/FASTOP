import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

import {
    IBaseRoundInfo,
    ICustomRoundResult,
    IDBActivateRoundValidation,
    INewRoundResult,
    INewRoundValidation,
    INextRoundInfo,
    IPeriod,
} from '.'

export class RoundService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNextRoundInfo
     *********************************************************************************************/
    public async getNextRoundInfo(): Promise<INextRoundInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.getNextRoundInfo', options)
        return dbResult.o_cur && dbResult.o_cur.length === 1 ? dbResult.o_cur[0] : undefined
    }

    /**********************************************************************************************
     * @method getRounds
     *********************************************************************************************/
    public async getRounds(): Promise<IBaseRoundInfo[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.getRounds', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method checkNewRound
     *********************************************************************************************/
    public async checkNewRound(year: number, periodSid: number): Promise<INewRoundValidation> {
        const options: ISPOptions = {
            params: [
                { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                { name: 'p_period_sid', type: NUMBER, dir: BIND_IN, value: periodSid },
                { name: 'o_input_year_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_input_period_sid_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_storage_ok', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.checkNewRoundPreconditions', options)
        return {
            inputYearOk: dbResult.o_input_year_ok === 1,
            inputPeriodSidOk: dbResult.o_input_period_sid_ok === 1,
            storageOk: dbResult.o_storage_ok === 1,
        }
    }

    /**********************************************************************************************
     * @method createNewRound
     *********************************************************************************************/
    public async createNewRound(year: number, periodSid: number, roundDesc: string): Promise<INewRoundResult> {
        const options: ISPOptions = {
            params: [
                { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                { name: 'p_period_sid', type: NUMBER, dir: BIND_IN, value: periodSid },
                { name: 'p_desc', type: STRING, dir: BIND_IN, value: roundDesc },
                { name: 'o_input_year_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_input_period_sid_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_grid_round_app_id', type: STRING, dir: BIND_OUT },
                { name: 'o_grids_ok', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.createNewRound', options)
        return {
            inputYearOk: dbResult.o_input_year_ok === 1,
            inputPeriodSidOk: dbResult.o_input_period_sid_ok === 1,
            gridRoundAppId: dbResult.o_grid_round_app_id || undefined,
            gridsOk: dbResult.o_grid_round_app_id ? dbResult.o_grids_ok === 1 : undefined,
        }
    }

    /**********************************************************************************************
     * @method createCustomRound
     *********************************************************************************************/
    public async createCustomRound(
        year: number, periodSid: number, version: number, roundDesc: string
    ): Promise<ICustomRoundResult> {
        const options: ISPOptions = {
            params: [
                { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                { name: 'p_period_sid', type: NUMBER, dir: BIND_IN, value: periodSid },
                { name: 'p_version', type: NUMBER, dir: BIND_IN, value: version },
                { name: 'p_desc', type: STRING, dir: BIND_IN, value: roundDesc },
                { name: 'o_input_year_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_input_period_sid_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_input_version_ok', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.createCustomRound', options)
        return {
            inputYearOk: dbResult.o_input_year_ok === 1,
            inputPeriodSidOk: dbResult.o_input_period_sid_ok === 1,
            versionOk: dbResult.o_input_version_ok === 1,
        }
    }

    /**********************************************************************************************
     * @method checkRoundActivation
     *********************************************************************************************/
    public async checkRoundActivation(roundSid: number): Promise<IDBActivateRoundValidation> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'o_round_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_storage_ok', type: NUMBER, dir: BIND_OUT },
                { name: 'o_app_status_cur', type: CURSOR, dir: BIND_OUT },

            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.checkActivateRound', options)
        return {
            roundOk: dbResult.o_round_ok === 1,
            storageOk: dbResult.o_storage_ok === 1,
            appStatus: dbResult.o_app_status_cur
        }
    }

    /**********************************************************************************************
     * @method activateRound
     *********************************************************************************************/
    public async activateRound(roundSid: number, user: string): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.activateRound', options)
        return dbResult.o_res > 0
    }


    /**********************************************************************************************
     * @method getPeriods
     *********************************************************************************************/
    public async getPeriods(): Promise<IPeriod[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.getPeriods', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getLatestRoundVersion
     *********************************************************************************************/
    public async getLatestRoundVersion(year: number, periodSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                { name: 'p_period_sid', type: NUMBER, dir: BIND_IN, value: periodSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.getLatestVersion', options)
        return dbResult.o_res ?? -1
    }
}
