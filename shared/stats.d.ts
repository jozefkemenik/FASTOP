import { AmecoType } from '../services/shared-lib/dist/prelib/ameco'

export interface IAccessInfo {
    user: string
    ip: string
    url: string
    agent: string
    intragate: boolean
}

export interface IAmecoStats {
    userId: string
    source: string
    agent: string
    addr: string
    amecoType: AmecoType
    uri: string
}
