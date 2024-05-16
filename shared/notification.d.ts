export * from './cns'

export interface IAttachment {
    filename: string
    contentType?: string
    raw: Buffer
}

export interface IEMail {
    to: string[]
    cc?: string[]
    bcc?: string[]
    subject: string
    body: string
    attachments?: IAttachment[]
}

export interface ITemplateParams {
    [key: string]: string
}

export interface INotificationTemplate {
    attachments?: IAttachment[]
    params?: ITemplateParams
}

export interface ICnsNotificationTemplate {
    notificationGroupCode: string
    params?: ITemplateParams
}

export const enum ENotificationTemplate {
    AMECO_TRANSFER = 'AMECO_TRANSFER',
    FDMS_AGGREGATES_ACCEPTATION = 'FMDS_AGG_ACCEPTATION',
}

export const enum ENotificationProvider {
    MAIL = 'MAIL',
    CNS = 'CNS'
}
