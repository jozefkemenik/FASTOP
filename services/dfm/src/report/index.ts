import { IArchiveParams, IDBStandardReport } from '../../../lib/dist/measure/shared'
import { IReportFilter, IStandardReport } from '../../../shared-lib/dist/prelib/report'

import { IReportMeasureBase } from './shared-interfaces'

export * from './shared-interfaces'

export interface IAdditionalImpactParams {
    gdp: boolean
    countryId: string
    archive: IArchiveParams
    filter?: IReportFilter
}

export interface IImpactParams extends IAdditionalImpactParams {
    groupBy?: string
    isTotalImpact?: boolean
    baseYear?: number
}

interface IAdditionalImpactBase {
    COUNTRY: string
    DESCR: string
    ORDER_BY: number
    REV_EXP_SID: number
    SERIES: string
    START_YEAR: number
    TYPE_SID: number
}

export interface IAdditionalImpact extends IAdditionalImpactBase, IStandardReport { }
export interface IDBAdditionalImpact extends IAdditionalImpactBase, IDBStandardReport { }
export interface IDBReportMeasure extends IReportMeasureBase, IDBStandardReport {}

export interface ITransferMatrixRecord {
    countryId: string
    overviewSid: number
    overviewDesc: string
    overviewCodes: string[]
    orderBy: number
    startYear: number
    vector: number[]
}

export interface IFilteredTransferMatrix {
    all: ITransferMatrixRecord[]
    withoutEuFunded: ITransferMatrixRecord[]
}
