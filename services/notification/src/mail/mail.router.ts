import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { LoggingService } from '../../../lib/dist'
import { MailController } from './mail.controller'
import { MailService } from './mail.service'
import { SharedService } from '../shared/shared.service'


export class MailRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(
        appId: EApps, mailService: MailService, sharedService: SharedService, logs: LoggingService
    ): Router {
        return new MailRouter(appId, mailService, sharedService, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: MailController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, mail: MailService, sharedService: SharedService, logs: LoggingService) {
        super(appId)
        this.controller = new MailController(mail, sharedService, logs)
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
                this.sendMailHandler)
            .post('/send/:templateId',
                this.sendMailWithTemplateHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method sendMailHandler
     *********************************************************************************************/
    private sendMailHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.sendMail(
            req.body,
            req.query.user as string,
            req.query.appId as string,
            req.query.log !== undefined,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method sendMailWithTemplateHandler
     *********************************************************************************************/
    private sendMailWithTemplateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.sendMailWithTemplate(
            req.params.templateId as string,
            req.body,
            req.query.user as string,
            req.query.appId as string,
            req.query.log !== undefined,
        ).then(res.json.bind(res), next)
}
