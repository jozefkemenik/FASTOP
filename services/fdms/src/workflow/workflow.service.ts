import { BIND_IN, BIND_OUT, ISPOptions, NUMBER } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { LibWorkflowService } from '../../../lib/dist/workflow/workflow.service'

export class WorkflowService extends LibWorkflowService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method closeApplication
     * @overrides
     *********************************************************************************************/
    public async closeApplication(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_app_status.setApplicationClosed', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method advanceStorage
     *********************************************************************************************/
    public async advanceStorage(roundSid: number, storageSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, dir: BIND_IN, value: storageSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_round.moveToNextStorage', options)
        return dbResult.o_res
    }
}
