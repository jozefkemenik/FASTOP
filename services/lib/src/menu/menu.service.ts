import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../db'
import { CacheMap } from '../cache-map'
import { DataAccessApi } from '../api/data-access.api'

import { IDBCountry, IDBMenu } from '.'

export class LibMenuService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _countries: [IDBCountry[], IDBCountry[]] = [undefined, undefined]
    private _appMenus = new CacheMap<string, IDBMenu[]>()
    private _menuItems = new CacheMap<string, IDBMenu[]>()
    private _appLinkAccess = new CacheMap<string, boolean>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly _app: string) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get app() {
        return this._app
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAppMenus
     *********************************************************************************************/
    public async getAppMenus(userGroups: string[]): Promise<IDBMenu[]> {
        const key = `${userGroups}`
        if (!this._appMenus.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_application_name', type: STRING, value: this.app },
                    { name: 'p_group_ids', type: STRING, value: userGroups },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('mn_accessors.getAppMenus', options)
            this._appMenus.set(key, dbResult.o_cur)
        }
        // return copies of menus since the cached ones may already contain the ITEMS inside
        // the copies will contain them too, but will get overwritten later
        // we don't want to override the original ones
        return this._appMenus.get(key).map(menu => Object.assign({}, menu))
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(activeOnly: boolean): Promise<IDBCountry[]> {
        if (!this._countries[Number(activeOnly)]) {
            const options: ISPOptions = {
                params: [
                    { name: 'cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: this.app },
                    { name: 'p_active_only', type: NUMBER, value: Number(activeOnly) },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getCountries', options)
            this._countries[Number(activeOnly)] = dbResult.cur
        }
        return this._countries[Number(activeOnly)]
    }

    /**********************************************************************************************
     * @method getMenuItems
     *********************************************************************************************/
    public async getMenuItems(menuSid: number, userGroups: string[]): Promise<IDBMenu[]> {
        const key = `${menuSid}${userGroups}`
        if (!this._menuItems.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_menu_sid', type: NUMBER, value: menuSid },
                    { name: 'p_group_ids', type: STRING, value: userGroups },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('mn_accessors.getMenuItems', options)
            this._menuItems.set(key, dbResult.o_cur)
        }
        return this._menuItems.get(key)
    }

    /**********************************************************************************************
     * @method canAccessAppLink
     *********************************************************************************************/
    public async canAccessAppLink(link: string, userGroups: string[]): Promise<boolean> {

        const key = `${link}_${userGroups.sort().join(',')}`
        if (!this._appLinkAccess.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_link', type: STRING, value: link },
                    { name: 'p_app_id', type: STRING, value: this.app },
                    { name: 'p_group_ids', type: STRING, value: userGroups },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('mn_accessors.canAccessAppLink', options)
            this._appLinkAccess.set(key, dbResult.o_res > 0)
        }

        return this._appLinkAccess.get(key)
    }
}
