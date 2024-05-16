import {
    ENotificationTemplate,
    ICnsClientSystemDetails,
    ICnsNotification,
    ICnsNotificationStatus, ICnsNotificationTemplate,
    ICnsReferenceType,
    IEMail,
    INotificationTemplate,
} from 'notification'
import { EApps } from 'config'
import { RequestService } from '../request.service'


export class NotificationApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Static Methods //////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method sendEmail
     *********************************************************************************************/
    public static sendEmail(email: IEMail, user: string, appId: string, log = false): Promise<number> {
        const params = NotificationApi.getParams(user, appId, log)
        return NotificationApi.mailRequest(`/send${params}`, 'post', email)
    }

    /**********************************************************************************************
     * @method sendEmailWithTemplate
     *********************************************************************************************/
    public static sendEmailWithTemplate(
        template: ENotificationTemplate, notificationTemplate: INotificationTemplate, user: string, appId: string, log = false
    ): Promise<number> {
        const params = NotificationApi.getParams(user, appId, log)
        return NotificationApi.mailRequest(`/send/${template}${params}`, 'post', notificationTemplate)
    }

    /**********************************************************************************************
     * @method sendCnsNotification
     *********************************************************************************************/
    public static sendCnsNotification(
        notification: ICnsNotification, user: string, appId: string, log = false
    ): Promise<number> {
        const params = NotificationApi.getParams(user, appId, log)
        return NotificationApi.cnsRequest(`/send${params}`, 'post', notification)
    }

    /**********************************************************************************************
     * @method sendCnsNotificationWithTemplate
     *********************************************************************************************/
    public static sendCnsNotificationWithTemplate(
        template: ENotificationTemplate, cnsTemplate: ICnsNotificationTemplate, user: string, appId: string, log = false
    ): Promise<number> {
        const params = NotificationApi.getParams(user, appId, log)
        return NotificationApi.cnsRequest(`/send/${template}${params}`, 'post', cnsTemplate)
    }

    /**********************************************************************************************
     * @method checkCnsNotificationStatus
     *********************************************************************************************/
    public static checkCnsNotificationStatus(
        referenceId: string, referenceType: ICnsReferenceType = 'NOTIFICATION_ID'
    ): Promise<ICnsNotificationStatus> {
        return NotificationApi.cnsRequest(`/status/${referenceId}?referenceType=${referenceType}`)
    }

    /**********************************************************************************************
     * @method getCnsClientSystemDetails
     *********************************************************************************************/
    public static getCnsClientSystemDetails(): Promise<ICnsClientSystemDetails> {
        return NotificationApi.cnsRequest('/clientSystem/details')
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Static Methods /////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getParams
     *********************************************************************************************/
    private static getParams(user: string, appId: string, log = false): string {
        return `?user=${user}&appId=${appId}${log ? '&log' : ''}`
    }

    /**********************************************************************************************
     * @method cnsRequest
     *********************************************************************************************/
    private static cnsRequest<B, T>(
        endpoint: string, method: 'get' | 'post' = 'get', body?: B
    ): Promise<T> {
        return RequestService.request(EApps.NOTIFICATION, `/cns${endpoint}`, method, body)
    }

    /**********************************************************************************************
     * @method mailRequest
     *********************************************************************************************/
    private static mailRequest<B, T>(
        endpoint: string, method: 'get' | 'post' = 'get', body?: B
    ): Promise<T> {
        return RequestService.request(EApps.NOTIFICATION, `/mail${endpoint}`, method, body)
    }
}
