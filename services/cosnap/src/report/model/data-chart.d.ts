export interface IDataCharts {
    items: IItem[]
}

export interface IItem {
    title: string
    chart: IChart
    icon?: string
    order?: number
}

export interface ICou {
    value: number
    georef: string
}

export interface IData {
    min: ICou
    max: ICou
    median: ICou
    eu?: ICou
    cou?: ICou

    [key: string]: number | ICou
}

export interface INamedValue {
    [key: string]: number
}

export type IChartData = IData | INamedValue

export interface IChart {
    chart_type: string
    data: IChartData
}
