declare module 'express-session' {
    interface SessionData {
        user: IUser
        csrfSecret?: string
        tokens?: ITokens
    }
}

import { ITokens, IUserAuthzs } from 'users'

export interface IEcasUser {
    userId: string
    loginDate: string
    groups: string[],
    departmentNumber?: string
    email?: string
    employeeType?: string
    firstName?: string
    lastName?: string
    domain?: string
    domainUsername?: string
    telephoneNumber?: string
    locale?: string
    userManager?: string
    pgtIou?: string
}

export interface IUser {
    authenticated: boolean
    ecas: IEcasUser
    authzs: IUserAuthzs
    impersonated: IUserAuthzs
    anonymous?: boolean
}

