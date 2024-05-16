import { IEMail, INotificationTemplate } from 'notification'
import { Level, LoggingService } from '../../../lib/dist'
import { MailService } from './mail.service'
import { SharedService } from '../shared/shared.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class MailController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private mailService: MailService,
        private sharedService: SharedService,
        private logs: LoggingService,
    ) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method sendMail
     *********************************************************************************************/
    public async sendMail(
        mail: IEMail, user: string, appId: string, log = false
    ): Promise<number> {
        return this.mailService.sendMail(
            mail.to, mail.cc, mail.bcc,
            mail.subject, mail.body,
            mail.attachments
        ).then((result) => {
            this.logEmail(log, mail, user, JSON.stringify(result), false, appId )
            return 1
        }).catch(err => {
            this.logEmail(log, mail, user, err.toString(), true, appId)
            throw err
        })
    }

    /**********************************************************************************************
     * @method sendMailWithTemplate
     *********************************************************************************************/
    public async sendMailWithTemplate(
        templateId: string, emailTemplate: INotificationTemplate,
        user: string, appId: string, log = false
    ): Promise<number> {

        return this.sharedService.getTemplate(templateId).then(
            template => this.sendMail({
                to: this.sharedService.parseRecipients(template.recipients),
                cc: this.sharedService.parseRecipients(template.ccRecipients),
                bcc: this.sharedService.parseRecipients(template.bccRecipients),
                subject: this.sharedService.populateTemplateParams(template.subject, emailTemplate?.params),
                body: this.sharedService.populateTemplateParams(template.body, emailTemplate?.params),
                attachments: emailTemplate?.attachments,
            }, user, appId, log)
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method logEmail
     *********************************************************************************************/
    private logEmail(
        log: boolean, mail: IEMail, user: string, result: string, failed: boolean, senderAppId: string
    ) {
        if (log) {
            this.sharedService.logMailSent(
                mail.to, mail.cc, mail.bcc, mail.subject, mail.body, user, result, failed, senderAppId
            ).catch(err => {
                this.logs.log(`Failed logging email sent status in db: ${err.toString()}`, Level.ERROR)
            })
        }
    }

}
