import { ELibColumn } from '../../shared-lib/dist/prelib/shared-interfaces/wizard'

export interface IExcelExport {
    worksheetName: string
    headers: string[]
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    data: any[][]
}

export interface IExcelHeader {
    label: string
    key: ELibColumn
    hidden?: boolean
    width?: number
    wrapText?: boolean,
    color?: string
}

export interface IExcelValidation {
    type: 'list' | 'whole' | 'decimal' | 'date' | 'textLength' | 'custom'
    truncate?: boolean
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    formulae: any[]
    allowBlank?: boolean
    operator?: IExcelValidationOperator
    error?: string
    errorTitle?: string
    errorStyle?: string
    prompt?: string
    promptTitle?: string
    showErrorMessage?: boolean
    showInputMessage?: boolean
}

export type IExcelValidationOperator =
    | 'between' | 'notBetween' | 'equal' | 'notEqual' | 'greaterThan' | 'lessThan'
    | 'greaterThanOrEqual' | 'lessThanOrEqual'
