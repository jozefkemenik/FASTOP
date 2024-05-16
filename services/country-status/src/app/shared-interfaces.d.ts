import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

export const enum EStatusRepo {
    ACTIVE = 'ACTIVE',
    OPENED = 'OPEN',
    CLOSED = 'CLOSED',
    SUBMITTED = 'SUBMIT',
    ARCHIVED = 'ARCHIVE',
    PUBLISHED = 'PUBLISH',
    TR_OPENED = 'TR_OPEN',
    TR_SUBMITTED = 'TR_SUBMIT',
    TR_PUBLISHED = 'TR_PUBLISH',
    VALIDATED = 'VALIDATE',
    ACCEPTED = 'ACCEPTED',
    REJECTED = 'REJECTED',
    ST_CLOSED = 'ST_CLOSED',
}

export interface ICountryStatus {
    countryId: string
    countryDescr: string
    lastChangeDate: string
    lastChangeUser: string
    statusSid: number
    statusId: EStatusRepo
    statusDescr: string
    statusTrDescr: string
}

export interface ICtyAccepted {
    countryId: string
    lastAcceptedDate: string
    roundSid: number
    storageSid: number
}

export interface ICtyRoundComment {
    storage: string
    storageId: string
    status: string
    statusId: EStatusRepo
    user: string
    date: string
    comment: string
}

export interface ICtyStatusChanges {
    countryId: string
    firstInputDate: string
    lastInputDate: string
    submitionDate: string
    validationDate: string
    outputGapDate: string
    archiveDate: string
}

export interface ISetCountryStatus {
    oldStatusId: EStatusRepo
    newStatusId: EStatusRepo
    roundKeys: IRoundKeys
    userId: string
    comment?: string
}

export interface ISetCountryStatusResult {
    result: number
    countryStatus?: ICountryStatus
}

export interface ISetStatusChangeDate {
    statusChange: 'Input' | 'OutputGap' | 'LastArchiving'
    roundKeys?: IRoundKeys
}
