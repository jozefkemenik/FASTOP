import { IDictionary } from '../../../lib/dist/measure/upload/shared-interfaces'
import { IFDMeasureDetails } from '../../../lib/dist/measure/fisc-drm/measure/shared-interfaces'
import { ISidType } from '../../../lib/dist/measure/shared/shared-interfaces'

export interface IDbpMeasureSpecific {
    SOURCE_SID: number
}

export interface IMeasureDetails extends IFDMeasureDetails, IDbpMeasureSpecific {}

export interface IScaleConfig {
    dataColumn: number
    dataRow: number
    dictionary: IDictionary
    dbpScale?: ISidType
}

export interface IWizardSpecific {
    ROUND_SID: number
    REV_EXP_SID: number
    DBP_SOURCE_SID: number
}

export interface IWizardMeasureDetails extends IMeasureDetails, IWizardSpecific {}
