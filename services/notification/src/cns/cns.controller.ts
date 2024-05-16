import {
    ICnsClientSystemDetails,
    ICnsNotification,
    ICnsNotificationStatus, ICnsNotificationTemplate,
    ICnsRecipient,
    ICnsRecipientType,
    ICnsReferenceType,
} from 'notification'
import { Level, LoggingService } from '../../../lib/dist'
import { CnsService } from './cns.service'
import { SharedService } from '../shared/shared.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class CnsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(
        private readonly cnsService: CnsService,
        private readonly sharedService: SharedService,
        private readonly logs: LoggingService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method send
     *********************************************************************************************/
    public async send(
        notification: ICnsNotification, user: string, appId: string, log = false
    ): Promise<number> {
        return this.cnsService.send(notification).then(
            (result) => {
                this.logCns(log, notification, user, JSON.stringify(result), false, appId)
                return result.notificationId
            },
            (err) => {
                this.logCns(log, notification, user, err.toString(), true, appId)
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method sendNotificationWithTemplate
     *********************************************************************************************/
    public async sendNotificationWithTemplate(
        templateId: string, notificationTemplate: ICnsNotificationTemplate,
        user: string, appId: string, log = false
    ): Promise<number> {

        return this.sharedService.getTemplate(templateId).then(
            template => this.send({
                notificationGroupCode: notificationTemplate.notificationGroupCode,
                recipients: this.getRecipients('TO', template.recipients).concat(
                    this.getRecipients('CC', template.ccRecipients)).concat(
                    this.getRecipients('BCC', template.bccRecipients)),
                defaultContent: {
                    subject: this.sharedService.populateTemplateParams(template.subject, notificationTemplate?.params),
                    body: this.sharedService.populateTemplateParams(template.body, notificationTemplate?.params),
                    language: 'EN',
                }
            }, user, appId, log)
        )
    }

    /**********************************************************************************************
     * @method getStatus
     *********************************************************************************************/
    public async getStatus(referenceId: string, referenceType: ICnsReferenceType): Promise<ICnsNotificationStatus> {
        return this.cnsService.checkStatus(referenceId, referenceType)
    }

    /**********************************************************************************************
     * @method getClientSystemDetails
     *********************************************************************************************/
    public async getClientSystemDetails(): Promise<ICnsClientSystemDetails> {
        return this.cnsService.getClientSystemDetails()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logCns
     *********************************************************************************************/
    private logCns(
        log: boolean, notification: ICnsNotification, user: string, result: string, failed: boolean, senderAppId: string
    ) {
        if (log) {
            this.sharedService.logCnsSent(
                this.getEmailAddresses('TO', notification.recipients),
                this.getEmailAddresses('CC', notification.recipients),
                this.getEmailAddresses('BCC', notification.recipients),
                notification.defaultContent.subject,
                notification.defaultContent.body,
                user, result, failed, senderAppId
            ).catch(err => {
                this.logs.log(`Failed logging cns notification sent status in db: ${err.toString()}`, Level.ERROR)
            })
        }
    }

    /**********************************************************************************************
     * @method getEmailAddresses
     *********************************************************************************************/
    private getEmailAddresses(rcpType: ICnsRecipientType, recipients: ICnsRecipient[]): string[] {
        return !recipients ? undefined :
               recipients.filter(rcp => rcp.type === rcpType).map(rcp => rcp.smtpAddress)
    }

    /**********************************************************************************************
     * @method getRecipients
     *********************************************************************************************/
    private getRecipients(rcpType: ICnsRecipientType, dbRecipients: string): ICnsRecipient[] {
        const recipients: string[] = this.sharedService.parseRecipients(dbRecipients)
        return !recipients ? [] : recipients.map(rcp => ({ type: rcpType, smtpAddress: rcp }))
    }
}
