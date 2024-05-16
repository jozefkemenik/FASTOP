import { IFPWorksheet, IFPWorksheetIndicatorData } from './shared-interfaces'

export * from './shared-interfaces'

export interface IFPTemplateDB {
    WORKSHEET_SID: number,
    WORKSHEET_NAME: string,
    WORKSHEET_HEADER?: string,
    START_YEAR: number,
    END_YEAR: number,
    INDICATOR_SID: number,
    INDICATOR_ID: string,
    GLOSSARY_DESC: string,
    GLOSSARY_LOCATION: string,
    GLOSSARY_EXPLANATION?: string,
    EXCEL_IND_TITLE?: string,
    WORKSHEET_ORDER?: number,
    INDICATOR_ORDER?: number
}

export interface IFPUploadParamsDB {
    roundSid: number
    lastChangeUser: string
    indicators: number[]
    countries: string[]
    startYears: number[]
    vectors: string[]
}

export type IDBFPWorksheet = IFPWorksheet
export type IDBFPWorksheetIndicatorData = IFPWorksheetIndicatorData