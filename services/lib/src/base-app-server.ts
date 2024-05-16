import { BaseServer } from './base-server'
import { LibMenuService } from './menu/menu.service'
import { MenuRouter } from './menu/menu.router'


/**
 * Base application backend server
 * By default implements the menu route.
 */
export abstract class BaseAppServer extends BaseServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/menus', MenuRouter.createRouter(new LibMenuService(this._appId)))
    }
}
