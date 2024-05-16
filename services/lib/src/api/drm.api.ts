import { EApps } from 'config'

import { ICtyActionResult } from '../dashboard'
import { RequestService } from '../request.service'

export class DrmApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method newRound
     *********************************************************************************************/
    public static newRound(oldRoundSid: number, newRoundSid: number, user: string): Promise<ICtyActionResult> {
        return RequestService.request(
            EApps.DRM,
            `/workflow/rounds`,
            'post',
            { oldRoundSid, newRoundSid },
            { authLogin: user },
        )
    }
}
