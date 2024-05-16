import { SharedCalc } from './shared-calc'

import { IAmecoValidation, IDBCalculatedIndicator, IIndicatorValidation } from '.'
import { SharedCalcService } from './shared-calc.service'

export abstract class SharedCalcController<S extends SharedCalcService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(protected calcService: S) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method validateAmecoIndicators
     *********************************************************************************************/
    protected async validateAmecoIndicators(calc: SharedCalc<S>): Promise<IAmecoValidation> {
        const amecoDbIndicators: IDBCalculatedIndicator[] = await calc.getAmecoIndicators(
            await this.getRequiredAmecoIndicators()
        )

        const indicators: IIndicatorValidation[] = amecoDbIndicators.map(ameco => ({
            indicatorId: ameco.INDICATOR_ID,
            indicatorDesc: ameco.DESCR,
            hasError: !this.vectorHasValue(ameco.VECTOR)
        }))

        return {
            indicators,
            lastUpdated: await calc.getAmecoLastChangeDate(),
            hasErrors: indicators.findIndex(indicator => indicator.hasError) > -1
        }
    }

    /**********************************************************************************************
     * @method getRequiredAmecoIndicators
     *********************************************************************************************/
    protected abstract getRequiredAmecoIndicators(): Promise<string[]>

    /**********************************************************************************************
     * @method vectorHasValue
     *********************************************************************************************/
    protected vectorHasValue(vector: string): boolean {
        return vector?.toLowerCase().replace(/(null|undefined|n\.a\.|,)/g, '').trim().length > 0
    }
}
