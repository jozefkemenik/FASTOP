import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { LibWorkflowRouter } from '../../../lib/dist/workflow/workflow.router'
import { SharedService } from '../shared/shared.service'
import { WorkflowController } from './workflow.controller'
import { WorkflowService } from './workflow.service'

export class WorkflowRouter extends LibWorkflowRouter<WorkflowService, WorkflowController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of WorkflowRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new WorkflowRouter(new WorkflowController(appId, sharedService, new WorkflowService())).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configInternalRoutes internal routes configuration for WorkflowRouter
     *********************************************************************************************/
    protected configInternalRoutes(router: Router): Router {
        return router
            .post('/rounds', this.newRoundHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method newRoundHandler
     *********************************************************************************************/
    private newRoundHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.newRound(
            req.body.oldRoundSid,
            req.body.newRoundSid,
        ).then(res.json.bind(res), next)
    }
}
