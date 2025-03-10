import { IFpapiParams } from '../shared-interfaces'
import { dateToPeriod } from '../../../../shared-lib/dist/date-utils'

export abstract class BaseFormatter<S, T> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method format
     *********************************************************************************************/
    public abstract format(data: S, params: IFpapiParams): T

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getPeriod format date to frequency specific string period
     *********************************************************************************************/
    protected getPeriod(date: Date, freq: string): string {
       return dateToPeriod(date, freq)
    }

    /**********************************************************************************************
     * @method hasValue
     *********************************************************************************************/
    protected hasValue(data: unknown): boolean {
        return data !== undefined && data !== null && `${data}`.trim() !== ''
    }

    /**********************************************************************************************
     * @method hasNumericValue
     *********************************************************************************************/
    protected hasNumericValue(data: unknown): boolean {
        return this.hasValue(data) && !isNaN(Number(data))
    }

    /**********************************************************************************************
     * @method formatObservationValue
     *********************************************************************************************/
    protected formatObservationValue(data: unknown): string {
        return this.hasNumericValue(data) ? `${data}` : ''
    }

    /**********************************************************************************************
     * @method formatTextValue
     *********************************************************************************************/
    protected formatTextValue(data: unknown): string {
        return this.hasValue(data) ? `${data}` : ''
    }
}
