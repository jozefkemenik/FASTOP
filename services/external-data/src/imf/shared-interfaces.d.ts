export interface IImfDataSet {
    countryId: string
    freqId: string
    indicatorId: string
    scaleId: string
    startYear: number
    endYear: number
    series: {[periodId: string]: number}
}

export type IImfDictionary = {[dictionaryKey: string]: { [valueKey: string]: string } | number}

export interface IImfData {
    dictionary: IImfDictionary
    dataSets: IImfDataSet[]
}

export const enum ImfDictionaryKey {
    FREQ = 'CL_FREQ',
    COUNTRY = 'CL_AREA_IFS',
    INDICATOR = 'CL_INDICATOR_IFS',
    SCALE = 'CL_UNIT_MULT',
    DIMENSION_COUNTRY = 'DIMENSION_REF_AREA_INDEX',
    DIMENSION_INDICATOR = 'DIMENSION_INDICATOR_INDEX',
}
