export interface IUserAppGroup {
    name: string
    subgroups: IUserAppSubgroup[]
}

export interface IUserAppSubgroup {
    name: string
    apps: IUserApp[]
}

export interface IUserApp {
    id: string
    descr: string
    link?: string
    routeDescr?: string
    route?: string
}

export interface IUserAuthz {
    groupId: string
    countries: string[]
}

export interface IUserAuthzs {
    [app: string]: IUserAuthz[]
}
