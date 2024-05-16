import { IDBSidType, ILibDictionaries, IObjectSIDs } from '../../shared'

export interface IDictionaries extends ILibDictionaries {
    dbpAdoptStatues: IObjectSIDs
    dbpAccPrinciples: IObjectSIDs
    guaranteeReasons: IObjectSIDs|IDBSidType[]
}
