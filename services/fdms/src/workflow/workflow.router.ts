import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzLibService } from '../../../lib/dist'
import { LibWorkflowRouter } from '../../../lib/dist/workflow/workflow.router'

import { WorkflowController } from './workflow.controller'
import { WorkflowService } from './workflow.service'

export class WorkflowRouter extends LibWorkflowRouter<WorkflowService, WorkflowController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of WorkflowRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new WorkflowRouter(new WorkflowController(appId, new WorkflowService(appId))).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(controller: WorkflowController) {
        super(controller)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for WorkflowRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/advanceStorage',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.advanceStorageRequestHandler.bind(this))

        return super.configRoutes(router)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method advanceStorageRequestHandler
     *********************************************************************************************/
    private advanceStorageRequestHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.advanceStorage(req.body).then(res.json.bind(res), next)
    }
}
