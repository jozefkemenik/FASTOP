import { EApps } from 'config'
import { IAddinCalcData } from '../addin/calc'
import { RequestService } from '../request.service'


export class FpCalcApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateExpression
     *********************************************************************************************/
    public static async calculateExpression(expression: string): Promise<IAddinCalcData> {
        return RequestService.request(
            EApps.FPCALC, `/calc/engine`, 'post', { expression }
        ).then(raw => JSON.parse(raw))
    }

}
