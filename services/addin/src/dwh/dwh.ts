import { IDwhIndicator, IDwhIndicatorData } from './shared-interfaces'

export type IDBDwhIndicator = IDwhIndicator
export interface IDBDwhIndicatorData extends Omit<IDwhIndicatorData, 'vector'> {
    timeserie: string
}
