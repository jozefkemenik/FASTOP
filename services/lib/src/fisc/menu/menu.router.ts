import { Router } from 'express'

import { MenuRouter as LibMenuRouter } from '../../menu/menu.router'
import { MenuController } from './menu.controller'
import { MenuService } from './menu.service'

export class MenuRouter extends LibMenuRouter<MenuService, MenuController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createFiscRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createFiscRouter(menuService: MenuService): Router {
        return new MenuRouter(new MenuController(menuService)).buildRouter()
    }
}
