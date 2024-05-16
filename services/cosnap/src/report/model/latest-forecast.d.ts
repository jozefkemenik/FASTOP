export interface ILatestComForecast {
    country_code: string
    years: number[]
    line: ILine
    bar: IBar
}

// this should be dynamic
export interface ILine {
    [name:string]:number[]
}

export interface IBar {
    Debt: number[]
}
