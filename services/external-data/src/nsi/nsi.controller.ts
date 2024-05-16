import { RequestService } from '../../../lib/dist/request.service'

export class NsiController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private mdbUrls = {
        pl: 'https://bdm.stat.gov.pl/app/'
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNsiData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async getMdbData(countryId: string, params: any): Promise<any> {
        const url = this.mdbUrls[countryId.toLowerCase()]
        if (!url) throw Error('Unknown macroeconomic data bank endpoint!')

        const endpoint = params.endpoint
        delete params.endpoint
        const queryParams = Object.keys(params).map(k => `${k}=${params[k]}`).join('&')

        return RequestService.requestUri(
            `${url}${endpoint}?${queryParams}`,
            'get', undefined, undefined, undefined, true
        )
    }
}
