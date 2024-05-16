import * as nodemailer from 'nodemailer'

import { Level, LoggingService } from '../../../lib/dist'
import { IAttachment } from 'notification'
import { config } from '../../../config/config'


export class MailService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private transporter: nodemailer.Transporter

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    private constructor(private logs: LoggingService) {
        this.transporter = nodemailer.createTransport({
            host: config.mailbox.host,
            port: config.mailbox.port,
            secure: false,
            sender: config.mailbox.sender,
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static instance: MailService

    /**********************************************************************************************
     * @method getInstance
     *********************************************************************************************/
    public static getInstance(logs: LoggingService) {
        if (!MailService.instance) {
            MailService.instance = new MailService(logs)
        }
        return MailService.instance
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method sendMail
     *********************************************************************************************/
    public async sendMail(
        to: string[], cc: string[], bcc: string[], subject: string, body: string,
        attachments: IAttachment[]
    ): Promise<unknown> {
        return this.transporter.sendMail({
            from: config.mailbox.sender,
            to,
            cc,
            bcc,
            subject,
            html: body,
            attachments: attachments?.map(a => ({
                filename: a.filename,
                contentType: a.contentType,
                content: Buffer.from(a.raw),
            }))
        }).then((info) => {
            this.logs.log(`Message sent with result: ${JSON.stringify(info)}`, Level.INFO)
            return info
        }).catch(err => {
            this.logs.log(`Failed sending email: ${err.toString()}`, Level.ERROR)
            throw err
        })
    }

    /**********************************************************************************************
     * @method close
     *********************************************************************************************/
    public close() {
        this.transporter.close()
    }
}
