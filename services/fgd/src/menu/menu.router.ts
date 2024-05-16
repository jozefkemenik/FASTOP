import { Router } from 'express'

import { MenuRouter as LibMenuRouter } from '../../../lib/dist/menu/menu.router'

import { EApps } from 'config'
import { MenuController } from './menu.controller'
import { MenuService } from './menu.service'


export class MenuRouter extends LibMenuRouter<MenuService, MenuController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createFgdRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createFgdRouter(appId: EApps, menuService: MenuService): Router {
        return new MenuRouter(new MenuController(appId, menuService)).buildRouter()
    }
}
