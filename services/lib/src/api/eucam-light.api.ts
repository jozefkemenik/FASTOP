import { EApps } from 'config'

import { IEucamLightVersion, IOutputGapUpload } from '../fisc/output-gaps'
import { RequestService } from '../request.service'

export class EucamLightApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateOutputGap
     *********************************************************************************************/
    public static calculateOutputGap(countryId: string, msGridLines: string[]): Promise<IOutputGapUpload> {
        return RequestService.request(EApps.EUCAM, `/calc/outputGap/${countryId}`, 'put', msGridLines)
    }

    /**********************************************************************************************
     * @method getEucamLightVersion
     *********************************************************************************************/
    public static getEucamLightVersion(): Promise<IEucamLightVersion> {
        return RequestService.request(EApps.EUCAM, `/config/eucamLightVersion`)
    }

    /**********************************************************************************************
     * @method getEucamLightVersionFormatted
     *********************************************************************************************/
    public static getEucamLightVersionFormatted(): Promise<[string, string]> {
        return this.getEucamLightVersion().then(this.formatEucamLightVersionInfo)
    }

    /**********************************************************************************************
     * @method getTKPCountries
     *********************************************************************************************/
    public static getTKPCountries(): Promise<string[]> {
        return RequestService.request(EApps.EUCAM, `/config/TKPCountries`)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Static Methods /////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatEucamLightVersionInfo
     *********************************************************************************************/
    private static formatEucamLightVersionInfo(eucamVersion: IEucamLightVersion): [string, string] {
        return [
            'EU-CAM light',
            eucamVersion
                ? `${eucamVersion.version} | ${eucamVersion.vintage} | Change year: ${eucamVersion.changeYear}`
                : ''
        ]
    }
}
