import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

import { IDBAction, IMailNotification } from '.'

export class MailService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _actions: IDBAction[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActions
     *********************************************************************************************/
    public async getActions(): Promise<IDBAction[]> {
        if (!this._actions) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('st_country_status.getActions', options)
            this._actions = dbResult.o_cur
        }
        return this._actions
    }

    /**********************************************************************************************
     * @method getMailRecipients
     *********************************************************************************************/
    public async getMailRecipients(notification: IMailNotification): Promise<[string[], string[]]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: notification.appId },
                { name: 'p_country_id', type: STRING, value: notification.countryId ?? null },
                { name: 'p_action_sid', type: NUMBER, value: notification.actionSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'o_inherited_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true,
        }
        const dbResult = await DataAccessApi.execSP('st_mail.getMailRecipients', options)
        return [dbResult.o_cur.map(row => row[0]), dbResult.o_inherited_cur.map(row => row[0])]
    }

    /**********************************************************************************************
     * @method manageMailRecipient
     *********************************************************************************************/
    public async manageMailRecipient(
        action: 'add'|'delete', notification: IMailNotification, email: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: notification.appId },
                { name: 'p_country_id', type: STRING, value: notification.countryId ?? null },
                { name: 'p_action_sid', type: NUMBER, value: notification.actionSid },
                { name: 'p_email', type: STRING, value: email },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`st_mail.${action}MailRecipient`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method updateMailRecipient
     *********************************************************************************************/
    public async updateMailRecipient(
        notification: IMailNotification, email: string, newEmail: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: notification.appId },
                { name: 'p_country_id', type: STRING, value: notification.countryId ?? null },
                { name: 'p_action_sid', type: NUMBER, value: notification.actionSid },
                { name: 'p_email', type: STRING, value: email },
                { name: 'p_new_email', type: STRING, value: newEmail },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`st_mail.updateMailRecipient`, options)
        return dbResult.o_res
    }
}
