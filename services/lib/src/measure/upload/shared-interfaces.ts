import { IExcelHeader, IExcelValidation } from '../../excel'
import { ELibExercise } from '../../../../shared-lib/dist/prelib/shared-interfaces/wizard'

export interface IRoundPeriod {
    roundSid: number
    year: number
    periodId: string
}

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type ILibMeasureValue = Record<string, any>

export interface ILibMeasureUpload {
    measureSid?: number
    values: ILibMeasureValue
}

export interface ILibMeasureWizardUpload {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    globalData?: any
    measures: ILibMeasureUpload[]
}
export interface ILibColumnConfig extends IExcelHeader {
    dictionary?: IDictionary
    dataValidation?: IExcelValidation
    yearData?: number
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    defaultValue: any
    exercise?: ELibExercise
}

export interface ILibWorksheetConfig {
    title: string // title of the worksheet
    key?: string // worksheet key (to identify the worksheet in case more then one)
    firstDataRow: number // first row where data begins
    isRequired: boolean // indicator if the worksheet is required
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    globalDataConfig?: any // any global data, e.g. measure scale
    columns: ILibColumnConfig[]
}

export interface ILibVectorConfig {
    startYear: number,
    endYear: number
}

export interface ILibWorkbookConfig {
    maxRows: number // max number of rows in the excel that should be processed
    vectorConfig: ILibVectorConfig // start-end year vector
    roundPeriod?: IRoundPeriod
    worksheets: ILibWorksheetConfig[]
}

export interface IDictionaryValue {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    [key: string]: any
}

export interface IDictionary {
    length: number // number of items in the dictionary
    column: string // column key
    data: IDictionaryValue // map (key = 'descr', value = 'sid')
    dbData: IDictionaryValue // map (key = 'sid', value = 'descr')
    itemMaxLength: number // max descr length (for calculating column width)
}

export interface IMeasureObject {
    TITLE: string,
    SHORT_DESCR: string,
    SOURCE_SID: number,
    ESA_SID: number,
    ACC_PRINCIP_SID: number,
    ADOPT_STATUS_SID: number,
    DATA: string,
    START_YEAR: number,
    YEAR: number,
    ONE_OFF_SID: number,
    ONE_OFF_TYPE_SID: number,
    ONE_OFF_DISAGREE_SID: number,
    ONE_OFF_COMMENTS: string,
    EXERCISE_SID: number,
    STATUS_SID: number,
    NEED_RESEARCH_SID: number,
    INFO_SRC: string,
    ADOPT_DATE_YR: number,
    ADOPT_DATE_MH: number,
    COMMENTS: string,
    REV_EXP_SID: number,
    ESA_COMMENTS: string,
    QUANT_COMMENTS: string,
    OO_PRINCIPLE_SID: number,
    UPLOADED_MEASURE_SID: number,
    LABEL_SIDS: number[],
    IS_EU_FUNDED_SID: number,
    EU_FUND_SID: number,
}

export interface IMeasureUpload {
    countryId: string,
    scaleSid: number,
    measures: IMeasureObject[]
}
