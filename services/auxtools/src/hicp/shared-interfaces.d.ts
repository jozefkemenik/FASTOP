interface IBaseCategory {
    categoryId: string
    label: string
    rootIndicatorId?: string
    baseIndicatorId?: string
}
export interface IHicpCategory extends IBaseCategory {
    categorySid: number
    childSids?: number[]
    isDefault: boolean
    indicators: string[]
    orderBy?: number
}

export interface IHicpCategoryIndicators extends IBaseCategory {
    indicatorIds: string[]
}

export const enum HicpFrequency {
    MOM = 'MoM',
    YOY = 'YoY'
}

export const enum HicpDataset {
    INDEX = 'INDEX',
    CONSTANT_TAX_RATES = 'TAX_RATES',
}

export const enum HicpIndicatorDataType {
    ITEM = 'I',
    WEIGHT = 'W',
}

export interface IBaseHicpIndicator {
    indicatorCodeSid: number
    indicatorId: string
    descr: string
    lastUpdated: Date
    updatedBy: string
}

export interface IHicpVector {
    startYear: number
    vector: number[]
}

export interface IHicpIndicator extends IBaseHicpIndicator {
    weight: number[]
    index: number[]
}

export interface IHicpExcelRange {
    startYear: number
    startMonth: number
    monthlyLength: number
    annualLength: number
}

export interface IHicpExcelData {
    indicators: IHicpIndicator[]
    range: IHicpExcelRange
}

export interface IHicpCalculationRange {
    from: string
    to: string
}

export interface IHicpBaseCalcParams {
    dataset: HicpDataset
    countryId: string
    indicatorIds: string[]
    rangeFrom: string
    rangeTo: string
    seats? : ECalcMethod,
}

export const enum ECalcMethod {
    NONE = 0,
    JDEMETRA = 1,
    X13 = 2
}

export interface IBaseEffectCalcParams extends IHicpBaseCalcParams {
    forecast?: number
}

export interface IHicpCalcParams extends IHicpBaseCalcParams {
    baseIndicatorIds: string[]
    frequencies: HicpFrequency[]
    percentageTrimmedMean: number
    category: string
}

export interface IHicpCalcVector {
    name: string
    data: string[]
    flag?: number
}

export interface IHicpCalcMatrix {
    startYear: number
    startPeriod: number
    rows: IHicpCalcVector[]
    name?: string
    startPeriodPred?: number  // index from which the forecast data starts
}

export interface IHicpCalcFreqMatrix {
    frequency: HicpFrequency
    summary: HicpCalcResampled
    index?: IHicpCalcMatrix
}

export interface IHicpCalcResult {
    weight?: IHicpCalcMatrix
    summary: IHicpCalcFreqMatrix[]
}

export interface HicpCalcResampled {
    monthly: IHicpCalcMatrix
    quarterly: IHicpCalcMatrix
}

export interface IHicpAnomaliesRange {
    startYear: number
    endYear: number
}

export interface IHicpAggCalcExtendedResult {
    monthly: IHicpCalcMatrix[]
    quarterly: IHicpCalcMatrix[]
}

export interface IHicpIndicatorVectors {
    weight: number[]
    index: number[]
}

export interface IHicpIndicatorData {
    range: IHicpIndexRange
    vectors: {[indicatorCodeSid: number]: IHicpIndicatorVectors}
}

export interface IHicpIndicatorCode {
    indicatorCodeSid: number
    indicatorId: string
    descr: string
    parentCodeSids?: number[]
    vectors?: IHicpIndicatorVectors
}

export interface IHicpIndexRange {
    startYear: number
    months: number
}

export interface IHicpCountry {
    countryId: string
    descr: string
}
