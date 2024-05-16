import { EApps } from 'config'

import { BIND_OUT, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { IRoundsLine } from '../grid'

export class FiscRoundService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public constructor(private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method updateLine
     *********************************************************************************************/
    public async updateLine(line: IRoundsLine, roundSid: number, lineSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'P_ROUND_SID',      type: NUMBER, value: roundSid },
                { name: 'P_LINE_SID',       type: NUMBER, value: lineSid },
                { name: 'P_GRID_SID',       type: NUMBER, value: line.GRID_SID },
                { name: 'P_DESCR',          type: STRING, value: line.DESCR },
                { name: 'P_ESA_CODE',       type: STRING, value: line.ESA_CODE },
                { name: 'P_RATS_ID',        type: STRING, value: line.RATS_ID },
                { name: 'P_IN_AGG',         type: STRING, value: line.IN_AGG ? 'Y' : null},
                { name: 'P_IN_LT',          type: STRING, value: line.IN_LT ? 'Y' : null },
                { name: 'P_IS_MANDATORY',   type: NUMBER, value: line.IS_MANDATORY ? 1 : 0 },
                { name: 'P_WEIGHT',         type: STRING, value: line.WEIGHT },
                { name: 'P_WEIGHT_YEAR',    type: NUMBER, value: line.WEIGHT_YEAR },
                { name: 'P_IN_DD',          type: STRING, value: line.IN_DD ? 'Y' : null},
                { name: 'P_AGG_DESCR',      type: STRING, value: line.AGG_DESCR },
                { name: 'P_HELP_MSG_SID',   type: NUMBER, value: line.HELP_MSG_SID },
                { name: 'o_res',        type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_line_pkg.saveLine`, options)
        return dbResult.o_res
    }
}
