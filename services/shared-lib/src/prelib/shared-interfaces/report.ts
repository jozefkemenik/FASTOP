export interface IStandardReport {
    COUNTRY_ID: string
    DATA: number[]
    dataWithoutGDP?: number[]
    revexpSid?: number
    labelSids: number[]
}

export interface IReportFilter {
    yearAdoption: number[]
    monthAdoption: number[]
    labels: number[]
    isEuFunded: number[]
    oneOff?: number[]
}
