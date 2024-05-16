export interface IAnswer {
    QUESTION_ANSWER_ID: string
    DESCR: string
    ANSWER_SID: number
    FREQ: string
}

export interface IObservationRange {
    MIN_DATE: Date
    MAX_DATE: Date
}

//START_PERIOD, SERIES_CODE, SERIES_VECTOR
export type IObservationRow = [Date, string, string]

export interface IObservationSeries {
    data: IObservationRow[]
    columns: string[]
}

export interface IQuestion {
    SURVEY_QUESTION_ID: string
    DESCR: string
    QUESTION_SID: number
    SURVEY_ID: string
    FREQ: string
}

export interface ISeasonalAdjustment {
    S_ADJ_ID: string
    S_ADJ_SID: number
    DESCR: string
}

export interface ISector {
    SECTOR_ID: string
    DESCR: string
    SECTOR_SID: number
    SURVEY_ID: string
}

export interface ISurvey {
    SURVEY_ID: string
    DESCR: string
}

export interface IBcsSearchCriteria {
    surveyIds: string[]
    countryIds: string[]
    sectorSids: number[]
    questionSids: number[]
    answerSids: number[]
    startYearMonth: number
    endYearMonth: number
    seasonallyAdjusted: number
    frequencyId: string
    serieCodes: string[]
}