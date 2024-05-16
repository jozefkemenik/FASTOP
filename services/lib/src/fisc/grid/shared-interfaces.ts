import { GridVersionType } from '../../../../shared-lib/dist/prelib/shared-interfaces/fisc-grids'
import { IScale } from '../../measure/shared/shared-interfaces'

export interface IRoundsLine {
    LINE_ID: string
    DESCR: string
    AGG_DESCR?: string
    CALC_RULE?: string
    COPY_LINE_RULE?: string
    EB_ID?: string
    ESA_CODE?: string
    GRID_SID?: number
    HELP_MSG_SID?: number
    INDICATOR_ID?: string
    IN_AGG?: boolean
    IN_DD?: boolean
    IN_LT?: boolean
    IS_MANDATORY?: boolean
    LINE_SID?: number
    LINE_TYPE_ID?: string
    LINE_TYPE_SID?: number
    MANDATORY_CTY_GROUP_ID?: string
    MANDATORY_CTY_GRP_CTY_IDS?: string
    MESS?: string
    ORDER_BY?: number
    RATS_ID?: string
    ROUND_GRID_SID?: number
    ROUND_SID?: number
    WEIGHT?: string
    WEIGHT_YEAR?: number
}

export interface IGridLine {
    roundGridSid: number
    lineSid: number
    lineId: string
    description: string
    esaCode: string
    isMandatory: number
    lineTypeId: string
    helpMessage: string
    calcRule: string
    copyLineRule: string
    mandatoryCtyIds: string[]
}

export interface IGridCol {
    roundGridSid: number
    colSid: number
    description: string
    dataTypeId: string
    dataTypeDesc: string
    colTypeId: string
    isMandatory: number
    yearValue: number
    isAbsolute: number
    helpMessage: string
    width: number
}

export interface IGridsLines {
    [roundGridSid: number]: IGridLine[]
}

export interface IGridsCols {
    [roundGridSid: number]: IGridCol[]
}

export interface IFiscGridData {
    colSid: number
    lineSid: number
    gridId: string
    lineId: string
    yearValue: number
    cellValue: string
    gridVersionType: GridVersionType
    footnote: string
}

export interface ICtyGridData {
    countryId: string
    gridCells: ICtyGridCells
    gridVersionType?: GridVersionType
    scale?: IScale
}

export interface ICtyGridCells {
    [gridId: string]: ICtyGridLineCells
}

export interface ICtyGridLineCells {
    [lineId: string]: ICtyGridValues
}

export interface ICtyGridValues {
    [colSid: number]: ICtyGridValue
}

export interface ICtyGridValue {
    cellValue: string
    gridVersionType: GridVersionType
    footnote?: string
}

export interface IFiscExportData {
    data: ICtyGridData
    definitions: IFiscGridDefinition[]
}

export interface IFiscGridDefinition {
    gridSid: number
    gridId: string
    gridTypeId: string
    description: string
    year: number
    lines: IGridLine[]
    cols: IGridCol[]
    optionalCells: IGridOptionalCells
}

export interface IFiscCtyGridDefinition extends IFiscGridDefinition {
    ctyGridSid: number
    orderBy: number
}

export interface IGridRound {
    roundSid: number
    year: number
    periodId: string
}

export interface ICountryGrid {
    CTY_GRID_SID: number
    ROUND_GRID_SID: number
    GRID_ID: string
    DESCR: string
    GRID_TYPE_ID: string
    CONSISTENCY_STATUS_CD_SID: number
    CONSISTENCY_STATUS_MS_SID: number
    YEAR: number
    VERSION: number
}

export interface IDownloadCSVParams {
    roundSids: number[]
    countryIds: string[]
    lineIds: string[]
    calculated: string[]
    ameco: string[]
}

export interface ICountryLineData { [colSid: number]: string }
export interface ICountryGridData { [lineSid: number]: ICountryLineData }
export interface ICountryDefaultLevels { [lineSid: number]: { [colSid: number]: number } }
export interface IGridOptionalCells { [lineSid: number]: {[colSid: number]: boolean} }
