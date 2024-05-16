import { ILinkedTableValues, IYearRange } from './shared-interfaces'

export * from './shared-interfaces'

export interface IDBCommonData {
    countryCd: string
}

export interface IDBCommonVectorData extends IDBCommonData {
    startYear: number
    source: string
    vector: string
    lastChangeDate: string
}

export interface IDBUPloadedData extends IDBCommonVectorData {
    indicatorId: string
    amecoCode: string
}

export interface IDBAmecoData extends IDBCommonVectorData {
    amecoCode: string
    variable: string
}

export interface IDBCalculatedData extends IDBCommonVectorData {
    indicatorId: string
}

export interface IDBCommonGridData extends IDBCommonData {
    key: string
    lineId: string
    year: number
}

export interface IDBLevelsData extends IDBCommonGridData {
    value: string
}

export interface IDBGrowthData extends IDBCommonGridData {
    valueP: string
    valueCd: string
}

export interface IDBCountryData {
    countryId: string
    countryDesc: string
    isInEAGroup: number
}

export type FetchFunctionType = (
    countryId: string,
    roundSid: number,
    range: IYearRange,
) => Promise<ILinkedTableValues[]>

export type VariablesFunctionType = (countryId: string, roundYear: number, roundSid: number) => Promise<ILinkedTableValues>

export type ProgramFunctionType = (countryId: string, roundSid: number, isInEAGroup: boolean) => Promise<ILinkedTableValues>
