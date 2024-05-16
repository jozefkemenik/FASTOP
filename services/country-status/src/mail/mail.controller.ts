import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IError } from '../../../lib/dist'

import { IMailNotification } from '.'
import { MailService } from './mail.service'

export class MailController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private mailService: MailService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method addMailRecipient
     *********************************************************************************************/
    public addMailRecipient(notification: IMailNotification, email: string) {
        return this.mailService.manageMailRecipient('add', notification, email).then(
            res => res < 0 ? EErrors.EMAIL_EXISTS : res,
            (err: IError) => {
                err.method = 'MailController.addMailRecipient'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getActions
     *********************************************************************************************/
    public getActions() {
        return this.mailService.getActions().catch(
            (err: IError) => {
                err.method = 'MailController.getActions'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getMailRecipients
     *********************************************************************************************/
    public getMailRecipients(notification: IMailNotification) {
        return this.mailService.getMailRecipients(notification).catch(
            (err: IError) => {
                err.method = 'MailController.getMailRecipients'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method deleteMailRecipient
     *********************************************************************************************/
    public deleteMailRecipient(notification: IMailNotification, email: string) {
        return this.mailService.manageMailRecipient('delete', notification, email).catch(
            (err: IError) => {
                err.method = 'MailController.deleteMailRecipient'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method updateMailRecipient
     *********************************************************************************************/
    public updateMailRecipient(notification: IMailNotification, email: string, data: {newEmail: string}) {
        return this.mailService.updateMailRecipient(notification, email, data.newEmail).then(
            res => res < 0 ? EErrors.EMAIL_EXISTS : res,
            (err: IError) => {
                err.method = 'MailController.updateMailRecipient'
                throw err
            }
        )
    }
}
