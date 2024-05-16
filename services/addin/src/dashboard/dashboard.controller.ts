import { IDBAddinApp, IDBAddinTreeApp, IDBAuthApp } from './index'
import { DashboardService } from './dashboard.service'
import { IAddinApp } from './shared-interfaces'
import { IUserAuthzs } from 'users'
import { catchAll } from '../../../lib/dist/catch-decorator'

@catchAll(__filename)
export class DashboardController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly dashboardService: DashboardService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDashboardPublicApps
     *********************************************************************************************/
    public async getDashboardPublicApps(): Promise<IAddinApp[]> {
        return this.dashboardService
            .getDashboardActiveApps()
            .then(apps => apps.filter(app => !app.ROLES))
            .then(this.toAddinApp)
    }

    /**********************************************************************************************
     * @method getDashboardTreeActiveApps
     *********************************************************************************************/
    public async getDashboardTreeActiveApps(allAuthz: IUserAuthzs, internal:boolean): Promise<IAddinApp[]> {
        if (!internal && !allAuthz) return []

        const appAuthz: IAppAuth = this.getAuthApps(allAuthz, internal)

        return this.dashboardService
            .getDashboardTreeActiveApps()
            .then(apps => apps.filter(
                app => !app.DASHBOARD_SID || !app.ROLES || this.canAccessApp(app, appAuthz, internal))
            )
            .then(this.toTreeAddinApp)
    }

    /**********************************************************************************************
     * @method getDashboardRestrictedApps
     *********************************************************************************************/
    public async getDashboardRestrictedApps(allAuthz: IUserAuthzs, internal: boolean): Promise<IAddinApp[]> {
        if (!internal && !allAuthz) return []

        const appAuthz: IAppAuth = this.getAuthApps(allAuthz, internal)

        return this.dashboardService
            .getDashboardActiveApps()
            .then(apps => apps.filter(app => this.canAccessApp(app, appAuthz, internal)))
            .then(this.toAddinApp)
    }

     /**********************************************************************************************
     * @method setDashboardTreeApps
     *********************************************************************************************/
     public async setDashboardTreeApps(apps:IAddinApp[]): Promise<number> {
        const [tree_sids,
            dashboard_sids,
            parent_tree_sids,
            titles,
            json_datas] = apps.reduce(([x1,x2,x3,x4,x5],item)=>{
                x1.push(item.id)
                x2.push(item.dashboardId??-1)
                x3.push(item.parentId??-1)
                x4.push(item.title)
                x5.push(item.data)
            return [x1,x2,x3,x4,x5]
        },[[],[],[],[],[]])
            
        return this.dashboardService.setDashboardTreeApps(tree_sids,
            dashboard_sids,
            parent_tree_sids,
            titles,
            json_datas)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////


    /**********************************************************************************************
     * @method canAccessApp
     *********************************************************************************************/
    private canAccessApp(app: IDBAuthApp, appAuthz: IAppAuth, internal: boolean): boolean {
        return app.ROLES &&
        (internal || (
                appAuthz[app.OWNER_APP_ID] &&
                (appAuthz[app.OWNER_APP_ID].includes('SU') ||
                    appAuthz[app.OWNER_APP_ID].some(userGroup => app.ROLES.split(',').includes(userGroup))))
        )
    }

    /**********************************************************************************************
     * @method getAuthApps
     *********************************************************************************************/
    private getAuthApps(allAuthz: IUserAuthzs, internal:boolean): IAppAuth {
        return internal ? {} : Object.keys(allAuthz).reduce((acc, app) => {
            acc[app] = allAuthz[app].map(userAuthz => userAuthz.groupId)
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method toAddinApp
     *********************************************************************************************/
    private toAddinApp(dbApps: IDBAddinApp[]): IAddinApp[] {
        return dbApps.map(dbApp => ({
            title: dbApp.TITLE,
            link: dbApp.LINK,
            dashboardId:dbApp.DASHBOARD_SID
        }))
    }

    /**********************************************************************************************
     * @method toAddinApp
     *********************************************************************************************/
    private toTreeAddinApp(dbApps: IDBAddinTreeApp[]): IAddinApp[] {
        return dbApps.map(dbApp => ({
            title: dbApp.TITLE,
            link: dbApp.LINK,
            id: dbApp.TREE_SID, 
            parentId: dbApp.PARENT_TREE_SID, 
            data:dbApp.JSON_DATA,
            dashboardId:dbApp.DASHBOARD_SID,
   
        }))
    }
}

interface IAppAuth {
    [app: string]: string[]
}
