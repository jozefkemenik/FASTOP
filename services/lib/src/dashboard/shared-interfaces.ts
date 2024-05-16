import { EStatusRepo } from 'country-status'

export interface IDashboardCtyStatus {
    statusDescr: string
    statusId: EStatusRepo
}

// key is the DashboardHeader
export interface IDashboardDatas {
    [key: string]: IDashboardCtyStatus
}

export interface ICountryData {
    countryId: string
    countryDescr: string
}

export interface IDashboardStatusChangesLog {
    [status: string]: string | Date
}

export interface IDashboardRow {
    data: IDashboardDatas
    error?: boolean
    updated?: boolean
    lastChangeDate?: string
    lastChangeUser?: string
    changesLog?: IDashboardStatusChangesLog
}

// key is the countryId
export interface IDashboardRows {
    [key: string]: IDashboardRow
}

export interface IDashboard {
    countries: ICountryData[]
    rows: IDashboardRows
    globals?: Array<[string, string]>
}

export interface ICtyActionResult {
    result: number
    updatedRow?: IDashboardRow
}
