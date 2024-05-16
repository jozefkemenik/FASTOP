export * from '../services/secunda/src/user/shared-interfaces'
export * from '../services/sum/src/user/shared-interfaces'

export interface IUserGroups {
    [groupId: string]: string[] // key: group id, value: countries
}

export interface IUserInfo {
    login: string
    name: string
    groups?: IUserGroups
    impersonated?: boolean
    anonymous?: boolean
}

export interface IAccessToken {
    token?: string
    timeout: number // in milliseconds
    generationTime?: number
}

export interface ITokens {
    code?: IAccessToken
    ip?: IAccessToken
}

