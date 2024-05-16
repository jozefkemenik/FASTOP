import { INotificationGroup } from './shared-interfaces'
import { NotificationApi } from '../../../lib/dist/api'


export class NotificationService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _notificationGroups: INotificationGroup[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNotificationGroups
     *********************************************************************************************/
    public async getNotificationGroups(): Promise<INotificationGroup[]> {
        if (!this._notificationGroups) {
            this._notificationGroups = await NotificationApi.getCnsClientSystemDetails().then(
                details => details.notificationGroups.map(ng => ({
                    code: ng.notificationGroupCode, name: ng.notificationGroupName
                }))
            )
        }
        return this._notificationGroups
    }
}
