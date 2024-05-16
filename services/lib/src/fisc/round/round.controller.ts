import { IError } from '../../error.service'
import { IRoundsLine } from '../grid'

import { FiscRoundService } from './round.service'

export class FiscRoundController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public constructor(private roundService: FiscRoundService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method updateLine
     *********************************************************************************************/
    public updateLine(roundSid: number, lineSid: number, line: IRoundsLine): Promise<number> {
        return this.roundService.updateLine(line, roundSid, lineSid).catch(
            (err: IError) => {
                err.method = `FiscRoundController.updateLine`
                throw err
            }
        )
    }
}
