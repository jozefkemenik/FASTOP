export interface IBaselineData {
    variableId: string
    countryId: string
    year: number
    value: string
}

export interface IBaselineVariable {
    variableSid: number
    variableId: string
    countryId?: string
    orderBy: number
    groupByCountry: number
}

export interface IBaselineDefinition {
    countries: string[]
    variables: IBaselineVariable[]
}

export interface IBaselineUpload {
    variableSid: number
    countryId: string
    year: number
    value: string
}

export interface ICountryParamsData {
    paramId: string
    countryId: string
    value: string
}

export type CountryParamDataType = 'BOOL' | 'BOOLNUM' | 'STR' | 'NUMERIC'

export interface ICountryParam {
    paramSid: number
    paramId: string
    dataType: CountryParamDataType
    defaultValue: string
}

export interface ICountryParamsDefinition {
    countries: string[]
    params: ICountryParam[]
}

export interface ICountryParamsUpload {
    paramSid: number
    countryId: string
    value: string
}

export interface IGeneralParamValue {
    code: string
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    value: any
}
