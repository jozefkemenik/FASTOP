import { IDBFDMeasureDetails } from '../../../lib/dist/measure/fisc-drm/measure'

import { IDrmMeasureSpecific, IWizardSpecific } from './shared-interfaces'

export * from './shared-interfaces'

export interface IDBMeasureDetails extends IDBFDMeasureDetails, IDrmMeasureSpecific {}
export interface IDBWizardMeasureDetails extends IDBMeasureDetails, IWizardSpecific {}
