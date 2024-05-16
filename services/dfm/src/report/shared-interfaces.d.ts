import { IMeasuresRange } from '../../../lib/dist/measure/shared/shared-interfaces'
import { IStandardReport } from '../../../shared-lib/dist/prelib/shared-interfaces/report'

import { IWQIndicator, IWQIndicators } from '../../../web-queries/src/shared/shared-interfaces'

export interface IAdditionalImpactData {
    code: number
    country: string
    descr: string
    values: number[]
    country_id?: string
    scale?: string
    series?: string
    rev_exp?: number
}

export interface IImpactReport {
    startYear: number
    yearsCount: number
    all: IAdditionalImpactData[]
}
export interface IAdditionalImpactReport extends IImpactReport{
    oneOff: IAdditionalImpactData[]
    excelRange?: IMeasuresRange
}

export interface IAdditionalImpactWithYears extends IAdditionalImpactReport {
    years?: number[]
}

export interface IReportMeasureBase {
    MEASURE_SID: number
    TITLE: string
    SHORT_DESCR: string
    ONE_OFF_SID: number
    REV_EXP_SID: number
    ADOPT_DATE_YR: number
    ADOPT_DATE_MH: number
}

export interface IReportMeasure extends IReportMeasureBase, IStandardReport {}

export interface IDetailedReport extends IMeasuresRange {
    data: IReportMeasure[]
    gdp: boolean
}

export interface ITransferMatrixReport extends Omit<IWQIndicators, 'indicators'> {
    all: IWQIndicator[]
    withoutEuFunded: IWQIndicator[]
}
