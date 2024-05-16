import { IAmecoInputSource } from './shared-interfaces'
import { IIndicatorDataWithoutTimeserie } from '../../../fdms/src/report/shared-interfaces'

export * from './shared-interfaces'

export interface IDBAmecoData extends IIndicatorDataWithoutTimeserie {
    TIMESERIE_DATA: string
    HST_TIMESERIE_DATA: string
    SRC_TIMESERIE_DATA: string
    LEVEL_TIMESERIE_DATA: string
}

export type IDBAmecoInputSource = IAmecoInputSource

export interface IDBAmecoNsiData {
    NSI_INDICATOR_SID: number
    NSI_INDICATOR_ID: string
    COUNTRY_ID: string
    TYPE: string
    PERIODICITY_ID: string
    START_YEAR: number
    UPDATE_DATE: Date
    UPDATE_USER: string
    TIMESERIE_DATA: string
    ORDER_BY: number
}
