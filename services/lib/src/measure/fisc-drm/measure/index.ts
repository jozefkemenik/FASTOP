import { IDBLibMeasureDetails } from '../../measure'
import { IFDMeasureSpecific } from './shared-interfaces'

export * from './shared-interfaces'

export interface IDBFDMeasureDetails extends IDBLibMeasureDetails, IFDMeasureSpecific {}
