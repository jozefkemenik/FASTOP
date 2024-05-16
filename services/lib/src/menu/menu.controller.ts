import { EMenuRepoTypes, IBuildMenuOptions, ICountry, IMenu } from '.'
import { CacheMap } from '../cache-map'
import { IError } from '../error.service'
import { LibMenuService } from './menu.service'
import { catchAll } from '../catch-decorator'

@catchAll(__filename)
export class LibMenuController<S extends LibMenuService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    protected _menus = new CacheMap<string, IMenu[]>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(protected readonly menuService: S) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries if userCountries are defined return only user's countries otherwise all
     *********************************************************************************************/
    public async getCountries(userCountries: string[], activeOnly: boolean): Promise<ICountry[]> {
        const countries = await this.menuService.getCountries(activeOnly).catch((err: IError) => {
            err.method = 'MenuController.getCountries'
            throw err
        })

        return (userCountries && countries.filter(this.filterCountry(userCountries))) || countries
    }

    /**********************************************************************************************
     * @method getMenus
     *********************************************************************************************/
    public async getMenus(options: IBuildMenuOptions): Promise<IMenu[]> {
        const key = this.getMenuCacheKey(options)

        if (!this._menus.has(key)) {
            const menus = await this.menuService.getAppMenus(options.userGroups).catch((err: IError) => {
                err.method = 'MenuController.getMenus'
                throw err
            })
            this._menus.set(key, await this.getMenuItems(menus, options))
        }

        return this._menus.get(key)
    }

    /**********************************************************************************************
     * @method checkAccess
     *********************************************************************************************/
    public async checkAccess(url: string, userGroups: string[]): Promise<boolean> {
        return this.menuService.canAccessAppLink(url, userGroups)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fillSubmenu
     *********************************************************************************************/
    protected async fillSubmenu(menu: IMenu, options: IBuildMenuOptions): Promise<IMenu[]> {
        const items = await this.menuService.getMenuItems(menu.MENU_REPO_SID, options.userGroups)
        return await this.getMenuItems(items, options)
    }

    /**********************************************************************************************
     * @method filterCountry
     *********************************************************************************************/
     protected filterCountry(userCountries: string[]) {
         return (country: ICountry) => userCountries.includes(country.COUNTRY_ID)
    }

    /**********************************************************************************************
     * @method getMenuCacheKey
     *********************************************************************************************/
    protected getMenuCacheKey(options: IBuildMenuOptions): string {
        return options.userGroups.sort().join()
    }

    /**********************************************************************************************
     * @method getMenuItems
     *********************************************************************************************/
    protected async getMenuItems(menus: IMenu[], options: IBuildMenuOptions): Promise<IMenu[]> {
        const submenus = menus.filter(
            menu => menu.MENU_REPO_TYPE_ID !== EMenuRepoTypes.PAGE &&
                    menu.MENU_REPO_TYPE_ID !== EMenuRepoTypes.URL
        )

        for (const menu of submenus) {
            menu.ITEMS = await this.fillSubmenu(menu, options)
            this.updateOptions(menu, options)
        }

        return menus.map(menu => {
            menu.TITLE = menu.TITLE.replace('{appName}', this.menuService.app)
            return menu
        })
    }

    /**********************************************************************************************
     * @method updateOptions
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected updateOptions(menu: IMenu, options: IBuildMenuOptions): void {
        // stub for apps that don't need to update options
    }

}
