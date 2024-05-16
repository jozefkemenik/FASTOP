import { IDBFDMeasureDetails } from '../../../lib/dist/measure/fisc-drm/measure'

import { IDbpMeasureSpecific, IWizardSpecific } from './shared-interfaces'

export * from './shared-interfaces'

export interface IDBMeasureDetails extends IDBFDMeasureDetails, IDbpMeasureSpecific {}
export interface IDBWizardMeasureDetails extends IDBMeasureDetails, IWizardSpecific {}
