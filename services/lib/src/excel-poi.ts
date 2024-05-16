
export const enum PoiActionType {
    RENAME = 'RENAME', // rename worksheet
}

export interface IPoiAction {
    type: PoiActionType
    [name: string]: unknown
}

export const enum PoiValueType {
    STRING = 'S',
    NUMBER = 'N',
    BOOLEAN = 'B',
    NUMERIC_STRING = 'NS',
    DATE_AS_STRING = 'D', // date as string in format dd/MM/yyyy
    FORMULA = 'F',
}

export interface IPoiCellValue {
    s?: string  // string
    n?: number  // number
    b?: boolean // boolean
    d?: string // date
    f?: string // formula
}

export interface IPoiTableData {
    cellRef: string
    data: IPoiCellValue[][]
}

export interface IPoiSeriesData {
    cellRef: string
    type: PoiValueType
    data: string[][]
}

export interface IPoiCellData {
    cellRef: string
    value: IPoiCellValue
}

export interface IPoiArrayData {
    header: string[]
    textColumns: number[]
    data: [][]
}

export interface IPoiWorksheetData {
    worksheet: string
    tableData?: IPoiTableData[]
    seriesData?: IPoiSeriesData[]
    cellData?: IPoiCellData[]
    arrayData?: IPoiArrayData
    actions?: IPoiAction[]
}
