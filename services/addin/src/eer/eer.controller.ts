import {
    IEerCountry,
    IEerGeoGroup,
    IEerProviderIndicatorData
} from '../../../auxtools/src/eer/shared-interfaces'
import { EerApi } from '../../../lib/dist/api/eer.api'
import { catchAll } from '../../../lib/dist/catch-decorator'

@catchAll(__filename)
export class EerController {

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(
        providerId: string,
        group: string,
        periodicity: string,
    ): Promise<IEerProviderIndicatorData> {
        return EerApi.getIndicatorData(providerId, group, periodicity)
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public getCountries(): Promise<IEerCountry[]> {
        return EerApi.getCountries()
    }

    /**********************************************************************************************
     * @method getGeoGroups
     *********************************************************************************************/
    public async getGeoGroups(): Promise<IEerGeoGroup[]> {
        return EerApi.getGeoGroups(true)
    }
}
