export interface IDBAccessLog {
    USER_ID: string
    APP: string
    URI?: string
    INTRAGATE?: number
    LATEST_IP: string
    LATEST_ACCESS_DATE: Date
}
