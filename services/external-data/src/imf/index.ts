// data elements

export interface IImfRawObs {
    '@TIME_PERIOD': string,
    '@OBS_VALUE': string,
}

export interface IImfRawSeries {
    '@FREQ': string,
    '@REF_AREA': string,
    '@INDICATOR': string,
    '@UNIT_MULT': string,
    '@TIME_FORMAT': string,
    Obs: IImfRawObs[]
}

export interface IImfRawDataSet {
    Series: IImfRawSeries | IImfRawSeries[]
}

export interface IImfRawCompactData {
    DataSet: IImfRawDataSet
}

export interface IImfRawData {
    CompactData: IImfRawCompactData
}

// dictionary elements

export interface IImfRawText {
    '#text': string
}

export interface IImfRawCode {
    '@value': string
    Description: IImfRawText
}

export interface IImfRawCodeList {
    '@id': string
    Name: IImfRawText
    Code: IImfRawCode[]
}

export interface IImfRawCodeLists {
    CodeList: IImfRawCodeList[]
}

export interface IImfRawDimension {
    '@conceptRef': string
    '@codelist': string
}

export interface IImfRawComponents {
    Dimension: IImfRawDimension[]
}

export interface IImfRawKeyFamily {
    Components: IImfRawComponents
}

export interface IImfRawKeyFamilies {
    KeyFamily: IImfRawKeyFamily
}

export interface IImfRawStructure {
    CodeLists: IImfRawCodeLists
    KeyFamilies: IImfRawKeyFamilies
}

export interface IImfRawDictionary {
    Structure: IImfRawStructure
}
