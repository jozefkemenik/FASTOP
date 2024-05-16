import { ILibMeasure, ILibMeasureDetails } from '../../../lib/dist/measure/measure/shared-interfaces'

export interface IDfmMeasureSpecific {
    NEED_RESEARCH_SID: number
    INFO_SRC: string
    COMMENTS: string
    ESA_COMMENTS: string
    ONE_OFF_DISAGREE_SID: number
    ONE_OFF_COMMENTS: string
    QUANT_COMMENTS: string
    OO_PRINCIPLE_SID: number
    REV_EXP_SID: number
    STATUS_SID: number
    IS_PUBLIC: number
}

export interface ICountryMeasure extends ILibMeasure {
    STATUS_SID: number
}

export interface IMeasureDetails extends ILibMeasureDetails, IDfmMeasureSpecific {}
