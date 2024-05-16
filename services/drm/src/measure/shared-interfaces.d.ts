import { IDictionary, IRoundPeriod } from '../../../lib/dist/measure/upload/shared-interfaces'
import { IObjectSIDs, ISidType } from '../../../lib/dist/measure/shared/shared-interfaces'
import { IFDMeasureDetails } from '../../../lib/dist/measure/fisc-drm/measure/shared-interfaces'

export interface IScaleConfig {
    dataColumn: number
    dataRow: number
    dictionary: IDictionary
    isDrmOnlyPeriod: boolean
    drmScale?: ISidType
    dbpScale?: ISidType
}

export interface IDrmRoundPeriod extends IRoundPeriod {
    exerciseSidToPid: IObjectSIDs
    isDrmOnlyPeriod: boolean
}

/* eslint-disable-next-line @typescript-eslint/no-empty-interface */
export interface IDrmMeasureSpecific { }
export interface IMeasureDetails extends IFDMeasureDetails, IDrmMeasureSpecific {}

export interface IWizardSpecific {
    EXERCISE_SID: number
    ROUND_SID: number
    DBP_SOURCE_SID: number
    REV_EXP_SID: number
}

export interface IWizardMeasureDetails extends IMeasureDetails, IWizardSpecific {}

