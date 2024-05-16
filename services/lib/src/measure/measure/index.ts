import { ILibMeasureBase, ILibMeasureYear } from './shared-interfaces'
import { IDBStandardReport } from '../shared'

export * from './shared-interfaces'

export interface IDBLibMeasure extends ILibMeasureBase, IDBStandardReport {}
export interface IDBLibMeasureDetails extends IDBLibMeasure, ILibMeasureYear {}
