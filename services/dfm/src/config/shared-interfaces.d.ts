export interface IOneOffPrinciple {
    id: string
    descr: string
}

export interface IOneOffPrinciples {
    [key: number]: IOneOffPrinciple
}

export interface ICustStorageText {
    CUST_STORAGE_TEXT_SID: number
    TITLE: string
    DESCR: string
}
