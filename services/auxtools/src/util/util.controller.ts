import { BloombergApi } from '../../../lib/dist/api/bloomberg.api'
import { EApps } from 'config'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class UtilController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
    ) {}

    /**********************************************************************************************
     * @method convertBloombergData
     *********************************************************************************************/
    public convertBloombergData(data: string): Promise<string> {
        return BloombergApi.convertBloombergData(data)
    }
}
