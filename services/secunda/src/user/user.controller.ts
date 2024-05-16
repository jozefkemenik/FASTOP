import { IDBUserAppGroup, IToken, IUserApp, IUserAppGroup, IUserAuthz, IUserAuthzs } from '.'
import { EApps } from 'config'
import { LoggingService } from '../../../lib//dist'
import { UserService } from './user.service'
import { config } from '../../../config/config'

export class UserController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private userService: UserService, private log: LoggingService) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getUserApps get user authorised applications and format response in an object
     *********************************************************************************************/
    public getUserApps(external: boolean, allAuthz: IUserAuthzs) {
        // Get all the applications defined in FASTOP
        return this.userService.getFastopApps(external).then(
            apps => this.formatApps(apps, allAuthz)
           ,err => {
                err.method = 'UserController.getUserApps'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getUserAuthzs get user authorised applications
     *********************************************************************************************/
    public async getUserAuthzs(userId: string, unit: string): Promise<IUserAuthzs> {
        if (config.secunda.useUM) return this.getUserAuthzsUM(userId, unit)

        return this.getUserAuthzsAPIGW(userId).catch(
            err => {
                err.method = 'getUserAuthzsAPIGW'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatApps format user authorised applications in an object
     *********************************************************************************************/
    private async formatApps(dbResult: IDBUserAppGroup[], allAuthz: IUserAuthzs): Promise<IUserAppGroup[]> {

        const appGroups: {[groupName: string]: IAppGroup} = dbResult.reduce( (acc, appGroup) => {

            const group: IAppGroup = acc[appGroup.APP_GROUP] || {
                name: appGroup.APP_GROUP,
                order: appGroup.GROUP_ORDER,
                subgroups: {}
            }
            const subGroup: IAppSubgroup = group.subgroups[appGroup.SUBGROUP] || {
                name: appGroup.SUBGROUP,
                order: appGroup.SUBGROUP_ORDER,
                apps: [],
            }
            if (this.canAccessAppGroup(appGroup, allAuthz[appGroup.APP_NAME])) {
                subGroup.apps.push({
                    id: appGroup.APP_NAME,
                    descr: appGroup.APP_DESCR,
                    link: appGroup.APP_LINK,
                    routeDescr: appGroup.ROUTE_DESCR,
                    route: appGroup.ROUTE,
                })
            }

            group.subgroups[appGroup.SUBGROUP] = subGroup
            acc[appGroup.APP_GROUP] = group

            return acc
        }, {})

        return Object.keys(appGroups)
                     .map(groupName => appGroups[groupName])
                     .sort((a, b) => a.order - b.order)
                     .reduce((acc, group) => (
                         acc.push({
                             name: group.name,
                             subgroups: Object.keys(group.subgroups)
                                              .map(subgroupName => this.prepareSubgroup(group.subgroups[subgroupName]))
                                              .filter(subgroup => subgroup.apps.length)
                                              .sort((a, b) => a.order - b.order)
                         }), acc
                        ), [])
    }

    /**********************************************************************************************
     * @method canAccessAppGroup
     *********************************************************************************************/
    private canAccessAppGroup(appGroup: IDBUserAppGroup, authzs: IUserAuthz[]): boolean {
        return appGroup.PUBLIC_SUBGROUP === 1 ||
               authzs && (
                   !appGroup.ROUTE || this.canAccessRoute(authzs.map(a => a.groupId), appGroup.ROUTE_ROLES)
            )
    }

    /**********************************************************************************************
     * @method canAccessRoute
     *********************************************************************************************/
    private canAccessRoute(authzGroups: string[], routeRoles: string): boolean {
        if (authzGroups.includes('SU') || !routeRoles) return true

        const roles: Set<string> = new Set<string>(routeRoles.split(','))
        return authzGroups.find(role => roles.has(role)) !== undefined
    }

    /**********************************************************************************************
     * @method prepareSubgroup
     *********************************************************************************************/
    private prepareSubgroup(subgroup: IAppSubgroup): IAppSubgroup {
        subgroup.apps.sort((a, b) =>
            (a.routeDescr || a.id).localeCompare(b.routeDescr || b.id)
        )
        return subgroup
    }

    /**********************************************************************************************
     * @method getUserAuthzsUM
     *********************************************************************************************/
    private async getUserAuthzsUM(userId: string, unit: string): Promise<IUserAuthzs> {
        return this.userService.getUserAuthzsUM(userId, unit).then(
            authzs => authzs.reduce((curr, auth) => {
                curr[auth.APP_ID] = curr[auth.APP_ID] || []
                curr[auth.APP_ID].push({ groupId: auth.ROLE_ID, countries: auth.COUNTRIES.split(',') })

                return curr
            }, {})
        )
    }

    /**********************************************************************************************
     * @method getUserAuthzsAPIGW
     *********************************************************************************************/
     private async getUserAuthzsAPIGW(userId: string): Promise<IUserAuthzs> {
        const token: IToken = await this.userService.getToken()
        if (!token) return undefined

        const ret: IUserAuthzs = {}
        const apiRoles = (await this.userService.getSecundaRoles(token, userId)).map(el => el.roleId)
        .filter(el => config.secundaApps.indexOf(el.split('-')[0] as EApps) >= 0 )

        for (const role of apiRoles) {
            const [app, group] = role.split('-')
            const countryScopes = (await this.userService.getSecundaRoles(token, userId, role, app))[0].scopes || []

            const countries = []
            ret[app]= ret[app] || []
            for (const scope of Object.keys(countryScopes)) {
                if (app !== EApps.IFI) {
                    countryScopes[scope].forEach(el => countries.push(el.split('/')[1]))
                } else {
                    countryScopes[scope].forEach(el => countries.push(el.split('/')[1] + '/' + el.split('/')[2]))
                }
            }
            ret[app].push({ groupId: group, countries: countries })
        }
        return ret
    }
}

interface IBaseAppGroup {
    name: string
    order: number
}

interface IAppGroup extends IBaseAppGroup {
    subgroups: {[subgroupName: string]: IAppSubgroup}
}

export interface IAppSubgroup extends IBaseAppGroup {
    apps: IUserApp[]
}
