// CNS rest api: https://webgate.ec.europa.eu/cns/restapi

export type ICnsReferenceType = 'NOTIFICATION_ID' | 'EXTERNAL_REFERENCE'

export interface ICnsNotificationOptions {
    type: 'FOLLOW_UP' | 'IMPORTANT' | 'KEYWORDS'
    value?: string
    valueType?: 'STRING' | 'DATE' // UTC instant in the ISO instant format, such as '2011-12-03T10:15:30'.
}

export interface ICnsNotificationLink {
    label: string
    url: string
}

export interface ICnsNotificationAttachment {
    attachmentId?: string
    name: string
    length: number
    mimeType: string
    inline: boolean // Whether the attachment is inline (e.g. inline image) or not.
    content: string
    contentBase64: string
}

export interface ICnsNotificationContent {
    subject: string
    summary?: string
    body: string
    language: string
    links?: ICnsNotificationLink[]
    categoryLabel?: string
    attachments?: ICnsNotificationAttachment[]
}

export type ICnsRecipientType = 'TO' | 'CC' | 'BCC'

export interface ICnsRecipient {
    name?: string
    type: ICnsRecipientType
    smtpAddress: string
}

export interface ICnsNotification {
    externalReference?: string
    notificationGroupCode: string
    recipients: ICnsRecipient[]
    defaultContent: ICnsNotificationContent
    notificationOptions?: ICnsNotificationOptions[]
}

export interface ICnsNotificationResult {
    notificationId: number
}

export interface ICnsNotificationStatus extends ICnsNotification {
    notificationId: string
    read: boolean // Flag to indicate if notification was read
    status: string
    submissionDate: string
    lastModificationDate: string
    clientSystemId: string
    clientSystemName: string
}

export interface ICnsClientSystem {
    clientSystemId: string
    clientSystemName: string
}

export interface ICnsAllowedValue {
    code: string
    labelEn: string
    labelFr?: string
}

export interface ICnsCustmMetadata {
    labelEn: string
    descriptionEn: string
    labelFr?: string
    descriptionFr?: string
    type: 'INT' | 'STRING' | 'DATE'
    defultAllowedValue: ICnsAllowedValue
    allowedValue: ICnsAllowedValue[]
}

export interface ICnsNotificationGroup {
    notificationGroupCode: string
    notificationGroupName: string
    defaultSubscribed: boolean
    allowUserUnsubscribed: boolean
    supportAttachments: boolean
    supportMultipleRecipients: boolean
    supportDailyDigest: boolean
    supportTranslations: boolean
    notificationType: 'MESSAGE' | 'TASK' | 'REPORT'
    subscriptionType: 'INSTANT' | 'DAILY_DIGEST'
    customMetadata?: ICnsCustmMetadata[]
}

export interface ICnsClientSystemDetails extends ICnsClientSystem {
    notificationGroups: ICnsNotificationGroup[]
}
