import { ILibDictionaries, IObjectSIDs } from '../../../lib/dist/measure'
import { IOneOffPrinciples } from '../config'

export interface IDictionaries extends ILibDictionaries {
    statuses: IObjectSIDs
    revexp: IObjectSIDs
    oneOffPrinciples: IOneOffPrinciples
    overviews: IObjectSIDs
}
