import { ICountry, IMenuBase } from './shared-interfaces'

export * from './shared-interfaces'

export type IDBCountry = ICountry
export type IDBMenu = IMenuBase

export interface IBuildMenuOptions {
    userId: string
    userGroups: string[]
}