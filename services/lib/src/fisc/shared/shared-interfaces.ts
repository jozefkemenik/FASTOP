export interface IGrid {
    GRID_SID: number
    GRID_ID: string
    DESCR: string
    ROUTE: string
    GRID_TYPE_ID: string
}

export interface IIndicator {
    INDICATOR_SID: number
    INDICATOR_ID: string
    DESCR: string
}

export interface ILineIndicator {
    LINE_SID: number
    INDICATOR_SID: number
    DATA_TYPE_SID: number
}

export interface IHelpMessage {
    HELP_MSG_SID?: number
    DESCR: string
    MESS: string
}

export interface ISemiElasticityData {
    VALUE: number
    ROUND_SID: number
    COUNTRY_ID: string
    COUNTRY_DESCR: string
    YEAR: number
    PERIOD_DESCR: string
    ROUND_DESCR: string
}

export interface IDataType {
    DATA_TYPE_SID: number
    DATA_TYPE_ID: string
    DESCR: string
    LINE_INDICATOR_DISPLAY: number
}
