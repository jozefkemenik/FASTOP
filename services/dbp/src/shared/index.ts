import { IDictionaries as IFDDictionaries } from '../../../lib/dist/measure/fisc-drm/shared'
import { IObjectSIDs } from '../../../lib/dist/measure'

export interface IDictionaries extends IFDDictionaries {
    dbpSources: IObjectSIDs
}
