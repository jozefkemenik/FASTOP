import { IError } from '../../error.service'
import { ILineIndicator } from '../shared'

import { LibLineIndicatorService } from './line-indicator.service'

export class LibLineIndicatorController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private lineIndicatorService: LibLineIndicatorService) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getLineIndicators
     *********************************************************************************************/
     public async getLineIndicators(lineSid: number): Promise<ILineIndicator[]> {
        return this.lineIndicatorService
            .getLineIndicators(lineSid)
            .catch((err: IError) => {
                err.method = 'LineIndicatorController.getLineIndicators'
                throw err
            })
    }

    /**********************************************************************************************
     * @method updateIndicator
     *********************************************************************************************/
    public async updateLineIndicator(lineSid: number, indicator: ILineIndicator): Promise<number> {
        return this.lineIndicatorService
            .saveLineIndicator(
                lineSid,
                indicator.DATA_TYPE_SID,
                indicator.INDICATOR_SID,
            )
            .catch((err: IError) => {
                err.method = 'LineIndicatorController.saveLineIndicator'
                throw err
            })
    }

    /**********************************************************************************************
     * @method deleteLineIndicator
     *********************************************************************************************/
    public async deleteLineIndicator(lineSid: number, dataTypeSid: number): Promise<number> {
        return this.lineIndicatorService.deleteLineIndicator(lineSid, dataTypeSid)
        .catch((err: IError) => {
            err.method = 'LineIndicatorController.deleteLineIndicator'
            throw err
        })
    }
}
