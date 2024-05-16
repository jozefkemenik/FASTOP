import { EMenuRepoTypes, IBuildMenuOptions, IMenu } from '../../menu'
import { GridVersionType } from '../../../../shared-lib/dist/prelib/fisc-grids'
import { LibMenuController } from '../../menu/menu.controller'

import { IDBGrid } from '../shared'
import { MenuService } from './menu.service'

export class MenuController extends LibMenuController<MenuService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fillSubmenu
     * @overrides
     *********************************************************************************************/
    protected async fillSubmenu(menu: IMenu, options: IBuildMenuOptions): Promise<IMenu[]> {
        const items = await this.menuService.getMenuItems(menu.MENU_REPO_SID, options.userGroups)
        let menuItems = await this.getMenuItems(items, options)

        if (menu.MENU_REPO_TYPE_ID === EMenuRepoTypes.GRID) {

            // Add a separator if there are static menu items before the grids
            if (menuItems.length) {
                menuItems.push(null)
            }

            menuItems = menuItems.concat(
                this.gridsToMenu(await this.menuService.getGrids())
            )
        }

        return menuItems
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method gridsToMenu
     *********************************************************************************************/
    private gridsToMenu(grids: IDBGrid[]): IMenu[] {
        return grids.map(g => ({
            LINK: `grids/${g.ROUTE}/${g.GRID_ID}/${GridVersionType.NUMERIC}`,
            MENU_REPO_TYPE_ID: EMenuRepoTypes.PAGE,
            TITLE: g.DESCR,
            width: 700,
        } as IMenu))
    }
}
