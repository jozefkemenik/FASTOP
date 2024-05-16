import { ICountryStatus, ICtyAccepted, ICtyRoundComment, ICtyStatusChanges } from './shared-interfaces'

export * from './shared-interfaces'

export type IDBCountryStatus = ICountryStatus
/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type IDBCommandResult = [number, any]
export type IDBCtyAccepted = ICtyAccepted
export type IDBCtyRoundComment = ICtyRoundComment
export type IDBCtyStatusChanges = ICtyStatusChanges
