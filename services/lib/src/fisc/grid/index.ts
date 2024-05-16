import { GridType } from '../../../../shared-lib/dist/prelib/fisc-grids'

import { ICountryGrid } from './shared-interfaces'

export * from './shared-interfaces'

export type IDBCountryGrid = ICountryGrid

export interface IDBRoundsLine {
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
    IN_AGG?: string
    IN_DD?: string
    IN_LT?: string
    IS_MANDATORY?: number
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

export interface IDBCountryGridData {
    LINE_SID: number
    COL_SID: number
    cellValue: string
}

export interface IDBCountryDefaultLevel {
    LINE_SID: number
    COL_SID: number
    VALUE: number
    SCALE_ID: string
}

export interface IDBGridName {
    ROUND_GRID_SID: number
    GRID_SID: number
    GRID_ID: string
    DESCR: string
    YEAR: number
    GRID_TYPE_ID: string
}

export interface IDBCtyGridName extends IDBGridName {
    CTY_GRID_SID: number
    ORDER_BY: number
}

export interface IDBOptionalCell {
    lineSid: number,
    colSid: number
}

export interface IGridTypeInfo {
    gridType: GridType
    gridId: string
    roundGridSid: number
    roundSid: number
    countryId: string
}

export interface ICellValue {
    lineId: string,
    yearValue: number
    value: number
}

export interface ICells {
    [lineSid: number]: {[colSid: number]: ICellValue}
}

export interface ILineIdToLineSid {
    [lineId: string]: number
}

export interface ILineCells {
    [lineId: string]: {[yearValue: number]: string}
}
