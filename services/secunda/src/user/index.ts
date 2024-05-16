export * from './shared-interfaces'

export interface IDBUserAppGroup {
    APP_GROUP: string
    SUBGROUP: string
    GROUP_ORDER: number
    SUBGROUP_ORDER: number
    APP_NAME: string
    APP_DESCR?: string
    APP_LINK?: string
    ROUTE_DESCR?: string
    ROUTE?: string
    ROUTE_ROLES?: string
    PUBLIC_SUBGROUP?: number
}

export interface IDBAuth {
    APP_ID: string
    ROLE_ID: string
    LDAP_LOGIN: string
    COUNTRIES: string
}

export interface IAPIGWRole {
    userId: string
    roleId: string
    scopes?: IScopes
}

export interface IScopes {
    EU_Candidate_Countries: string[]
    EU_Member_States: string[]
}

export interface IToken {
    access_token: string
    scope: string
    token_type: string
    expires_is: number
}
