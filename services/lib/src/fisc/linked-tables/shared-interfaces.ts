import { IMemberStateValidation } from '../output-gaps/shared-interfaces'

import { IAmecoValidation } from '../shared/calc/shared-interfaces'

export interface IGridsValidation {
    validated: boolean
}

export interface ILinkedTableValidation {
    hasErrors: boolean
    ameco: IAmecoValidation
    grids: IGridsValidation
    memberState: IMemberStateValidation
    scpGrids?: IGridsValidation
    scpMemberState?: IMemberStateValidation
}

export interface ILinkedTableValues {
    [key: string]: string
}

export interface ILinkedTableData {
    cols: string[]
    rows: ILinkedTableValues[]
}

export interface ILinkedTableIndicatorsData {
    ameco: ILinkedTableData
    levels: ILinkedTableData
    calculated: ILinkedTableData
    growth: ILinkedTableData
    variables: ILinkedTableValues
}

export interface ILinkedTableExcelData {
    uploaded: ILinkedTableData
    scp: ILinkedTableIndicatorsData
    dbp?: ILinkedTableIndicatorsData
}

export interface IYearRange {
    startYear: number
    endYear: number
}

export interface ILinkedTableBaseExcelParams {
    isDBP: boolean
    scpRoundSid?: number
}

export interface ILinkedTableExcelParams extends ILinkedTableBaseExcelParams {
    countryId: string
    roundSid: number
    roundYear: number
    range: IYearRange
}

export interface ILinkedTableTemplateFile {
    content: Buffer
    fileName: string
    contentType: string
}
