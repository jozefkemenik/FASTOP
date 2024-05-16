import { IESACodes, IMeasuresRange, IObjectSIDs, IScale, ISidType } from './shared-interfaces'

export * from './shared-interfaces'

export type IDBSidType = ISidType
export type IDBScale = IScale

export interface IDBPidType extends IDBSidType {
    PID: string
}

export interface IDBESACode {
    ESA_SID: number
    ESA_ID: string
    DESCR: string
    REV_EXP_SID: number
    OVERVIEW_SID: number
}

export interface IDBOneOffType {
    ONE_OFF_TYPE_SID: number
    DESCR: string
}

export interface IDBOneOff {
    ONE_OFF_SID: number
    DESCR: string
}

export const config: IMeasuresRange = {
    startYear: 2008,
    yearsCount: 23,
}

export const excelConfig: IMeasuresRange = {
    startYear: 2000,
    yearsCount: 30
}

export interface IArchiveParams {
    roundSid: number
    storageSid: number
    custTextSid: number
    storageId?: string
    ctyVersion?: number
}

export interface IDBGDPPonderation {
    COUNTRY_ID: string
    START_YEAR: number
    VECTOR: string
}

export interface IDBCountryMultiplier {
    COUNTRY_ID: string
    MULTI: number
    SCALE: string
}

export interface IDBStandardReport {
    COUNTRY_ID: string
    DATA: string
    START_YEAR: number
    LABEL_SIDS: string
}

export interface ILibDictionaries {
    esaCodes: IESACodes
    oneOff: IObjectSIDs
    oneOffTypes: IObjectSIDs
    euFunds: IObjectSIDs
    labels: IObjectSIDs
    months: IObjectSIDs
}
