export * from './shared-interfaces/fisc-grids'

export enum GridDataType {
    TEXT = 'TEXT',
    LEVELS = 'LEVELS',
    GDP = 'GDP',
    CHANGE_RATE = 'CHANGE_RATE'
}

export enum GridColType {
    CODE = 'CODE',
    YEAR = 'YEAR'
}

export enum GridLineType {
    LINE = 'LINE',
    HEADER = 'HEADER',
    CALCULATION = 'CALCULATION'
}

export enum GridType {
    NORMAL = 'NORMAL',
    MEASURES = 'MEASURES',
    AGGREGATE = 'AGGREGATE',
    DIVERGENCE = 'DIVERGENCE'
}

export enum WorkbookGroup {
    LINKED_TABLES = 'linked_tables'
}

export const GRIDS_CONTROL_WORKSHEET_NAME = 'Grids_Control_Data'

export const GRIDS_CONTROL_LINE_SID_COLUMN_NAME = 'LINESID'

export function lineSidToText(lineSid: number): string {
    return `LINE_${lineSid}`
}

export function colSidToText(colSid: number): string {
    return `COL_${colSid}`
}

export function textToLineSid(text: string): number {
    return text !== undefined && text !== null && text.startsWith('LINE_') ? +text.split('LINE_')[1] : null
}

export function textToColSid(text: string): number {
    return text !== undefined && text !== null && text.startsWith('COL_') ? +text.split('COL_')[1] : null
}
