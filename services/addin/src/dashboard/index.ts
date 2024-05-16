export interface IDBAuthApp {
    OWNER_APP_ID: string
    ROLES?: string
}

export interface IDBAddinApp extends IDBAuthApp {
    DASHBOARD_SID: number
    TITLE: string
    LINK: string
}

export interface IDBAddinTreeApp extends IDBAuthApp {
    TREE_SID?:number
    PARENT_TREE_SID?:number
    DASHBOARD_SID?: number
    TITLE: string
    LINK?: string
    JSON_DATA?:string
}
