import { EApps } from 'config'

import { IArchiveParams, IMeasuresDenormalised } from '../measure'
import { RequestService } from '../request.service'
import { buildQuery } from './util'

export class MeasureApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getMeasures
     *********************************************************************************************/
    public static getMeasures(
        app: EApps, countryId?: string, gdp?: boolean, archive?: IArchiveParams
    ): Promise<IMeasuresDenormalised> {
        const query = buildQuery(Object.assign({}, {countryId, gdp}, archive))
        return RequestService.request(app, `/measures/denormalised${query}`)
    }
}
