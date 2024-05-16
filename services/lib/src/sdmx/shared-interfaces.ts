export interface ISdmxDictionary {
    [key: string]: string[]
}

export const enum SdmxDataType {
    ATTRIBUTE = 'A',
    MEASURE = 'M',
    MEASURE_START = 'S'
}

export interface ISdmxId {
    id: string
    type?: SdmxDataType
}

export interface ISdmxDimensions {
    ids: ISdmxId[]
    dictionary: ISdmxDictionary
}

export interface ISdmxBag {
    dimensions: ISdmxDimensions
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    data: any[][]
}

export interface ISdmxCode {
    id: string
    name: string
}

export interface ISdmxCodeMap {
    [key: string]: ISdmxCode[]
}

export interface ISdmxStructure {
    dimensions: ISdmxCode[]
    dictionary: ISdmxCodeMap
}

export interface ISdmxLabels {
    [key: string]: Array<{[key: string]: string}>
}

export interface ISdmxDataItem {
    index: string[]
    item: {[key: string]: number | string}
    flags?: {[key: string]: number | string}
}

export interface ISdmxData {
    names: string[]
    data: ISdmxDataItem[]
    labels?: ISdmxLabels
    freq?: string
}

export const enum SdmxProvider {
    ESTAT ='estat',
    ECB = 'ecb',
    ECFIN = 'ecfin',
}
