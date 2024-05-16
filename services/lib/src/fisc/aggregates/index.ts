import { AggregateType } from './shared-interfaces'

export * from './shared-interfaces'

export interface IDBVariable {
    AGG_DATA_SID: number
    AGG_TYPE_ID: string
    DESCR: string
    LAST_CHANGE_USER: string
    LAST_CHANGE_DATE: Date
    WEIGHT_INDICATOR: string
    WEIGHTING_YEAR: number
    AGG_TYPE: AggregateType
    GR_DESCR: string
    COMPARABLE_VARIABLE_ID: string
}

export interface IBaseData {
    variableId: string
    countryId: string
}

export interface ILineData extends IBaseData {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    vectorCd: any[]
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    vectorPublic: any[]
    isLevel: boolean
}

export interface IVectorData extends IBaseData {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    vector: any[]
}

export interface ILevelData {
    countryId: string
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    value: any
}

export interface IDBCellValue {
    LINE_ID: string
    COUNTRY_ID: string
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    VALUE_CD: any
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    VALUE_P: any
    START_YEAR: number
    YEAR_VALUE: number
    IS_LEVEL: number
}

export interface IDBVariableVector {
    VARIABLE_ID: string
    COUNTRY_ID: string
    START_YEAR: number
    VECTOR: string
}

export interface IDBLevel {
    COUNTRY_ID: string
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    VALUE_CD: any
}

export interface IDBAggregateVariable {
    VARIABLE_ID: string
    START_YEAR: number
    VECTOR: string
}

export interface ICalculatedAggregate {
    [countryGroupId: string]: {[variableId: string]: string}
}
