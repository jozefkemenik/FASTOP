import { EApps } from 'config'
import { IMailNotification } from 'country-status'

import { CountryStatusApi } from '../api/country-status.api'

export class MailController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method addMailRecipient
     *********************************************************************************************/
    public addMailRecipient(notification: IMailNotification, email: string) {
        notification.appId = this.appId
        return CountryStatusApi.manageMailRecipient(notification, email, 'post')
    }

    /**********************************************************************************************
     * @method getMailRecipients
     *********************************************************************************************/
    public getMailRecipients(notification: IMailNotification) {
        notification.appId = this.appId
        return CountryStatusApi.getMailNotification(notification)
    }

    /**********************************************************************************************
     * @method deleteMailRecipient
     *********************************************************************************************/
    public deleteMailRecipient(notification: IMailNotification, email: string) {
        notification.appId = this.appId
        return CountryStatusApi.manageMailRecipient(notification, email, 'delete')
    }

    /**********************************************************************************************
     * @method updateMailRecipient
     *********************************************************************************************/
    public updateMailRecipient(notification: IMailNotification, email: string, body: {newEmail: string}) {
        notification.appId = this.appId
        return CountryStatusApi.manageMailRecipient(notification, email, 'put', body)
    }
}
