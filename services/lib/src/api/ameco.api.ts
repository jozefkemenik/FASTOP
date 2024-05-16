import { EApps } from 'config'
import { IAmecoCountryCode } from '../../../ameco/src/report/shared-interfaces'
import { RequestService } from '../request.service'


export class AmecoApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoDownloadCountryCodes
     *********************************************************************************************/
    public static getAmecoDownloadCountryCodes(): Promise<IAmecoCountryCode[]> {
        return RequestService.request(EApps.AD, `/config/countryCodes`)
    }
}
