export interface IDBMailTemplate {
    templateId: string
    recipients: string // list of emails separated with ';'
    ccRecipients?: string // list of emails separated with ';'
    bccRecipients?: string // list of emails separated with ';'
    subject: string
    body: string
}
