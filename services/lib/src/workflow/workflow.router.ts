import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '..'
import { BaseRouter } from '../base-router'

import { LibWorkflowController } from './workflow.controller'
import { LibWorkflowService } from './workflow.service'

export class LibWorkflowRouter<S extends LibWorkflowService, C extends LibWorkflowController<S>> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of LibWorkflowRouter
     *********************************************************************************************/
    public static createLibRouter(appId: EApps): Router {
        return new LibWorkflowRouter(
            new LibWorkflowController<LibWorkflowService>(new LibWorkflowService(appId))
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(protected readonly controller: C) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for WorkflowRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .post('/open',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.openAppRequestHandler)
            .post('/close',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.closeAppRequestHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method openAppRequestHandler
     *********************************************************************************************/
    private openAppRequestHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.openApplication().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method closeAppRequestHandler
     *********************************************************************************************/
    private closeAppRequestHandler = (req: Request, res: Response, next: NextFunction) => {
        this.controller.closeApplication().then(res.json.bind(res), next)
    }
}
