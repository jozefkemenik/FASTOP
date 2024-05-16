export interface IWQImfDataSet {
    country: string
    freq: string
    indicatorId: string
    indicator: string
    scale: string
    series: {[periodId: string]: number}
}

export interface IWQImf {
    periods: string[]
    dataSets: IWQImfDataSet[]
}