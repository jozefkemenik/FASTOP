export interface ICountryIdxCalcStage {
    STAGE_SID: number
    ITERATION: number
    LDAP_LOGIN: string
    ORGANISATION: string
    DATETIME: string
}

export type ICountryIdxCalcStageMapping = Record<number, ICountryIdxCalcStage>

export type IHorizCols = string[]
export interface IHorizontalStage extends IHorizCols {
    ENTRY_SID: number
}

export interface IHorizontalColumn {
    COLUMN_DESCR: string
    COLUMN_NAME: string
}