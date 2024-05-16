import { IAmecoValidation, IVectorRange } from '../shared/calc/shared-interfaces'
import { OGCalculationSource } from '../../../../shared-lib/dist/prelib/shared-interfaces/fisc-grids'

export interface IGridLineValidation {
    hasError: boolean
    lineId: string
    lineDesc: string
    code?: string
}

export interface IMemberStateValidation {
    hasErrors: boolean
    gridLines: IGridLineValidation[]  // sorted by lineId ASC
}

export interface IBSEValidation {
    hasErrors: boolean
    value: number
    message?: string
}

export interface IOutputGapIndicator {
    indicatorId: string
    descr: string
    vector: string[]
    source?: OGCalculationSource
    orderBy?: number
}

export interface IEcfinValidation {
    hasErrors: boolean
    hasOG: boolean
    range: IVectorRange
    indicators: IOutputGapIndicator[]
    ratsLastUpdated: Date
    ecfinLastUpdated: Date
}

export interface IOutputGapValidation {
    hasErrors: boolean
    memberState: IMemberStateValidation
    ameco: IAmecoValidation
    bse: IBSEValidation
    ecfin: IEcfinValidation
    ctyStatus: string
}

export interface IOutputGapResult {
    successful: boolean
    message?: string
}

export interface IOutputGapUpload {
    startYear: number
    ygapVector: string
    wypotVector?: string
}

export interface IEucamLightVersion {
    version: string
    changeYear: number
    vintage: string
}
