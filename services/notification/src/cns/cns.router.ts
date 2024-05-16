import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { CnsController } from './cns.controller'
import { CnsService } from './cns.service'
import { EApps } from 'config'
import { ICnsReferenceType } from 'notification'
import { LoggingService } from '../../../lib/dist'
import { SharedService } from '../shared/shared.service'


export class CnsRouter extends BaseRouter {

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService, logs: LoggingService): Router {
        return new CnsRouter(appId, sharedService, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: CnsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService, logs: LoggingService) {
        super(appId)
        this.controller = new CnsController(new CnsService(logs), sharedService, logs)
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
                this.sendNotificationHandler)
            .post('/send/:templateId',
                this.sendNotificationWithTemplateHandler)
            .get('/status/:referenceId',
                this.getNotificationStatusHandler)
            .get('/clientSystem/details',
                this.getClientSystemDetailsHandler)
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
            req.query.user as string,
            req.query.appId as string,
            req.query.log !== undefined,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getNotificationStatusHandler
     *********************************************************************************************/
    private getNotificationStatusHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getStatus(
            req.params.referenceId,
            req.query.referenceType as ICnsReferenceType
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getClientSystemDetailsHandler
     *********************************************************************************************/
    private getClientSystemDetailsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getClientSystemDetails().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method sendNotificationWithTemplateHandler
     *********************************************************************************************/
    private sendNotificationWithTemplateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.sendNotificationWithTemplate(
            req.params.templateId as string,
            req.body,
            req.query.user as string,
            req.query.appId as string,
            req.query.log !== undefined,
        ).then(res.json.bind(res), next)

}
