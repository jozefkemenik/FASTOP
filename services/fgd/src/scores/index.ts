import { IIndex } from './shared-interfaces'

export * from './shared-interfaces'

export interface IDBIdxCriterion {
    CRITERION_SID: number
    CRITERION_ID: number
    SUB_CRITERION_ID: string
    DESCR: string
    HELP_TEXT: string
    SCORES: string
}
export type IDBIndex = IIndex
