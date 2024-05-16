import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter, LoggingService } from '../../../lib/dist'
import { UserController } from './user.controller'
import { UserService } from './user.service'

export class UserRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of UserRouter
     *********************************************************************************************/
    public static createRouter(logs: LoggingService): Router {
        return new UserRouter(logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: UserController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(logs: LoggingService) {
        super()
        this.controller = new UserController(new UserService(), logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/apps', this.getUserAppsHandler.bind(this))
            .get('/:userId/authzs', this.getUserAuthzHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getUserAppsHandler
     *********************************************************************************************/
    private getUserAppsHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getUserApps(
            !this.isOnIntragate(req),
            this.getAllUserAuthorizations(req) || {},
        ).then(res.json.bind(res), next)
    }
    /**********************************************************************************************
     * @method getUserAuthzHandler
     *********************************************************************************************/
    private getUserAuthzHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getUserAuthzs(req.params.userId, String(req.query.unit))
            .then(res.json.bind(res), next)
    }
}
