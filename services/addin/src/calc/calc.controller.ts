import { FpCalcApi } from '../../../lib/dist/api/fp-calc.api'
import { IAddinCalcData } from '../../../lib/dist/addin/shared-interfaces'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class CalcController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateExpression
     *********************************************************************************************/
    public async calculateExpression(expression: string): Promise<IAddinCalcData> {
        return FpCalcApi.calculateExpression(expression)
    }
}
