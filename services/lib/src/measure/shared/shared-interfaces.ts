export interface IESACode {
    descr: string
    id: string
    revexpSid: number
    overviewSid: number
}

export interface IESACodes {
    [key: number]: IESACode
}

export interface IMeasuresRange {
    startYear: number
    yearsCount: number
}

export interface IGDPPonderation {
    [countryId: string]: number[]
}

export interface ICountryMultipliers {
    [country: string]: { multi: number, scale: string }
}

export interface IObjectSIDs {
    [key: number]: string
}

export interface IObjectPID {
    PID: string
    DESCRIPTION: string
}

export interface IObjectPIDs {
    [key: number]: IObjectPID
}

export interface ISidType {
    SID: number
    DESCRIPTION: string
}

export interface IScale {
    sid: number
    id: string
    description: string
}
