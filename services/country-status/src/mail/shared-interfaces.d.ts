import { EDashboardActions } from '../../../shared-lib/dist/prelib/shared-interfaces/dashboard'

export interface IMailNotification {
    appId: string
    countryId: string
    actionSid: number
}

export interface IAction {
    ACTION_SID: number
    ACTION_ID: EDashboardActions
    DESCR: string
}
