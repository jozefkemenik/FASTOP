import {
    IEerCountry,
    IEerGeoGroup,
    IEerProviderIndicatorData
} from '../../../auxtools/src/eer/shared-interfaces'

import { EApps } from 'config'
import { RequestService } from '../request.service'


export class EerApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////


    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public static getIndicatorData(
        providerId: string,
        group: string,
        periodicity: string,
    ): Promise<IEerProviderIndicatorData> {
        return RequestService.request(
            EApps.AUXTOOLS, `/eer/indicator/data/${providerId}?group=${group}&periodicity=${periodicity}`
        )
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public static getCountries(): Promise<IEerCountry[]> {
        return RequestService.request(EApps.AUXTOOLS, `/eer/countries`)
    }

    /**********************************************************************************************
     * @method getGeoGroups
     *********************************************************************************************/
    public static getGeoGroups(activeOnly : boolean): Promise<IEerGeoGroup[]> {
        return RequestService.request(EApps.AUXTOOLS, `/eer/geo/groups?activeOnly=${activeOnly}`)
    }

}
