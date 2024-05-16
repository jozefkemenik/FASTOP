import {
    ECalcMethod,
    IBaseEffectCalcParams,
    IHicpAggCalcExtendedResult,
    IHicpBaseCalcParams,
    IHicpCalcParams,
    IHicpCalcResult,
} from '../../../auxtools/src/hicp/shared-interfaces'

import { EApps } from 'config'

import { RequestService } from '../request.service'

export class HicpApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateHicp
     *********************************************************************************************/
    public static calculateHicp(params: IHicpCalcParams): Promise<IHicpCalcResult> {
        return RequestService.request(EApps.HICP, `/calc/hicp`, 'post', params)
    }

    /**********************************************************************************************
     * @method calculateBaseStats
     *********************************************************************************************/
    public static calculateBaseStats(params: IHicpCalcParams): Promise<IHicpCalcResult> {
        return RequestService.request(EApps.HICP, `/calc/base_stats`, 'post', params)
    }

    /**********************************************************************************************
     * @method calculateTramoSeats
     *********************************************************************************************/
    public static calculateTramoSeats(params: IHicpCalcParams): Promise<IHicpAggCalcExtendedResult> {
        const url = params.seats == ECalcMethod.X13 ? '/calc/x13_seats' : '/calc/tramo_seats'

        return RequestService.request(EApps.HICP, url, 'post', params)
    }

    /**********************************************************************************************
     * @method calculateBaseEffect
     *********************************************************************************************/
    public static calculateBaseEffect(params: IBaseEffectCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return RequestService.request(EApps.HICP, `/calc/base_effect`, 'post', params)
    }

    /**********************************************************************************************
     * @method calculateContributions
     *********************************************************************************************/
    public static calculateContributions(params: IHicpBaseCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return RequestService.request(EApps.HICP, `/calc/contributions`, 'post', params)
    }

    /**********************************************************************************************
     * @method calculateAnomalies
     *********************************************************************************************/
    public static calculateAnomalies(params: IHicpBaseCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return RequestService.request(EApps.HICP, `/calc/anomalies`, 'post', params)
    }
}
