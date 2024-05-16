import { IESACodes, IMeasuresRange, IObjectSIDs } from '../shared/shared-interfaces'
import { ILibWorkbookConfig } from '../upload/shared-interfaces'
import { IMeasureViews } from '../../../../shared-lib/dist/prelib/shared-interfaces/measure'
import { IStandardReport } from '../../../../shared-lib/dist/prelib/shared-interfaces/report'

export interface IMeasureTable<T extends ILibMeasure> extends IMeasuresRange {
    measures: T[]
}

export interface IColumn {
    field: string
    header: string
    views: IMeasureViews
    width?: number
    order?: number
    disabled?: boolean
    isGrouped?: boolean
    isNumeric?: boolean
    span?: number
}

export interface ILibMeasureBase {
    MEASURE_SID: number
    DESCR: string
    TITLE: string
    ESA_SID: number
    ONE_OFF_SID: number
    ONE_OFF_TYPE_SID: number
    IS_EU_FUNDED_SID: number
    EU_FUND_SID: number
    ADOPT_DATE_YR: number
    ADOPT_DATE_MH: number
}

export interface ILibMeasureYear {
    YEAR: number
    START_YEAR: number
}

export interface ILibMeasure extends ILibMeasureBase, IStandardReport {
    lastChanged?: boolean
}
export interface ILibMeasureDetails extends ILibMeasure, ILibMeasureYear { }

export interface IWizardDefinition {
    range?: IMeasuresRange
    workbookConfig: ILibWorkbookConfig
}

export interface IWizardTemplate<B extends ILibMeasureDetails> extends IWizardDefinition {
    measures: B[]
    withData: boolean
}

export interface IResidual {
    [key: number]: number
}

export interface IPublicMeasures {
    [key: number]: ILibMeasureDetails[]
}

export interface IReportData {
    residual: IResidual
    gdpResidual: IResidual
    publicMeasures: IPublicMeasures
    publicYears: number[]
    publicMeasuresCount: number
    startYear: number
}

export interface ITransparencyReport {
    countryId: string
    reportRange: IMeasuresRange
    oneOffs: IObjectSIDs
    esaCodes: IESACodes
    reportData: IReportData
    scale: string
}

export interface IMeasuresDenormalised {
    columns: IColumn[]
    measures: Array<Partial<ILibMeasure>>
}
