import { ILibMeasureDetails } from '../../measure/shared-interfaces'

export interface IFDMeasureSpecific {
    ACC_PRINCIP_SID: number
    ADOPT_STATUS_SID: number
}

export interface IFDMeasureDetails extends ILibMeasureDetails, IFDMeasureSpecific {}
