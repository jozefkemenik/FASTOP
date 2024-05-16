export * from './shared-interfaces/dashboard'

export enum DashboardHeader {
    DRM_STATUS = 'DRM',
    TR_STATUS = 'TR',
    DFM_STATUS = 'DFM',

    CURRENT_STATUS = 'currentStatus',
    FIRST_INPUT = 'firstInputDate',
    LAST_INPUT = 'lastInputDate',
    LAST_SUBMIT = 'submitionDate',
    LAST_VALIDATION = 'validationDate',
    OUTPUT_GAP = 'outputGapDate',
    LAST_ARCHIVE = 'archiveDate',
    LAST_UPLOAD = 'lastUploadDate',
    LAST_ACCEPTED = 'lastAcceptedDate',
}
