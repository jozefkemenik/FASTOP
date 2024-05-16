export interface IRound {
    ROUND_SID: number
    YEAR: number
    PERIOD_DESCR: string
    VERSION: number
    DESCR: string
}

export interface IStorage {
    storageSid: number
    storageId: string
    descr: string
    altDescr: string
    orderBy: number
    isCustom: boolean
    isPermanent: boolean
    isFull: boolean
}

export interface IRoundInfo {
    roundSid: number
    year: number
    roundDescr: string
    periodDescr: string
    periodId: string
    version: number
}

export interface IStorageInfo {
    storageSid: number
    storageDescr: string
    storageId: string
}

export interface ICustomTextInfo {
    textSid: number
    textTitle: string
    textDescr: string
}

export interface ICurrentRoundInfo extends IRoundInfo, IStorageInfo, ICustomTextInfo {}
export interface IArchivedRoundInfo extends IRoundInfo, IStorageInfo {}

export interface IGeoArea {
    geoAreaId: string
    codeIso3: string
}

export interface IRoundKeys {
    roundSid: number
    storageSid?: number
    storageId?: string
    custTextSid?: number
}

export interface IGeoAreaMapping {
    source: string
    geoAreaId: string
}

export interface IRoundStorage {
    roundSid: number
    roundId: string
    storageSid: number
    storageId: string
    custTextSid?: number
    custTextId?: string
}

export interface IParam {
    descr: string
    value: string
}
