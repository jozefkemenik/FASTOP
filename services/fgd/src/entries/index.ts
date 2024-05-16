import { IAbolishEntry, ICreateReform, IDuplicateEntry } from './shared-interfaces'
import { IScoreDetail } from '../shared/'

export * from './shared-interfaces'

export interface IDBRuleScoreDetail {
    ENTRY_CRITERIA_SID: number
    SCORE: number
    SCORE_VERSION_SID: number
    LDAP_LOGIN: string
    ORGANISATION: string
    DATETIME: string
    ACC_LDAP_LOGIN: string
    ACC_DATETIME: string
    ACC_ORGANISATION: string
}

export interface IDBResponseChoices {
    RESPONSE_SID: number
    RESPONSE_ID: string
    RESPONSE_GROUP_SID: number
    DESCR: string
    RESPONSE_TYPE_SID: number
    HELP_TEXT: string
    PROVIDE_DETAILS: number
    CHOICE_LIMIT: number
    DETS_TXT: string
    INFO_ICON: number
    INFO_TXT: string
}

export interface IDBRuleType {
    DESCR: string
    LOV_SID: number
}

export type IDBScoreDetail = IScoreDetail
export type IDBCreateReform = ICreateReform
export type IDBDuplicateRule = IDuplicateEntry
export type IDBAbolishRule = IAbolishEntry
