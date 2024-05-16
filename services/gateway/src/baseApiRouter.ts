import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from './baseRouter'
import { IUser } from './interfaces'

export abstract class BaseApiRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public static readonly LOGOUT_ROUTE = '/_myself_/logout'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method config
     *********************************************************************************************/
    protected config(): Router {
        const router = super.config()
        this.configAppServices(router)

        return router
    }

    /**********************************************************************************************
     * @method checkAuth checks authentication
     *********************************************************************************************/
    protected checkAuth(req: Request, res: Response, next: NextFunction): void {
        const user: IUser = req.session.user
        if (!req.get('internal') && user?.authenticated || req.url === BaseApiRouter.LOGOUT_ROUTE) {
            next()
        } else {
            // Not authenticated
            res.status(401).send('Not authenticated')
        }
    }

    /**********************************************************************************************
     * @method configAppServices
     *********************************************************************************************/
    protected abstract configAppServices(router: Router)

}
