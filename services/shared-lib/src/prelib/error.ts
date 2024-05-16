export enum EErrors {
    NO_ERROR = 0,

    NEEDS_CONFIRMATION = -999,
    IGNORE,

    ROUND_KEYS = -9999,
    APP_STATUS,
    CTY_STATUS,
    APP_CTY_STATUS,
    CTY_ACTION,
    NO_COUNTRIES,
    ALL_SUBMITTED,
    ARCHIVE_DFM,
    IDR_SCALE_INVALID,
    IDR_SCALE_DIFFERENT,
    IDR_DUPLICATE,
    ID_NOT_PROVIDED,

    EMAIL_EXISTS,
    NOT_FULL_OG,
    ALL_ACCEPTED,
    NOT_FULL_STORAGE,
    NO_FILE
}

const m = {}
m[EErrors.ROUND_KEYS] = 'Invalid round/storage information'
m[EErrors.APP_STATUS] = 'Invalid application status'
m[EErrors.CTY_STATUS] = 'Invalid country status'
m[EErrors.APP_CTY_STATUS] = 'Invalid country or application status'
m[EErrors.CTY_ACTION] = 'Invalid country action'
m[EErrors.NO_COUNTRIES] = 'No countries have been selected for the action'
m[EErrors.ALL_SUBMITTED] = 'All involved countries must submit first'
m[EErrors.ARCHIVE_DFM] = 'DFM cannot be archived. Please verify that all countries have submitted.'
m[EErrors.IDR_SCALE_INVALID] = 'Invalid/unrecognized indicator scale'
m[EErrors.IDR_SCALE_DIFFERENT] = 'Indicator data should be provided in different scale'
m[EErrors.IDR_DUPLICATE] = 'Duplicate entries for indicator'
m[EErrors.ID_NOT_PROVIDED] = 'ID not provided for update'
m[EErrors.EMAIL_EXISTS] = 'The provided email already exists'
m[EErrors.NOT_FULL_OG] = 'Full Output Gap not calculated'
m[EErrors.ALL_ACCEPTED] =  'All countries must be accepted'
m[EErrors.NOT_FULL_STORAGE] =  'Current storage is not the full storage'


export const errorMessages = m

export class FastopError extends Error {
    constructor(public code?: EErrors, message?: string) {
        super(message)
    }
}

export class SilentError extends Error {
    public readonly silent = true
    constructor(message?: string) {
        super(message)
    }
}

export const FASTOP_HTTP_ERROR_STATUS = 550
