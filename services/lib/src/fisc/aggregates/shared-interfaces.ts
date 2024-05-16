export interface IAggregateParameters {
    countryArea: string
    eaArea: string
    nominalCode: string
}

export type AggregateType = 'LINE' | 'INDICATOR'

export interface IVariableGroup {
    name: string
    variables: IVariable[]
}

export interface IAggregateCalcResult {
    calcResult: AggCalcResult
    lastChangeUser?: string
    lastChangeDate?: Date
}

export interface IVariable extends IAggregateCalcResult {
    code: string
    name: string
    aggDataSid?: number
    weightIndicator?: string
    weightingYear?: number
    aggType: AggregateType
    comparableVariableId?: string
}

export interface IWeightVariable {
    code: string
    weightIndicator?: string
}

export interface IVariableParams {
    lines: IWeightVariable[]
    indicators: IWeightVariable[]
}

export interface IVariableExcelParams {
    variables: string[]
    lines: string[]
    indicators: string[]
}

export interface IAggregateVariable {
    variableCode: string
    vector: string[]
    weights: string[]
}

export interface IAggregateCountryParam {
    countryId: string
    variables: IAggregateVariable[]
}

export interface IAggregateCalcParams {
    startYear: number
    endYear: number
    countryVariables: IAggregateCountryParam[]
}

export type AggCalcResult = 'OK' | 'NO_CALC' | 'FAILED'

export interface IAggregateCalcResults {
    [code: string]: IAggregateCalcResult
}
