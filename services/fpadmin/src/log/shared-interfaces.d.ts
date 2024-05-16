export interface IAccessLog {
    userId: string
    app: string
    uri?: string
    isIntragate: boolean
    latestIp: string
    latestAccess: Date
}
