
export interface IDBLogUpload {
    UPLOAD_SID :number
    USER_ID: string
    LATEST_DATE: Date
    DATASET: string
    PROVIDER: string
    FOLDER?: string
    STATUS?: string
    STATE?: string
}

export interface IDBStatusTransition {
    STATUS_ID: string
    STATE_CHANGE: number
    VALID_STATUSES: string
}

export interface IStatusTransition {
    status: string
    canChangeState: boolean
    validStatuses: Set<string>
}
