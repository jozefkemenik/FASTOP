import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../authzLib.service'
import { BaseRouter } from '../base-router'
import { CnsController } from './cns.controller'
import { EApps } from 'config'
import { ICnsReferenceType } from 'notification'


export class CnsRouter extends BaseRouter {

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new CnsRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: CnsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new CnsController()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .post('/send',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.sendNotificationHandler)
            .get('/status/:referenceId',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getNotificationStatusHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method sendNotificationHandler
     *********************************************************************************************/
    private sendNotificationHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.send(
            req.body,
            this.getUserId(req),
            this.appId,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getNotificationStatusHandler
     *********************************************************************************************/
    private getNotificationStatusHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getStatus(
            req.params.referenceId,
            req.query.referenceType as ICnsReferenceType
        ).then(res.json.bind(res), next)
}
