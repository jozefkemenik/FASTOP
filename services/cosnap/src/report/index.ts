interface IDBIdItems<T> {
    _id: string
    items: Array<T>
}

export interface IDBGeoRefValue {
    georef: string
    value: number
}

export interface IDBData {
    min: IDBGeoRefValue
    max: IDBGeoRefValue
    median: IDBGeoRefValue
    eu?: IDBGeoRefValue
    cou?: IDBGeoRefValue
}

export type IDBChartTypeData = IDBData | number[]

export interface IDBChart {
    chart_type: string
    data: IDBChartTypeData
    legend?: string[]
}

export interface IDBChartDataItem {
    title: string
    chart: IDBChart
    order: number
}

export type IDBChartData = IDBIdItems<IDBChartDataItem>

export interface IDBLine {
    // Deficit: number[]
    // Growth: number[]
    // Unemployment: number[]
    [name:string]:number[]
}

export interface IDBBar {
    Debt: number[]
}

export interface IDBForecastDataItems {
    country_code: string
    years: number[]
    line: IDBLine
    bar: IDBBar
}

export interface IDBIdSingleItem<T> {
    _id: string
    items: T
}

export interface IDBDataLegend {
    title: string
    legend: string[]
    data: number[]
}

export interface IDBName {
    text: string
    property?: string
}

export interface IDBRrpData {
    char?: IDBName
    name: IDBName
    value: IDBName
    perc?: string
}

export interface IDBRrpRow {
    color_group: number
    data: IDBRrpData
}

export type IDBLatestComForecast = IDBIdSingleItem<IDBForecastDataItems>
export type IDBMtStatus = IDBIdSingleItem<IDBDataLegend>
export type IDBRrpTable = IDBIdItems<IDBRrpRow>

export interface IDBTextRow {
    [key: string]: string[]
}

export interface IDBDataTexts extends IDBIdItems<IDBTextRow> {
    header: string[]
    footnotes: string
}

export interface IDBText {
    _id: string
    text: string
    editable?: boolean
}

export enum CosnapComponents {
    KEY_DATA = 'KeyData',
    DIGITAL_TRANSITION = 'DigitalTransition',
    GREEN_TRANSITION = 'GreenTransition',
    LATEST_COM_FORECAST = 'LatestComForecast',
    RRP = 'RrpTable',
    MT_STATUS = 'MtStatus',
    OTHER_EU_FUNDS = 'OtherEuFunds',

    // text fields
    KEY_FACTS = 'KeyFacts',
    IMPLEMENTATION_RISKS = 'ImplRisks',
    GT_KEY_CHALLENGES = 'GtKeyChallenges',
    GT_KEY_COMMITMENTS = 'GtKeyCommitments',
    DT_KEY_CHALLENGES = 'DtKeyChallenges',
    DT_KEY_COMMITMENTS = 'DtKeyCommitments',
    REFORMS = 'Reforms',
    INVESTMENTS = 'Investments',
    TSI_PROJECTS = 'TsiProjects',
    COUNTRY_SPECIFIC = 'CountrySpecific',
}
