import {
    IArchivedRoundInfo,
    ICurrentRoundInfo,
    IRoundStorage,
    IStorage
} from '../../../dashboard/src/config/shared-interfaces'
import { EApps } from 'config'
import { EStatusRepo } from 'country-status'
import { ETemplateTypes } from '../../../shared-lib/dist/prelib/files'
import { IBinaryFile } from '../template/shared-interfaces'
import { ICountry } from '../menu'
import { RequestService } from '../request.service'


export class DashboardApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getApplicationStatus
     *********************************************************************************************/
    public static getApplicationStatus(appId: EApps): Promise<EStatusRepo> {
        return RequestService.request(EApps.DASHBOARD, `/statuses/applications/${appId}`)
    }

    /**********************************************************************************************
     * @method getCurrentRoundInfo
     *********************************************************************************************/
    public static getCurrentRoundInfo(appId: EApps): Promise<ICurrentRoundInfo> {
        return RequestService.request(EApps.DASHBOARD, `/config/currentRoundInfo/${appId}`)
    }

    /**********************************************************************************************
     * @method getCurrentStorage
     *********************************************************************************************/
    public static getCurrentStorage(appId: EApps): Promise<IStorage> {
        return RequestService.request(EApps.DASHBOARD, `/config/currentStorage/${appId}`)
    }

    /**********************************************************************************************
     * @method getArchivedRoundInfo
     *********************************************************************************************/
    public static getArchivedRoundInfo(
        appId: EApps, year: number, period: string, storageId: string, version?: number
    ): Promise<IArchivedRoundInfo> {
        return RequestService.request(
            EApps.DASHBOARD, `/config/archiveRoundInfo/${appId}/${year}/${period}/${storageId}/${version || 1}`
        )
    }

    /**********************************************************************************************
     * @method getRoundInfo
     *********************************************************************************************/
    public static getRoundInfo(
        appId: EApps, roundSid: number, storageSid: number,
    ): Promise<IArchivedRoundInfo> {
        return RequestService.request(EApps.DASHBOARD, `/config/roundInfo/${appId}/${roundSid}/${storageSid}`)
    }

    /**********************************************************************************************
     * @method getStorages
     *********************************************************************************************/
    public static getStorages(appId: EApps): Promise<IStorage[]> {
        return RequestService.request(EApps.DASHBOARD, `/config/storages/${appId}`)
    }

    /**********************************************************************************************
     * @method getStorage
     *********************************************************************************************/
    public static getStorage(appId: EApps, storageSid: number): Promise<IStorage> {
        return RequestService.request(EApps.DASHBOARD, `/config/storage/${appId}/${storageSid}`)
    }

    /**********************************************************************************************
     * @method getCountry
     *********************************************************************************************/
    public static getCountry(countryId: string): Promise<ICountry> {
        return RequestService.request(EApps.DASHBOARD, `/config/country/${countryId}`)
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public static getCountries(countryIds: string[]): Promise<ICountry[]> {
        return RequestService.request(EApps.DASHBOARD, `/config/countries/${countryIds}`)
    }

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    public static getCountryGroupCountries(countryGroupId: string, inactive?: boolean): Promise<ICountry[]> {
        const query = inactive ? '?inactive=true' : ''
        return RequestService.request(EApps.DASHBOARD, `/config/countryGroupCountries/${countryGroupId}${query}`)
    }

    /**********************************************************************************************
     * @method getActiveTemplate
     *********************************************************************************************/
    public static getActiveTemplate(appId: EApps, templateId: ETemplateTypes): Promise<IBinaryFile> {
        return RequestService.request(EApps.DASHBOARD, `/templates/active/${appId}/${templateId}`)
    }

    /**********************************************************************************************
     * @method getRoundStorage
     *********************************************************************************************/
    public static getRoundStorage(roundSid: number, storageSid: number, textSid?: number): Promise<IRoundStorage> {
        return RequestService.request(
            EApps.DASHBOARD,
            `/config/roundStorage?roundSid=${roundSid}&storageSid=${storageSid}${textSid ? '&textSid=' + textSid : ''}`
        )
    }

    /**********************************************************************************************
     * @method getApplicationCountries
     *********************************************************************************************/
    public static getApplicationCountries(appId: EApps): Promise<string[]> {
        return RequestService.request(EApps.DASHBOARD, `/config/applicationCountries/${appId}`)
    }

    /**********************************************************************************************
     * @method getLatestOffsetRound
     *********************************************************************************************/
    public static getLatestOffsetRound(
        appId: EApps, roundSid: number, offset: number
    ): Promise<number> {
        return RequestService.request(EApps.DASHBOARD, `/config/latestOffRound/${appId}/${roundSid}/${offset}`)
    }

    /**********************************************************************************************
     * @method getLatestRound
     *********************************************************************************************/
    public static getLatestRound(
        appId: EApps, roundSid: number
    ): Promise<number> {
        return RequestService.request(EApps.DASHBOARD, `/config/latestRound/${appId}/${roundSid}`)
    }

    /**********************************************************************************************
     * @method getRoundYear
     *********************************************************************************************/
    public static getRoundYear(
        roundSid: number
    ): Promise<number> {
        return RequestService.request(EApps.DASHBOARD, `/config/roundYear/${roundSid}`)
    }

}
