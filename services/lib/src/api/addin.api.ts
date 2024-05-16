import { EApps } from 'config'
import { IAddinApp } from '../../../addin/src/dashboard/shared-interfaces'
import { RequestService } from '../request.service'


export class AddinApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method setDashboardTreeApps
     *********************************************************************************************/
    public static setDashboardTreeApps(data:IAddinApp[]): Promise<number> {
        return RequestService.request(EApps.ADDIN, '/dashboard/tree', 'post', data)
    }
    /**********************************************************************************************
     * @method getDashboardTreeApps
     *********************************************************************************************/
    public static getDashboardTreeApps(): Promise<IAddinApp[]> {
        return RequestService.request(EApps.ADDIN, '/dashboard/tree')
    }
    /**********************************************************************************************
     * @method getDashboardPublicApps
     *********************************************************************************************/
    public static getDashboardPublicApps(): Promise<IAddinApp[]> {
        return RequestService.request(EApps.ADDIN, '/dashboard/public')
    }
    /**********************************************************************************************
     * @method getDashboardRestrictedApps
     *********************************************************************************************/
    public static getDashboardRestrictedApps(): Promise<IAddinApp[]> {
        return RequestService.request(EApps.ADDIN, '/dashboard/restricted')
    }
}
