import {
    EStatusRepo,
    IAction,
    ICountryStatus, ICtyAccepted, ICtyRoundComment, ICtyStatusChanges,
    IMailNotification, ISetCountryStatus, ISetCountryStatusResult, ISetStatusChangeDate,
} from 'country-status'
import { EApps } from 'config'

import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

import { RequestService } from '../request.service'
import { buildQuery } from './util'

export class CountryStatusApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActions
     *********************************************************************************************/
    public static getActions(): Promise<IAction[]> {
        return RequestService.request(EApps.CS, `/mails/actions`)
    }

    /**********************************************************************************************
     * @method getCountryComments
     *********************************************************************************************/
    public static getCountryComments(
        appId: EApps, countryId: string, roundSid: number
    ): Promise<ICtyRoundComment[]> {
        return RequestService.request(EApps.CS, `/${appId}/comments/${countryId}?roundSid=${roundSid}`)
    }

    /**********************************************************************************************
     * @method getCountryLastAccepted
     *********************************************************************************************/
    public static getCountryLastAccepted(
        appId: EApps, countries: string[] = [], onlyFullStorage = false, onlyFullRound = false,
    ): Promise<ICtyAccepted[]> {
        const queryParams = []
        if (onlyFullStorage) queryParams.push('onlyFullStorage=true')
        if (onlyFullRound) queryParams.push('onlyFullRound=true')
        const query = queryParams.length ? `?${queryParams.join('&')}` : ''
        return RequestService.request(EApps.CS, `/${appId}/accepted/${countries}${query}`)
    }

    /**********************************************************************************************
     * @method getCountryStatuses
     *********************************************************************************************/
    public static getCountryStatuses(
        appId: EApps, countries: string[] = [], roundKeys?: IRoundKeys
    ): Promise<ICountryStatus[]> {
        const query = buildQuery(roundKeys)
        return RequestService.request(EApps.CS, `/${appId}/${countries}${query}`)
    }

    /**********************************************************************************************
     * @method getCountryStatusId
     *********************************************************************************************/
    public static getCountryStatusId(
        appId: EApps, countryId: string, roundKeys?: IRoundKeys
    ): Promise<EStatusRepo> {
        return this.getCountryStatuses(appId, [countryId], roundKeys)
            .then(statuses => statuses[0]?.statusId)
    }

    /**********************************************************************************************
     * @method getMailNotification
     *********************************************************************************************/
    public static getMailNotification(notification: IMailNotification): Promise<[string[], string[]]> {
        const query = buildQuery(notification)
        return RequestService.request(EApps.CS, `/mails/notification${query}`)
    }

    /**********************************************************************************************
     * @method getStatusChanges
     *********************************************************************************************/
    public static getStatusChanges(
        appId: EApps, countries: string[] = [], roundKeys?: IRoundKeys
    ): Promise<ICtyStatusChanges[]> {
        const query = roundKeys ? `?roundSid=${roundKeys.roundSid}` : ''
        return RequestService.request(EApps.CS, `/${appId}/statusChanges/${countries}${query}`)
    }

    /**********************************************************************************************
     * @method manageMailRecipient
     *********************************************************************************************/
    public static manageMailRecipient(
        notification: IMailNotification, email: string, method: 'post' | 'delete' | 'put', body?: {newEmail: string}
    ): Promise<number> {
        const query = buildQuery(notification)
        return RequestService.request(EApps.CS, `/mails/notification/${email}${query}`, method, body)
    }

    /**********************************************************************************************
     * @method setCountryStatus
     *********************************************************************************************/
    public static setCountryStatus(
        appId: EApps, countryId: string, setStatus: ISetCountryStatus
    ): Promise<ISetCountryStatusResult> {
        return RequestService.request(EApps.CS, `/${appId}/${countryId}`, 'post', setStatus)
    }

    /**********************************************************************************************
     * @method setManyCountriesStatus
     *********************************************************************************************/
    public static setManyCountriesStatus(
        appId: EApps, countries: string[] = [], setStatus: ISetCountryStatus
    ): Promise<number> {
        return RequestService.request(EApps.CS, `/${appId}/${countries}`, 'put', setStatus)
    }

    /**********************************************************************************************
     * @method setStatusChangeDate
     *********************************************************************************************/
    public static setStatusChangeDate(
        appId: EApps, countryId: string, setChangeDate: ISetStatusChangeDate
    ): Promise<undefined> {
        return RequestService.request(EApps.CS, `/${appId}/statusChanges/${countryId}`, 'put', setChangeDate)
    }
}
