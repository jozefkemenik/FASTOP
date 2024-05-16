import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { ENotificationProvider, ITemplateParams } from 'notification'
import { DataAccessApi } from '../../../lib/dist/api'
import { IDBMailTemplate } from '.'


export class SharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logMailSent
     *********************************************************************************************/
    public async logMailSent(
        to: string[], cc: string[], bcc: string[], subject: string, body: string,
        user: string, result: string, failed: boolean, senderAppId: string,
    ): Promise<number> {

        return this.logNotificationSent(ENotificationProvider.MAIL,
            to, cc, bcc, subject, body, user, result, failed, senderAppId
        )
    }

    /**********************************************************************************************
     * @method logCnsSent
     *********************************************************************************************/
    public async logCnsSent(
        to: string[], cc: string[], bcc: string[], subject: string, body: string,
        user: string, result: string, failed: boolean, senderAppId: string,
    ): Promise<number> {

        return this.logNotificationSent(ENotificationProvider.CNS,
            to, cc, bcc, subject, body, user, result, failed, senderAppId
        )
    }

    /**********************************************************************************************
     * @method getTemplate
     *********************************************************************************************/
    public async getTemplate(templateId: string): Promise<IDBMailTemplate> {
        const options: ISPOptions = {
            params: [
                { name: 'p_template_id', type: STRING, value: templateId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        return DataAccessApi.execSP(`notification_template.getTemplate`, options).then(dbResult => dbResult.o_cur[0])
    }

    /**********************************************************************************************
     * @method populateTemplateParams
     *********************************************************************************************/
    public populateTemplateParams(template: string, params: ITemplateParams): string {
        let result = template
        if (params) {
            Object.keys(params).forEach(key => {
                result = result.replace(key, params[key])
            })
        }

        return result
    }

    /**********************************************************************************************
     * @method parseRecipients
     *********************************************************************************************/
    public parseRecipients(data: string): string[] {
        return data !== null && data !== undefined ? data.split(';') : undefined
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logNotificationSent
     *********************************************************************************************/
    private async logNotificationSent(
        provider: ENotificationProvider,
        to: string[], cc: string[], bcc: string[], subject: string, body: string,
        user: string, result: string, failed: boolean, senderAppId: string,
    ): Promise<number> {

        const arrToStr = (arr: string[]) => arr ? arr.join(';') : ''
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_provider', type: STRING, value: provider},
                { name: 'p_recipients', type: STRING, value: arrToStr(to)},
                { name: 'p_cc_recipients', type: STRING, value: arrToStr(cc) },
                { name: 'p_bcc_recipients', type: STRING, value: arrToStr(bcc) },
                { name: 'p_subject', type: STRING, value: subject },
                { name: 'p_body', type: STRING, value: body },
                { name: 'p_user_id', type: STRING, value: user },
                { name: 'p_result', type: STRING, value: result },
                { name: 'p_failed', type: NUMBER, value: Number(failed) },
                { name: 'p_sender_app', type: STRING, value: senderAppId || null },
            ],
        }
        return DataAccessApi.execSP('notification_log.logNotificationSent', options).then(dbResult => dbResult.o_res)
    }

}
