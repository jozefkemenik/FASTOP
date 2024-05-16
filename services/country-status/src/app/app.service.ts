import { EApps } from 'config'

import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

import { IDBCommandResult, IDBCountryStatus, IDBCtyAccepted, IDBCtyRoundComment, IDBCtyStatusChanges, ISetCountryStatus } from '.'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

export class AppService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly packageName = 'st_country_status'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryRoundComments
     *********************************************************************************************/
    public async getCountryRoundComments(
        appId: EApps, countryId: string, roundSid: number
    ): Promise<IDBCtyRoundComment[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_country_id', type: STRING, value: countryId },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`st_status_comments.getCountryRoundComments`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCountryAcceptedDates
     *********************************************************************************************/
    public async getCountryAcceptedDates(
        appId: EApps, countries: string[], onlyFullStorage: boolean, onlyFullRound: boolean,
    ): Promise<IDBCtyAccepted[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_country_ids', type: STRING, value: countries ?? [] },
                { name: 'p_only_full_storage', type: NUMBER, value: Number(onlyFullStorage) },
                { name: 'p_only_full_round', type: NUMBER, value: Number(onlyFullRound) },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.packageName}.getCountryAcceptedDates`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getStatusChanges
     *********************************************************************************************/
    public async getStatusChanges(countries: string[], roundKeys: IRoundKeys): Promise<IDBCtyStatusChanges[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_ids', type: STRING, value: countries ?? [] },
                { name: 'p_round_sid', type: NUMBER, value: roundKeys.roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.packageName}.getCtyStatusChanges`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getStatuses
     *********************************************************************************************/
    public async getStatuses(
        appId: EApps, countries: string[], roundKeys: IRoundKeys
    ): Promise<IDBCountryStatus[]> {

        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_country_ids', type: STRING, value: countries ?? [] },
                { name: 'p_round_sid', type: NUMBER, value: roundKeys.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: roundKeys.storageSid || null },
                { name: 'p_cust_text_sid', type: NUMBER, value: roundKeys.custTextSid || null },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.packageName}.getCountryStatuses`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method setCountryStatus
     *********************************************************************************************/
    public async setCountryStatus(
        appId: EApps, countryId: string, setStatus: ISetCountryStatus, sendMail: boolean,
    ): Promise<IDBCommandResult> {

        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_old_status_id', type: STRING, value: setStatus.oldStatusId },
                { name: 'p_new_status_id', type: STRING, value: setStatus.newStatusId },
                { name: 'p_user', type: STRING, value: setStatus.userId },
                { name: 'p_comment', type: STRING, value: setStatus.comment ?? null },
                { name: 'p_send_mail', type: NUMBER, value: sendMail ? 1 : 0 },
                { name: 'p_round_sid', type: NUMBER, value: setStatus.roundKeys.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: setStatus.roundKeys.storageSid || null },
                { name: 'p_cust_text_sid', type: NUMBER, value: setStatus.roundKeys.custTextSid || null },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.packageName}.setCountryStatus`, options)
        return [dbResult.o_res, dbResult.o_cur[0]]
    }

    /**********************************************************************************************
     * @method setManyCountriesStatus
     *********************************************************************************************/
    public async setManyCountriesStatus(
        appId: EApps, countries: string[], setStatus: ISetCountryStatus
    ): Promise<number> {

        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_country_ids', type: STRING, value: countries ?? []},
                { name: 'p_new_status_id', type: STRING, value: setStatus.newStatusId },
                { name: 'p_user', type: STRING, value: setStatus.userId },
                { name: 'p_comment', type: STRING, value: setStatus.comment ?? null },
                { name: 'p_round_sid', type: NUMBER, value: setStatus.roundKeys.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: setStatus.roundKeys.storageSid || null },
                { name: 'p_cust_text_sid', type: NUMBER, value: setStatus.roundKeys.custTextSid || null },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.packageName}.setManyCountriesStatus`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setStatusChangeDate
     *********************************************************************************************/
    public async setStatusChangeDate(countryId: string, roundSid: number, statusChange: string): Promise<undefined> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_country_id', type: STRING, value: countryId },
            ],
        }
        await DataAccessApi.execSP(`st_status_changes.set${statusChange}Date`, options)
        return
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
