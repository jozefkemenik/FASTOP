import * as oracledb from 'oracledb'

export const BIND_IN = oracledb.BIND_IN
export const BIND_INOUT = oracledb.BIND_INOUT
export const BIND_OUT = oracledb.BIND_OUT
export const CURSOR = oracledb.CURSOR.num
export const DATE = oracledb.DATE.num
export const DB_TYPE_DATE = oracledb.DB_TYPE_DATE.num
export const DB_TYPE_TIMESTAMP = oracledb.DB_TYPE_TIMESTAMP.num
export const NUMBER = oracledb.NUMBER.num
export const STRING = oracledb.STRING.num
export const BUFFER = oracledb.BUFFER.num
export const BLOB = oracledb.BLOB.num

// user defined DB types
export const [
    CLOBLIST, GUARANTEEARRAY, GUARANTEEOBJECT, MEASUREARRAY, SIDSLIST, VARCHARLIST
] = [
    'CLOBLIST', 'GUARANTEEARRAY', 'GUARANTEEOBJECT', 'MEASUREARRAY', 'SIDSLIST', 'VARCHARLIST'
]

export interface ISPBaseParam {
    name: string
    dir?: number
    type: number|string
    maxSize?: number
}

export interface ISPParam extends ISPBaseParam {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    value?: number|string|Date|object|number[]|string[]|Date[]|Buffer|any[]
}

export interface ISPOptions {
    params?: ISPParam[]
    arrayFormat?: boolean,
    maxRows?: number,
    skipLogs?: boolean,
    fetchInfo?: Record<string, {
        type: number
    }>
}