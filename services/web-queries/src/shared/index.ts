import { IArchivedRoundInfo, ICurrentRoundInfo } from '../../../dashboard/src/config/shared-interfaces'
import { ITplIndicators, IVector, IWQInputParams, IWQRequestParams } from './shared-interfaces'


export interface IIndicatorFields {
    code: string
    trn: string
    agg: string
    unit: string
    ref: string
}

export type TransformationFunction = (
    vectors: IVector[], startYear: number, params: IWQInputParams
) => Promise<IVector[]>

export interface IWQRoundInfo {
    archiveRound: IArchivedRoundInfo
    currentRound: ICurrentRoundInfo
}

export interface IWQRenderData<T extends IWQRequestParams> {
    indicators: ITplIndicators
    countries: string[]
    archivedRound: IArchivedRoundInfo
    params: T
    error?: string
}
