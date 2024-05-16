import {
    ICnsClientSystemDetails,
    ICnsNotification,
    ICnsNotificationResult,
    ICnsNotificationStatus,
    ICnsReferenceType,
} from 'notification'
import { Level, LoggingService } from '../../../lib/dist'
import { RequestService } from '../../../lib/dist/request.service'
import { config } from '../../../config/config'


export class CnsService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _clientSystemDetails: ICnsClientSystemDetails

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(
        private readonly logs: LoggingService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method send
     *********************************************************************************************/
    public async send(notification: ICnsNotification): Promise<ICnsNotificationResult> {
        return this.callCns('notifications', 'post', notification)
    }

    /**********************************************************************************************
     * @method checkStatus
     *********************************************************************************************/
    public async checkStatus(
        referenceId: string, referenceType: ICnsReferenceType = 'NOTIFICATION_ID'
    ): Promise<ICnsNotificationStatus> {
        return this.callCns(`notifications/${referenceId}?referenceType=${referenceType}`)
    }

    /**********************************************************************************************
     * @method getClientSystemDetails
     *********************************************************************************************/
    public async getClientSystemDetails(): Promise<ICnsClientSystemDetails> {
        if (!this._clientSystemDetails) {
            this._clientSystemDetails = await this.callCns('clientSystems/details')
        }
        return this._clientSystemDetails
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getEndpointUrl
     *********************************************************************************************/
    private getEndpointUrl(endpoint: string): string {
        // replace /xxx//yyy to /xxx/yyy
        return `${config.cns.url}/${endpoint}`
            .replace('//', '/')
            .replace(':/', '://')
    }

    /**********************************************************************************************
     * @method getAuthHeader
     *********************************************************************************************/
    private getAuthHeader(): Record<string, string> {
        return { 'X-CNS-CS-Auth-Key': config.cns.auth }
    }

    /**********************************************************************************************
     * @method callCns
     *********************************************************************************************/
    private callCns<T, R>(
        endpoint: string, method: 'get' | 'post' = 'get', body?: T
    ): Promise<R> {

        const url = this.getEndpointUrl(endpoint)

        this.logs.log(`Calling cns url: ${url}`, Level.INFO)

        return RequestService.requestUri(
            url,
            method,
            body,
            this.getAuthHeader(),
        )
    }

}
