export interface IRrp {
    rows: IRrpRow[]
}

export interface IRrpRow {
    color_group: number
    bgColor?: string
    data: IRrpData
}

export interface IRrpData {
    char: IName | null
    name: IName
    value: IName
    perc: number | null
}

export interface IName {
    text: string
    property: EProperty | null
}

export const enum EProperty {
    Bold = 'bold',
}
