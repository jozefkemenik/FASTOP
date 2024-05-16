import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'

export class NsiController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNsiData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async getNsiData(nsiType: string, countryId: string, params: any): Promise<any> {
        return ExternalDataApi.getNsiData(nsiType, countryId, params)
    }
}
