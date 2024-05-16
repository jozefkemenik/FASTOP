import { IDataCharts } from './data-chart'
import { ILatestComForecast } from './latest-forecast'
import { IRrp } from './rrp'

export { ICou, IChartData, IItem, IDataCharts } from './data-chart'
export { ILatestComForecast } from './latest-forecast'
export { IRrp } from './rrp'

export interface IMTStatus {
    title: string
    legend: string[]
    data: number[]
}

export interface ICosnapCountry {
    code: string
    name: string
}

export interface IDataTexts {
    header: string[]
    footnotes: string
    data: string[][]
}

export type IOtherEuFunds = IDataTexts

export interface IText {
    id: string
    text: string
    editable?: boolean
}

export interface ICosnapReport {
    lastUpdate: Date
    keyData: IDataCharts
    digitalTransition: IDataCharts
    greenTransition: IDataCharts
    latestComForecast: ILatestComForecast
    rrp: IRrp
    mtStatus: IMTStatus
    otherFunds: IOtherEuFunds

    keyFacts: IText
    implementationRisks: IText
    gtKeyChallenges: IText
    gtKeyCommitments: IText
    dtKeyChallenges: IText
    dtKeyCommitments: IText
    reforms: IText
    investments: IText
    tsiProjects: IText
    countrySpecific: IText
}
