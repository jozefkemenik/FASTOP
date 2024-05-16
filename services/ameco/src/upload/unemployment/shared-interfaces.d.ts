import { IFdmsIndicator } from '../../../../fdms/src/upload/shared-interfaces'

export interface IAmecoRawInputUpload {
    countryId: string
    startYear: number
    indicatorSids: number[]
    timeSeries: string[]
}

export type IAmecoIndicator = IFdmsIndicator
