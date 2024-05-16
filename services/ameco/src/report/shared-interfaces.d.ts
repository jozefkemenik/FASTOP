import { IIndicatorDataWithoutTimeserie } from '../../../fdms/src/report/shared-interfaces'

export interface IAmecoData extends IIndicatorDataWithoutTimeserie {
    TIMESERIE_DATA: number[]
    HST_TIMESERIE_DATA: number[]
    SRC_TIMESERIE_DATA: number[]
    LEVEL_TIMESERIE_DATA: number[]
}

export interface IAmecoCountryCode {
    countryId: string
    code: number
}

export interface IAmecoInputSource {
    sid: number
    code: string
}

export const enum AmecoNsiType {
    HOUSEHOLDS = 'UH',
    CORPORATIONS = 'UC',
    TOTAL_ECONOMY = 'TE',
}

export interface IAmecoNsiIndicator {
    indicatorId: string
    countryId: string
    type: AmecoNsiType
    periodicity: string
    startYear: number
    lastUpdate: Date
    updatedBy: string
    timeSeries: Array<Array<number>>
}
