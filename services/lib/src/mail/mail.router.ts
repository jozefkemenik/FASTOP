import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '..'
import { BaseRouter } from '../base-router'
import { IMailNotification } from '../../../country-status/src/mail/shared-interfaces'

import { MailController } from './mail.controller'

export class MailRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new MailRouter(new MailController(appId)).buildRouter()
    }

    /**********************************************************************************************
     * @method buildMailNotification
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static buildMailNotification(query: any): IMailNotification {
        return {
            appId: query.appId?.toUpperCase(),
            countryId: query.countryId,
            actionSid: Number(query.actionSid),
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(private readonly mailController: MailController) {
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
            .get('/notification',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getMailRecipientsHandler.bind(this))
            .post('/notification/:email',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.addMailRecipientHandler.bind(this))
            .delete('/notification/:email',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.deleteMailRecipientHandler.bind(this))
            .put('/notification/:email',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.updateMailRecipientHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getMailRecipientsHandler
     *********************************************************************************************/
    private getMailRecipientsHandler(req: Request, res: Response, next: NextFunction) {
        this.mailController.getMailRecipients(MailRouter.buildMailNotification(req.query))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method addMailRecipientHandler
     *********************************************************************************************/
    private addMailRecipientHandler(req: Request, res: Response, next: NextFunction) {
        this.mailController.addMailRecipient(MailRouter.buildMailNotification(req.query), req.params.email)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method deleteMailRecipientHandler
     *********************************************************************************************/
    private deleteMailRecipientHandler(req: Request, res: Response, next: NextFunction) {
        this.mailController.deleteMailRecipient(MailRouter.buildMailNotification(req.query), req.params.email)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method updateMailRecipientHandler
     *********************************************************************************************/
    private updateMailRecipientHandler(req: Request, res: Response, next: NextFunction) {
        this.mailController.updateMailRecipient(
            MailRouter.buildMailNotification(req.query), req.params.email, req.body
        ).then(res.json.bind(res), next)
    }
}
