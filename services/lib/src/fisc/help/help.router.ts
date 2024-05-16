import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

import { LibHelpController } from './help.controller'
import { LibHelpService } from './help.service'

export class LibHelpRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of LibHelpRouter
     *********************************************************************************************/
    public static createRouter(): Router {
        return new LibHelpRouter(
            new LibHelpController(
                new LibHelpService()
            )
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(private readonly controller: LibHelpController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .put('/line/:helpMsgSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.updateLineHelpMsgHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method updateHelpMsgHandler
     *********************************************************************************************/
    private updateLineHelpMsgHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.updateHelpMessage(
            Number(req.params.helpMsgSid), req.body, 'LINE'
        ).then(res.json.bind(res), next)
    }
}
