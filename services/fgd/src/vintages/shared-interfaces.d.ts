export interface IVintageCols {
    [key: string] : string | number
}

export interface IVintageData extends IVintageCols {
    ENTRY_SID: number
}

export interface IVtAppAttrs {
    VINTAGE_ATTR_SID: number
    DISPLAY_NAME: string
    DEFAULT_SELECTED: number
    DISPLAY_HELP: string
    ORDER_BY: number
    IS_FILTER: number
    ADMIN_ONLY: number
}