import {
    IArchivedRoundInfo,
    ICurrentRoundInfo,
    IGeoArea,
    IGeoAreaMapping,
    IParam,
    IRound,
    IRoundInfo,
    IRoundStorage,
    IStorage
} from '.'
import { ICountry, ICountryGroup } from '../../../lib/dist/menu'
import { ConfigService } from './config.service'
import { EApps } from 'config'
import { catchAll } from '../../../lib/dist/catch-decorator'

@catchAll('ConfigController')
export class ConfigController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private configService: ConfigService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    public getCountryGroupCountries(countryGroupId: string, inactive: boolean): Promise<ICountry[]> {
        return this.configService.getCountryGroupCountries(countryGroupId?.toUpperCase(), inactive)
    }

    /**********************************************************************************************
     * @method getCountryGroupsWithCountries
     *********************************************************************************************/
    public async getCountryGroupsWithCountries(countryGroupIds: string[]): Promise<ICountryGroup[]> {
        const countryGroups: ICountry[] = await Promise.all(countryGroupIds.map(ctyGrpId => this.getCountry(ctyGrpId)))
        return Promise.all(
            countryGroups.map(
                cty => this.getCountryGroupCountries(cty.COUNTRY_ID, false).then(
                    (members) => Object.assign(cty, { members })
                )
            )
        )
    }

    /**********************************************************************************************
     * @method getCountry
     *********************************************************************************************/
    public async getCountry(countryId: string): Promise<ICountry> {
        return this.configService.getCountries([countryId]).then(
            countries => countries?.length ? countries[0] : undefined
        )
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public getCountries(countryIds: string[]): Promise<ICountry[]> {
        return this.configService.getCountries(countryIds)
    }

    /**********************************************************************************************
     * @method getArchiveRoundInfo
     *********************************************************************************************/
    public getArchiveRoundInfo(
        appId: EApps, roundSid: number, storageSid: number,
    ): Promise<IArchivedRoundInfo> {
        return Promise.all([
            this.configService.getRoundInfo(appId, roundSid),
            this.configService.getStorageInfo(appId, storageSid),
        ]).then(
            results => Object.assign({}, ...results)
        )
    }

    /**********************************************************************************************
     * @method getPreviousRoundInfo
     *********************************************************************************************/
    public getPreviousRoundInfo(
        appId: EApps, year: number, period: string, storageId: string, version: number
    ): Promise<IArchivedRoundInfo> {
        return Promise.all([
            this.configService.getRoundSid(year, period, version),
            this.configService.getStorageSid(storageId),
        ]).then(
            ([roundSid, storageSid]) =>
                this.getArchiveRoundInfo(appId, roundSid, storageSid)
        )
    }

    /**********************************************************************************************
     * @method getCurrentRoundInfo
     *********************************************************************************************/
    public getCurrentRoundInfo(appId: EApps): Promise<ICurrentRoundInfo> {
        return Promise.all([
            this.configService.getRoundInfo(appId),
            this.configService.getStorageInfo(appId),
            this.configService.getCustomTextInfo(),
        ]).then(
            results => Object.assign({}, ...results)
        )
    }

    /**********************************************************************************************
     * @method getGeoAreas
     *********************************************************************************************/
    public getGeoAreas(): Promise<IGeoArea[]> {
        return this.configService.getGeoAreas()
    }

    /**********************************************************************************************
     * @method getRoundInfo
     *********************************************************************************************/
    public getRoundInfo(roundSid: number): Promise<IRoundInfo> {
        return this.configService.getRoundInfo(null, roundSid)
    }

    /**********************************************************************************************
     * @method getRounds
     *********************************************************************************************/
    public getRounds(appId: EApps): Promise<IRound[]> {
        return this.configService.getRounds(appId)
    }

    /**********************************************************************************************
     * @method getStorages
     *********************************************************************************************/
    public getStorages(appId: EApps): Promise<IStorage[]> {
        return this.configService.getStorages(appId)
    }

    /**********************************************************************************************
     * @method getStorage
     *********************************************************************************************/
    public getStorage(appId: EApps, storageSid: number): Promise<IStorage> {
        return this.configService.getStorages(appId).then(
            storages => storages.find(s => s.storageSid === storageSid)
        )
    }

    /**********************************************************************************************
     * @method getCurrentStorage
     *********************************************************************************************/
    public getCurrentStorage(appId: EApps): Promise<IStorage> {
        return this.getCurrentRoundInfo(appId)
            .then(roundInfo => roundInfo.storageSid)
            .then(storageSid => this.getStorage(appId, storageSid))
    }

    /**********************************************************************************************
     * @method getGeoAreaMappings
     *********************************************************************************************/
    public getGeoAreaMappings(mappings?: string[]): Promise<IGeoAreaMapping[]> {
        return this.configService.getGeoAreaMappings(mappings)
    }

    /**********************************************************************************************
     * @method getRoundStorage
     *********************************************************************************************/
    public getRoundStorage(roundSid: number, storageSid: number, textSid?: number): Promise<IRoundStorage> {
        return this.configService.getRoundStorage(roundSid, storageSid, textSid)
    }

    /**********************************************************************************************
     * @method getHelpLink
     *********************************************************************************************/
    public getHelpLink(): Promise<IParam> {
        return this.configService.getParameter('FASTOP_HELP_URL')
    }

    /**********************************************************************************************
     * @method getApplicationCountries
     *********************************************************************************************/
    public getApplicationCountries(appId: EApps): Promise<string[]> {
        return this.configService.getApplicationCountries(appId)
    }

    /**********************************************************************************************
     * @method getLatestOffsetRound
     *********************************************************************************************/
    public async getLatestOffsetRound(appId: EApps, roundSid: number, offset: number): Promise<number> {
        return this.configService.getLatestOffsetRound(appId, roundSid, offset)
    }

    /**********************************************************************************************
     * @method getLatestRound
     *********************************************************************************************/
    public async getLatestRound(appId: EApps, roundSid: number): Promise<number> {
        return this.configService.getLatestRound(appId, roundSid)
    }

    /**********************************************************************************************
     * @method getRoundYear
     *********************************************************************************************/
    public async getRoundYear(roundSid: number): Promise<number> {
        return this.configService.getRoundYear(roundSid)
    }

}
