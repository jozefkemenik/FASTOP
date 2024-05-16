import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, BaseRouter, LoggingService } from '../../../lib/dist'

import { SumDbService } from '../db/sum.db.service'
import { UserController } from './user.controller'
import { UserService } from './user.service'

export class UserRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of UserRouter
     *********************************************************************************************/
    public static createRouter(logs: LoggingService, dbService: SumDbService): Router {
        return new UserRouter(logs, dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: UserController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(logs: LoggingService, dbService: SumDbService) {
        super()
        this.controller = new UserController(new UserService(dbService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/:email/ldap', AuthzLibService.checkAuthorisation('ADMIN'), this.getLdapInfo.bind(this))
            .get('/:ecasId/isProv', AuthzLibService.checkAuthorisation('ADMIN'), this.searchProvisioned.bind(this))
            .put('/provision', AuthzLibService.checkAuthorisation('ADMIN'), this.addUser.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getLdapInfo
     *********************************************************************************************/
    private getLdapInfo(req: Request, res: Response, next: NextFunction) {

        this.controller.getLdapInfo(req.params.email)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method searchProvisioned
     *********************************************************************************************/
    private searchProvisioned(req: Request, res: Response, next: NextFunction) {

        this.controller.searchProvisioned(req.params.ecasId)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method addUser
     *********************************************************************************************/
    private addUser(req: Request, res: Response, next: NextFunction) {
        this.controller.addUser(req.body.user)
            .then(res.json.bind(res), next)
    }
}
