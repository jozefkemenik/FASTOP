import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../authzLib.service'
import { BaseRouter } from '../base-router'

import { LibMenuController } from './menu.controller'
import { LibMenuService } from './menu.service'

export class MenuRouter<S extends LibMenuService, C extends LibMenuController<S>> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(menuService: LibMenuService): Router {
        return new MenuRouter(new LibMenuController(menuService)).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(private readonly controller: C) {
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
            .get('/', this.getMenusHandler.bind(this))
            .get('/countries', this.getCountriesHandler.bind(this))
            .post('/checkAccess', this.checkAccessHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getMenusHandler
     *********************************************************************************************/
    private getMenusHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getMenus({
            userId: this.getUserId(req),
            userGroups: AuthzLibService.getUserGroups(req)
        }).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getCountries(
            // for SU, ADMIN, READ_ONLY return all countries, for others only user's countries
            AuthzLibService.isAdmin(req) || AuthzLibService.isReadOnly(req)
                ? undefined
                : AuthzLibService.getUserCountries(req),
            req.query.inactive !== 'true',
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method checkAccessHandler
     *********************************************************************************************/
    private checkAccessHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.checkAccess(
            req.body.url as string,
            AuthzLibService.getUserGroups(req),
        ).then(res.json.bind(res), next)
    }
}
