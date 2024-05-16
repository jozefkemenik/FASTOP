import { BIND_OUT, CURSOR, ISPOptions, NUMBER } from '../../db'
import { CacheMap } from '../../cache-map'
import { DataAccessApi } from '../../api/data-access.api'

import { IDBESACode, IDBOneOff, IDBOneOffType, IDBPidType, IDBScale, IDBSidType, IESACodes, IObjectPIDs, IObjectSIDs } from '.'

export abstract class MeasureSharedConfigService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////// Static Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly ADOPTION_BASE_YEAR = 2005
    private static readonly ADOPTION_YEAR_OFFSET = 6

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    protected _scales: IDBScale[]
    protected _dbpEsaRevenueCodes: IObjectSIDs
    protected _dbpEsaExpenditureCodes: IObjectSIDs
    protected _exercises: IObjectPIDs
    protected _dbpSources: IObjectSIDs
    protected _oneOff: IObjectSIDs
    protected _esaCodes = new CacheMap<string, IESACodes>()
    protected _oneOffTypesVersionByRound = {} as IOneOffTypesVersions
    protected _oneOffTypes = {} as IOneOffTypes
    protected _months: IObjectSIDs
    protected _adoptionYears: IObjectSIDs
    protected _labels: IObjectSIDs
    protected _euFunds: IObjectSIDs

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getESACodes
     *********************************************************************************************/
    public abstract getESACodes(roundSid: number): Promise<IESACodes>

    /**********************************************************************************************
     * @method getOneOffTypes
     *********************************************************************************************/
    public async getOneOffTypes(roundSid: number): Promise<IObjectSIDs> {
        const version = await this.getOneOffTypesVersion(roundSid)
        if (!Object.prototype.hasOwnProperty.call(this._oneOffTypes, version)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_version', type: NUMBER, value: version },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getOneOffTypes', options)
            this._oneOffTypes[version] = this.oneOffTypesToObject(dbResult.o_cur)
        }
        return this._oneOffTypes[version]
    }

    /**********************************************************************************************
     * @method getOneOff
     *********************************************************************************************/
    public async getOneOff(): Promise<IObjectSIDs> {
        if (!this._oneOff) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getOneOff', options)
            this._oneOff = this.oneOffToObject(dbResult.o_cur)
        }
        return this._oneOff
    }

    /**********************************************************************************************
     * @method getScales
     *********************************************************************************************/
    public async getScales(): Promise<IDBScale[]> {
        if (!this._scales) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getScales', options)
            this._scales = dbResult.o_cur
        }
        return this._scales
    }

    /**********************************************************************************************
     * @method getExercises
     *********************************************************************************************/
    public async getExercises(): Promise<IObjectPIDs> {
        if (!this._exercises) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getExercises', options)
            this._exercises = this.pidTypeToObject(dbResult.o_cur)
        }
        return this._exercises
    }

    /**********************************************************************************************
     * @method getDbpSources
     *********************************************************************************************/
    public async getDbpSources(): Promise<IObjectSIDs> {
        if (!this._dbpSources) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getDbpSources', options)
            this._dbpSources = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._dbpSources
    }

    /**********************************************************************************************
     * @method getDbpEsaRevenueCodes
     *********************************************************************************************/
    public async getDbpEsaRevenueCodes(): Promise<IObjectSIDs> {
        if (!this._dbpEsaRevenueCodes) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getDbpEsaRevenueCodes', options)
            this._dbpEsaRevenueCodes = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._dbpEsaRevenueCodes
    }

    /**********************************************************************************************
     * @method getDbpEsaExpenditureCodes
     *********************************************************************************************/
    public async getDbpEsaExpenditureCodes(): Promise<IObjectSIDs> {
        if (!this._dbpEsaExpenditureCodes) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dbp_getters.getDbpEsaExpenditureCodes', options)
            this._dbpEsaExpenditureCodes = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._dbpEsaExpenditureCodes
    }

    /**********************************************************************************************
     * @method getMonths
     *********************************************************************************************/
    public async getMonths(): Promise<IObjectSIDs> {
        if (!this._months) {
            this._months = { 1: 'January', 2: 'February', 3: 'March', 4: 'April', 5: 'May', 6: 'June',
                             7: 'July', 8: 'August', 9: 'September', 10: 'October', 11: 'November', 12: 'December', }
            this._months[-1] = '< not set >'
        }
        return this._months
    }

    /**********************************************************************************************
     * @method getAdoptionYears
     *********************************************************************************************/
    public async getAdoptionYears(): Promise<IObjectSIDs> {
        if (!this._adoptionYears) {
            const startYear = MeasureSharedConfigService.ADOPTION_BASE_YEAR
            const endYear = new Date().getFullYear() + MeasureSharedConfigService.ADOPTION_YEAR_OFFSET
            this._adoptionYears = Array.from(
                {length: 1 + endYear - startYear}, (_, idx) => startYear + idx
            ).reduce((acc, year) => {
                acc[year] = year.toString()
                return acc
            }, {})
            this._adoptionYears[-1] = '< not set >'
        }
        return this._adoptionYears
    }

    /**********************************************************************************************
     * @method getLabels
     *********************************************************************************************/
    public async getLabels(): Promise<IObjectSIDs> {
        if (!this._labels) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getLabels', options)
            this._labels = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._labels
    }

    /**********************************************************************************************
     * @method getEuFunds
     *********************************************************************************************/
    public async getEuFunds(): Promise<IObjectSIDs> {
        if (!this._euFunds) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getEuFunds', options)
            this._euFunds = this.sidTypeToObject(dbResult.o_cur)
        }
        return this._euFunds
    }

    /**********************************************************************************************
     * @method esaCodesToObject
     *********************************************************************************************/
    protected esaCodesToObject(esaCodes: IDBESACode[]): IESACodes {
        return esaCodes.reduce((acc, code) => {
            acc[code.ESA_SID] = {
                descr: code.DESCR,
                id: code.ESA_ID,
                revexpSid: code.REV_EXP_SID,
                overviewSid: code.OVERVIEW_SID
            }
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method sidTypeToObject
     **********************************************************************************************/
    protected sidTypeToObject(data: IDBSidType[]): IObjectSIDs {
        return data.reduce((acc, value) => {
            acc[value.SID] = value.DESCRIPTION
            return acc
        }, {})
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method pidTypeToObject
     **********************************************************************************************/
    private pidTypeToObject(data: IDBPidType[]): IObjectPIDs {
        return data.reduce((acc, status) => {
            acc[status.SID] = {
                PID: status.PID,
                DESCRIPTION: status.DESCRIPTION
            }
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method oneOffToObject
     **********************************************************************************************/
    private oneOffToObject(oneOffs: IDBOneOff[]): IObjectSIDs {
        return oneOffs.reduce((acc, oneOff) => {
            acc[oneOff.ONE_OFF_SID] = oneOff.DESCR
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getOneOffTypesVersion
     *********************************************************************************************/
    private async getOneOffTypesVersion(roundSid: number): Promise<number> {
        if (!roundSid) roundSid = null
        if (!Object.prototype.hasOwnProperty.call(this._oneOffTypesVersionByRound, roundSid)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getOneOffTypesVersion', options)
            this._oneOffTypesVersionByRound[roundSid] = dbResult.o_res
        }
        return this._oneOffTypesVersionByRound[roundSid]
    }

    /**********************************************************************************************
     * @method oneOffTypesToObject
     *********************************************************************************************/
    private oneOffTypesToObject(oneOffTypes: IDBOneOffType[]): IObjectSIDs {
        return oneOffTypes.reduce((acc, type) => {
            acc[type.ONE_OFF_TYPE_SID] = type.DESCR
            return acc
        }, {})
    }
}

interface IOneOffTypes {
    [version: number]: IObjectSIDs
}

interface IOneOffTypesVersions {
    [round: number]: number
}
