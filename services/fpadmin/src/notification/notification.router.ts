import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, BaseRouter } from '../../../lib/dist'
import { EApps } from 'config'
import { NotificationController } from './notification.controller'
import { NotificationService } from './notification.service'

export class NotificationRouter extends BaseRouter{

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new NotificationRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: NotificationController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new NotificationController(new NotificationService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/groups',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getNotificationGroupsHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNotificationGroupsHandler
     *********************************************************************************************/
    private getNotificationGroupsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getNotificationGroups().then(res.json.bind(res), next)
}
