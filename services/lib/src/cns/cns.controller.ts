import { ICnsNotification, ICnsNotificationStatus, ICnsReferenceType } from 'notification'
import { NotificationApi } from '../api'
import { catchAll } from '../catch-decorator'


@catchAll(__filename)
export class CnsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method send
     *********************************************************************************************/
    public async send(notification: ICnsNotification, user: string, appId: string): Promise<number> {
        return NotificationApi.sendCnsNotification(notification, user, appId, true)
    }

    /**********************************************************************************************
     * @method getStatus
     *********************************************************************************************/
    public async getStatus(referenceId: string, referenceType: ICnsReferenceType): Promise<ICnsNotificationStatus> {
        return NotificationApi.checkCnsNotificationStatus(referenceId, referenceType)
    }
}
