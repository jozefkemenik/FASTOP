import { EApps } from 'config'

import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { ICurrentRoundInfo } from '../../../dashboard/src/config/shared-interfaces'
import { LibWorkflowController } from '../../../lib/dist/workflow/workflow.controller'
import { catchAll } from '../../../lib/dist/catch-decorator'

import { WorkflowService } from './workflow.service'

@catchAll(__filename)
export class WorkflowController extends LibWorkflowController<WorkflowService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, service: WorkflowService) {
        super(service)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method advanceStorage
     *********************************************************************************************/
    public async advanceStorage(info: ICurrentRoundInfo): Promise<number> {
        const currentRoundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        if (info.roundSid !== currentRoundInfo.roundSid || info.storageSid !== currentRoundInfo.storageSid) {
            return EErrors.ROUND_KEYS
        }

        // if (currentRoundInfo.isMainStorage &&
        //     await RequestService.request(
        //         EApps.DFM, `/workflow/archiveStorage?force=true`, 'post', currentRoundInfo
        //     ) < 0
        // ) {
        //     return EErrors.ARCHIVE_DFM
        // }

        return this.service.advanceStorage(info.roundSid, info.storageSid)
    }
}
