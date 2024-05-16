export interface IBcsSeries {
    [key: string]: string
}

export interface IBcsTimeSeries {
    start: string // yyyyMmm or yyyyQq
    freq: string
    series: IBcsSeries
}
