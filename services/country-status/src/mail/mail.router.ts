import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { MailRouter as LibMailRouter } from '../../../lib/dist/mail/mail.router'

import { MailController } from './mail.controller'
import { MailService } from './mail.service'

export class MailRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new MailRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: MailController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new MailController(new MailService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/actions', this.getActionsHandler.bind(this))
            .get('/notification', this.getMailRecipientsHandler.bind(this))
            .post('/notification/:email', this.addMailRecipientHandler.bind(this))
            .delete('/notification/:email', this.deleteMailRecipientHandler.bind(this))
            .put('/notification/:email', this.updateMailRecipientHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActionsHandler
     *********************************************************************************************/
    private getActionsHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getActions().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getMailRecipientsHandler
     *********************************************************************************************/
    private getMailRecipientsHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getMailRecipients(LibMailRouter.buildMailNotification(req.query))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method addMailRecipientHandler
     *********************************************************************************************/
    private addMailRecipientHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.addMailRecipient(LibMailRouter.buildMailNotification(req.query), req.params.email)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method deleteMailRecipientHandler
     *********************************************************************************************/
    private deleteMailRecipientHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.deleteMailRecipient(LibMailRouter.buildMailNotification(req.query), req.params.email)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method updateMailRecipientHandler
     *********************************************************************************************/
    private updateMailRecipientHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.updateMailRecipient(
            LibMailRouter.buildMailNotification(req.query), req.params.email, req.body
        ).then(res.json.bind(res), next)
    }
}
