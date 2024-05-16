export interface IFPIndicatorGlossary {
    description: string
    where: string
    explanation?: string
}

export interface IFPBaseWorksheetDefinition {
    worksheetName: string
    startYear: number
    endYear: number
    headerTitle?: string
}

export interface IFPBaseIndicatorDefinition {
    indicatorId: string
    indicatorSid: number
}

export interface IFPCountryIndicatorData {
    countryId: string
    startYear: number
    vector: string
}

export interface IFPIndicatorDefinition extends IFPBaseIndicatorDefinition {
    excelTitle?: string
    glossary?: IFPIndicatorGlossary
    data?: IFPCountryIndicatorData[]
}

export interface IFPWorksheetDefinition extends IFPBaseWorksheetDefinition {
    indicators: IFPIndicatorDefinition[]
}

export interface IFPDefinition {
    countries: string[]
    worksheets: IFPWorksheetDefinition[]
}

export interface IFPVector {
    ctyId: string
    vector?: string
}

export interface IFPUpload {
    indSid: number
    year: number
    ctyData: IFPVector[]
}

export interface IFPWorksheet {
    worksheetSid: number
    name: string
    title: string
    startYear: number
    endYear: number
    orderBy: number
}

export interface IFPWorksheetIndicatorData {
    countryId: string
    startYear: number
    vector: string
    indicatorId: string
    indicatorSid: number
}
