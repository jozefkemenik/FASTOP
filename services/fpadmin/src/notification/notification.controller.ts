import { INotificationGroup } from './shared-interfaces'
import { NotificationService } from './notification.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class NotificationController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(
        private readonly notificationService: NotificationService
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNotificationGroups
     *********************************************************************************************/
    public async getNotificationGroups(): Promise<INotificationGroup[]> {
        return this.notificationService.getNotificationGroups()
    }
}
