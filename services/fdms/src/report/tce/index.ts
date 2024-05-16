import { ITcePartner } from './shared-interfaces'

export type IDBTcePartner = ITcePartner

export interface IDBTceMatrixData {
    EXPORTER_CTY_ID: string
    PARTNER_CTY_ID: string
    VALUE: string
}

export interface IDBTceResult {
    KEY_ID: string
    START_YEAR: number
    TIMESERIE_DATA: string
}

export interface IDBTceReportDefinition {
    ORDER_BY: number
    DESCR?: string
    GN_KEY_ID: string
    SN_KEY_ID: string
    GS_KEY_ID: string
}

export interface IDBTceTradeItem {
    DESCR: string
    GN_INDICATOR_ID: string
    GN_DATA_TYPE: string
    SN_INDICATOR_ID: string
    SN_DATA_TYPE: string
    GS_INDICATOR_ID: string
    GS_DATA_TYPE: string
}
