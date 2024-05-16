import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzLibService } from '../../../lib/dist'
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
    public static createRouter(appId: EApps): Router {
        return new WorkflowRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(new WorkflowController(appId, new WorkflowService()))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for WorkflowRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/archiveStorage',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.archiveStorageHandler.bind(this))
            .post('/customStorage/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.newCustomStorageHandler.bind(this))
            .post('/openTransparencyReport',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.openTransparencyReportHandler.bind(this))
            .post('/publishTransparencyReport',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.publishTransparencyReportHandler.bind(this))

        return super.configRoutes(router)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archiveStorageHandler
     *********************************************************************************************/
    private archiveStorageHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.archive(
            SharedService.getReqArchiveParams(req.body),
            req.body.countryIds,
            this.getUserId(req),
            req.query.force === 'true',
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method newCustomStorageHandler
     *********************************************************************************************/
    private newCustomStorageHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.newCustomStorage(Number(req.params.roundSid), req.body)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method openTransparencyReportHandler
     *********************************************************************************************/
    private openTransparencyReportHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.openTransparencyReport().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method publishTransparencyReportHandler
     *********************************************************************************************/
    private publishTransparencyReportHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.publishTransparencyReport(SharedService.getReqArchiveParams(req.body))
            .then(res.json.bind(res), next)
    }
}
