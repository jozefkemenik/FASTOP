import { EStatusRepo } from 'country-status'

export interface IBaseRoundInfo {
    roundSid: number
    year: number
    periodDesc: string
    title: string
    isActive: number
    version: number
    activated: number
    activationDate?: Date
    activationUser?: string
}

export interface INextRoundInfo extends IBaseRoundInfo {
    periodSid: number
}

export interface IInputParamsValidation {
    inputYearOk: boolean
    inputPeriodSidOk: boolean
}

export interface INewRoundValidation extends IInputParamsValidation {
    storageOk: boolean
}

export interface IActivateRoundAppStatus {
    appId: string
    status: string
    statusChange: number
}

export interface IBaseRoundValidation {
    roundOk: boolean
    storageOk: boolean
    appStatus: IActivateRoundAppStatus[]
}

export interface IActivateRoundValidation extends IBaseRoundValidation {
        forecastAggStatusId: EStatusRepo
}

export interface INewRoundResult extends IInputParamsValidation {
    gridRoundAppId?: string
    gridsOk?: boolean
}

export interface ICustomRoundResult extends IInputParamsValidation {
    versionOk: boolean
}

export interface IPeriod {
    periodSid: number
    periodId: string
    descr: string
    order: number
}
