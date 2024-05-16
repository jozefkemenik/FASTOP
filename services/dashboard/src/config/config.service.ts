import { EApps } from 'config'

import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { CacheMap } from '../../../lib/dist'
import { DataAccessApi } from '../../../lib/dist/api'
import { IDBCountry } from '../../../lib/dist/menu'

import {
    ICustomTextInfo,
    IDBGeoArea,
    IDBRound,
    IDBStorage,
    IGeoAreaMapping,
    IParam,
    IRoundInfo,
    IRoundStorage,
    IStorageInfo
} from '.'
import { IStorage } from './shared-interfaces'

export class ConfigService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _storages: CacheMap<EApps, IStorage[]> = new CacheMap<EApps, IStorage[]>()
    private _countries: CacheMap<string, IDBCountry> = new CacheMap<string, IDBCountry>()
    private _countryGroupCountries: CacheMap<string, IDBCountry[]> = new CacheMap<string, IDBCountry[]>()
    private _geoAreas: IDBGeoArea[]
    private _roundSids: CacheMap<string, number> = new CacheMap()
    private _storageSids: CacheMap<string, number> = new CacheMap()
    private _params: CacheMap<string, IParam> = new CacheMap()
    private _appCountries: CacheMap<string, string[]> = new CacheMap()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    public async getCountryGroupCountries(countryGroupId: string, inactive: boolean): Promise<IDBCountry[]> {
        const key = `${countryGroupId}${inactive}`
        if (!this._countryGroupCountries.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_country_group_id', type: STRING, value: countryGroupId },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_active_only', type: NUMBER, value: Number(!inactive) },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getGeoAreasByCountryGroup', options)
            this._countryGroupCountries.set(key, dbResult.o_cur)
        }

        return this._countryGroupCountries.get(key)
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(countryIds: string[]): Promise<IDBCountry[]> {
        const normalizedIds = countryIds.map(c => c.toUpperCase())
        const missingCodes = normalizedIds.filter(ctyId => !this._countries.has(ctyId))

        if (missingCodes.length > 0) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_country_ids', type: STRING, value: missingCodes },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getCountries', options)
            dbResult.o_cur.forEach(country => this._countries.set(country.COUNTRY_ID, country))
        }

        return normalizedIds.map(ctyId => this._countries.get(ctyId))
    }

    /**********************************************************************************************
     * @method getCustomTextInfo
     *********************************************************************************************/
    public async getCustomTextInfo(textSid?: number): Promise<ICustomTextInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cust_storage_text_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_title', type: STRING, dir: BIND_OUT },
                { name: 'o_descr', type: STRING, dir: BIND_OUT },
                { name: 'p_cust_storage_text_sid', type: NUMBER, value: textSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_getters.getCustomTextInfo', options)
        return {
            textSid: Number(dbResult.o_cust_storage_text_sid),
            textTitle: dbResult.o_title,
            textDescr: dbResult.o_descr,
        }
    }

    /**********************************************************************************************
     * @method getGeoAreas
     *********************************************************************************************/
    public async getGeoAreas(): Promise<IDBGeoArea[]> {
        if (!this._geoAreas) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getGeoAreas', options)
            this._geoAreas = dbResult.o_cur
        }
        return this._geoAreas
    }

    /**********************************************************************************************
     * @method getRoundInfo
     *********************************************************************************************/
    public async getRoundInfo(appId?: EApps, roundSid?: number): Promise<IRoundInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'o_round_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_year', type: NUMBER, dir: BIND_OUT },
                { name: 'o_descr', type: STRING, dir: BIND_OUT },
                { name: 'o_period', type: STRING, dir: BIND_OUT },
                { name: 'o_period_id', type: STRING, dir: BIND_OUT },
                { name: 'o_version', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getRoundInfo', options)
        return {
            roundSid: Number(dbResult.o_round_sid),
            year: Number(dbResult.o_year),
            roundDescr: dbResult.o_descr,
            periodDescr: dbResult.o_period,
            periodId: dbResult.o_period_id,
            version: dbResult.o_version,
        }
    }

    /**********************************************************************************************
     * @method getRoundSid
     *********************************************************************************************/
    public async getRoundSid(year: number, period: string, version: number): Promise<number> {
        const ver = version > 0 ? version : 1
        const key = `${year}-${period}-${ver}`
        if (!this._roundSids.has(key)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_year', type: NUMBER, value: year },
                    { name: 'p_period', type: STRING, value: period },
                    { name: 'p_version', type: NUMBER, value: ver },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getRoundSid', options)
            this._roundSids.set(key, dbResult.o_res)
        }
        return this._roundSids.get(key)
    }

    /**********************************************************************************************
     * @method getStorageSid
     *********************************************************************************************/
    public async getStorageSid(storageId: string): Promise<number> {
        if (!this._storageSids.has(storageId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_storage_id', type: STRING, value: storageId },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getStorageSid', options)
            this._storageSids.set(storageId, dbResult.o_res)
        }
        return this._storageSids.get(storageId)
    }

    /**********************************************************************************************
     * @method getRounds
     *********************************************************************************************/
    public async getRounds(appId: EApps = null): Promise<IDBRound[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getRounds', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getStorageInfo
     *********************************************************************************************/
    public async getStorageInfo(appId: EApps, storageSid?: number): Promise<IStorageInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'o_storage_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_descr', type: STRING, dir: BIND_OUT },
                { name: 'o_storage_id', type: STRING, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getStorageInfo', options)
        return {
            storageSid: Number(dbResult.o_storage_sid),
            storageDescr: dbResult.o_descr,
            storageId: dbResult.o_storage_id,
        }
    }

    /**********************************************************************************************
     * @method getStorages
     *********************************************************************************************/
    public async getStorages(appId: EApps): Promise<IDBStorage[]> {
        if (!this._storages.has(appId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getStorages', options)
            this._storages.set(appId, dbResult.o_cur)
        }
        return this._storages.get(appId)
    }

    /**********************************************************************************************
     * @method getGeoAreaMappings
     *********************************************************************************************/
    public async getGeoAreaMappings(mappings?: string[]): Promise<IGeoAreaMapping[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_mapping_ids', type: STRING, value: mappings ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getGeoAreaMappings', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getRoundStorage
     *********************************************************************************************/
    public async getRoundStorage(roundSid: number, storageSid: number, textSid?: number): Promise<IRoundStorage> {
        const options: ISPOptions = {
            params: [
                { name: 'o_round_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_round_id', type: STRING, dir: BIND_OUT },
                { name: 'o_storage_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_storage_id', type: STRING, dir: BIND_OUT },
                { name: 'o_cust_text_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_cust_text_id', type: STRING, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: textSid ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getRoundStorageInfo', options)
        return {
            roundSid: Number(dbResult.o_round_sid),
            roundId: dbResult.o_round_id,
            storageSid: Number(dbResult.o_storage_sid),
            storageId: dbResult.o_storage_id,
            custTextSid: dbResult.o_cust_text_sid ? Number(dbResult.o_cust_text_sid) : undefined,
            custTextId: dbResult.o_cust_text_id ?? undefined,
        }
    }

    /**********************************************************************************************
     * @method getParameter
     *********************************************************************************************/
    public async getParameter(paramId: string): Promise<IParam> {
        if (!this._params.has(paramId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_param_id', type: STRING,  value: paramId},
                    { name: 'o_descr', type: STRING, dir: BIND_OUT },
                    { name: 'o_value', type: STRING, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getParameter', options)
            this._params.set(paramId, { descr: dbResult.o_descr, value: dbResult.o_value })
        }

        return this._params.get(paramId)
    }

    /**********************************************************************************************
     * @method getApplicationCountries
     *********************************************************************************************/
    public async getApplicationCountries(appId: EApps): Promise<string[]> {
        if (!this._appCountries.has(appId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_app_id', type: STRING, value: appId },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
                arrayFormat: true,
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getApplicationCountries', options)
            this._appCountries.set(appId, dbResult.o_cur)
        }
        return this._appCountries.get(appId)

    }

    /**********************************************************************************************
     * @method getLatestOffsetRound
     *********************************************************************************************/
    public async getLatestOffsetRound(appId: EApps, roundSid: number, offset: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: appId },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_history_offset', type: NUMBER, dir: BIND_IN, value: offset ?? 0}
            ],
        }
        const dbResult = await DataAccessApi.execSP('CORE_GETTERS.getLatestApplicationRound', options)
        return dbResult
    }

    /**********************************************************************************************
     * @method getLatestRound
     *********************************************************************************************/
    public async getLatestRound(appId: EApps, roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: appId },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid }
            ],
        }
        const dbResult = await DataAccessApi.execSP('CORE_GETTERS.getLatestApplicationRound', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getRoundYear
     *********************************************************************************************/
    public async getRoundYear(roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT}
            ],
        }
        const dbResult = await DataAccessApi.execSP('CORE_GETTERS.getRoundYear', options)
        return dbResult.o_res
    }
}
