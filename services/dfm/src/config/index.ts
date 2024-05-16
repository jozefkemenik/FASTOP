import { ICustStorageText } from './shared-interfaces'

export * from './shared-interfaces'

export type IDBCustStorageText = ICustStorageText

export interface IDBOneOffPrinciples {
    OO_PRINCIPLE_SID: number
    OO_PRINCIPLE_ID: number
    DESCR: string
}

export interface IDBOverview {
    OVERVIEW_SID: number
    DESCR: string
    CODES: string
    OPERATOR: string
    ORDER_BY: number
    IS_FILTER: number
}

export interface IDBRevExp {
    REV_EXP_SID: string
    DESCR: string
}

export interface IDBStatuses {
    STATUS_SID: number
    DESCR: string
}
