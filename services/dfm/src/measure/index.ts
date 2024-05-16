import { IDBLibMeasure, IDBLibMeasureDetails } from '../../../lib/dist/measure/measure'
import { IDfmMeasureSpecific } from './shared-interfaces'

export * from './shared-interfaces'

export type IDBCountryMeasure = IDBLibMeasure
export interface IDBMeasureDetails extends IDBLibMeasureDetails, IDfmMeasureSpecific {}
