import { EApps } from 'config'

import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { LibWorkflowController } from '../../../lib/dist/workflow/workflow.controller'

import { SharedService } from '../shared/shared.service'
import { WorkflowService } from './workflow.service'

export class WorkflowController extends LibWorkflowController<WorkflowService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly sharedService: SharedService,
        service: WorkflowService,
    ) {
        super(service)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method newRound
     *********************************************************************************************/
    public async newRound(oldRoundSid: number, newRoundSid: number): Promise<number> {
        // ignore the action if DRM does not participate in the new round
        if (!(await this.sharedService.isApplicationInRound(this.appId, newRoundSid))) return EErrors.IGNORE

        // get the latest DRM round
        const roundSid = await this.sharedService.getLatestRound(oldRoundSid)

        return this.service.archiveMeasures(roundSid)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
