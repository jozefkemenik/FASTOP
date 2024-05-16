import { EApps } from 'config'

import { RequestService } from '../request.service'

export class BloombergApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertBloombergData
     *********************************************************************************************/
     public static convertBloombergData(data: string): Promise<string> {
        return RequestService.request(EApps.AD, `/util/bloomberg`, 'post', { content: data })
    }
}
