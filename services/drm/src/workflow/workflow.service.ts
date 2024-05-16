import { EApps } from 'config'

import { BIND_OUT, ISPOptions, NUMBER } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { LibWorkflowService } from '../../../lib/dist/workflow/workflow.service'

export class WorkflowService extends LibWorkflowService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super(EApps.DFM)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archiveMeasures
     *********************************************************************************************/
    public async archiveMeasures(roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('drm_app_status.archiveMeasures', options)
        return dbResult.o_res
    }
}
