import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { ICountryCurrencyInfo, IDBESACode, IESACodes, IObjectSIDs, MeasureSharedService } from '../../../lib/dist/measure'
import { CacheMap } from '../../../lib/dist'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'
import { LibMenuService } from '../../../lib/dist/menu/menu.service'

import {
    IDBCustStorageText,
    IDBOneOffPrinciples,
    IDBOverview,
    IDBRevExp,
    IDBStatuses,
    IOneOffPrinciples
} from '../config'
import { IDictionaries } from '.'
import { IMeasureDetails } from '../measure'

export class SharedService extends MeasureSharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _statuses: IObjectSIDs
    private _revexp: IObjectSIDs
    private _overviews: IObjectSIDs[] = [null, null]
    private _dbOverviews: IDBOverview[]
    private _esaPeriodByRound = {} as IESAPeriods
    private _oneOffPrinciples: IOneOffPrinciples
    private _dbEsaCodes = new CacheMap<string, IDBESACode[]>()

    private readonly _menuService: LibMenuService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this._menuService = new LibMenuService(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get menuService() {
        return this._menuService
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getColumnValue
     *********************************************************************************************/
    public getColumnValue(
        column: string, row: IMeasureDetails, dictionaries: IDictionaries
    ): string | number {
        switch (column) {
            case 'STATUS_DESCR':
                return dictionaries.statuses[row.STATUS_SID]
            case 'REV_EXP_DESCR':
                return dictionaries.revexp[row.REV_EXP_SID]
            case 'OO_PRINCIPLE_DESCR':
                return dictionaries.oneOffPrinciples[row.OO_PRINCIPLE_SID].descr
            case 'OVERVIEW_DESCR':
                return dictionaries.overviews[dictionaries.esaCodes[row.ESA_SID].overviewSid]
            default:
                return super.getColumnValue(column, row, dictionaries)
        }
    }

    /**********************************************************************************************
     * @method getDictionaries
     *********************************************************************************************/
    public async getDictionaries(roundSid: number): Promise<IDictionaries> {
        roundSid = roundSid || 0
        return Promise.all([
            super.getDictionaries(roundSid),
            this.getStatuses(),
            this.getRevExp(),
            this.getOneOffPrinciples(),
            this.getOverviews(),
        ]).then( ([baseDictionary, statuses, revexp, oneOffPrinciples, overviews]) =>
            ({ ...baseDictionary, statuses, revexp, oneOffPrinciples, overviews }))
    }

    /**********************************************************************************************
     * @method getOneOffPrinciples
     *********************************************************************************************/
    public async getOneOffPrinciples(): Promise<IOneOffPrinciples> {
        if (!this._oneOffPrinciples) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getOneOffPrinciples', options)
            this._oneOffPrinciples = this.oneOffPrinciplesToObject(dbResult.o_cur)
        }
        return this._oneOffPrinciples
    }

    /**********************************************************************************************
     * @method getESACodes
     *********************************************************************************************/
    public async getESACodes(roundSid: number): Promise<IESACodes> {
        const esaPeriod = await this.getESAPeriod(roundSid)
        if (!this._esaCodes.has(esaPeriod)) {
            this._esaCodes.set(esaPeriod, this.esaCodesToObject(await this.getDBEsaCodes(esaPeriod)))
        }
        return this._esaCodes.get(esaPeriod)
    }

    /**********************************************************************************************
     * @method getDBEsaCodes
     *********************************************************************************************/
    public async getDBEsaCodes(esaPeriod?: string): Promise<IDBESACode[]> {
        if (!this._dbEsaCodes.has(esaPeriod)) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            if (esaPeriod) options.params.push({ name: 'p_esa_period', type: STRING, value: esaPeriod })
            const dbResult = await DataAccessApi.execSP('dfm_getters.getESACodes', options)
            this._dbEsaCodes.set(esaPeriod, dbResult.o_cur)
        }
        return this._dbEsaCodes.get(esaPeriod)
    }

    /**********************************************************************************************
     * @method getESAPeriod
     *********************************************************************************************/
    public async getESAPeriod(roundSid: number): Promise<string> {
        if (!roundSid) roundSid = null
        if (!Object.prototype.hasOwnProperty.call(this._esaPeriodByRound, roundSid)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'o_res', type: STRING, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getEsaPeriod', options)
            this._esaPeriodByRound[roundSid] = dbResult.o_res
        }
        return this._esaPeriodByRound[roundSid]
    }

    /**********************************************************************************************
     * @method getRevExp
     *********************************************************************************************/
    public async getRevExp(): Promise<IObjectSIDs> {
        if (!this._revexp) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getRevExp', options)
            this._revexp = this.revexpToObject(dbResult.o_cur)
        }
        return this._revexp
    }

    /**********************************************************************************************
     * @method getStatuses
     *********************************************************************************************/
    public async getStatuses(): Promise<IObjectSIDs> {
        if (!this._statuses) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getStatuses', options)
            this._statuses = this.statusesToObject(dbResult.o_cur)
        }
        return this._statuses
    }

    /**********************************************************************************************
     * @method getOverviews
     *********************************************************************************************/
    public async getOverviews(isFilter=false): Promise<IObjectSIDs> {
        const _isFilter = Number(isFilter)
        if (!this._overviews[_isFilter]) {
            // Fill _overviews : [all, only filters]
            const dbOverviews = await this.getDBOverviews()
            this._overviews[0] = this.overviewsToObject(dbOverviews)
            this._overviews[1] = this.overviewsToObject(dbOverviews.filter(o => o.IS_FILTER === 1))
        }
        return this._overviews[_isFilter]
    }

    /**********************************************************************************************
     * @method getOverviews
     *********************************************************************************************/
    public async getDBOverviews(): Promise<IDBOverview[]> {
        if (!this._dbOverviews) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_getters.getOverviews', options)
            this._dbOverviews = dbResult.o_cur
        }
        return this._dbOverviews
    }

    /**********************************************************************************************
     * @method getCustStorageTexts
     *********************************************************************************************/
    public async getCustStorageTexts(roundSid: number): Promise<IDBCustStorageText[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_getters.getCustStorageTexts', options)
        return dbResult.o_cur
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fetchCountryCurrencyInfo
     *********************************************************************************************/
    protected async fetchCountryCurrencyInfo(
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        countryId: string, roundSid: number, version: number
    ): Promise<ICountryCurrencyInfo> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_getters.getCountryCurrency', options)
        return dbResult.o_cur[0]
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method overviewsToObject
     **********************************************************************************************/
    private overviewsToObject(overviews: IDBOverview[]): IObjectSIDs {
        return overviews.reduce((acc, overview) => (acc[overview.OVERVIEW_SID] = overview.DESCR, acc), {})
    }

    /**********************************************************************************************
     * @method statusesToObject
     **********************************************************************************************/
    private statusesToObject(statuses: IDBStatuses[]): IObjectSIDs {
        return statuses.reduce((acc, status) => (acc[status.STATUS_SID] = status.DESCR, acc), {})
    }

    /**********************************************************************************************
     * @method revexpToObject
     **********************************************************************************************/
    private revexpToObject(revexps: IDBRevExp[]): IObjectSIDs {
        return revexps.reduce((acc, revexp) => (acc[revexp.REV_EXP_SID] = revexp.DESCR, acc), {})
    }

    /**********************************************************************************************
     * @method oneOffPrinciplesToObject
     **********************************************************************************************/
    private oneOffPrinciplesToObject(oneOffPrinciples: IDBOneOffPrinciples[]): IOneOffPrinciples {
        return oneOffPrinciples.reduce((acc, oneOffPrinciple) => {
            acc[oneOffPrinciple.OO_PRINCIPLE_SID] = {
                id: oneOffPrinciple.OO_PRINCIPLE_ID,
                descr: oneOffPrinciple.DESCR
            }
            return acc
        }, {})
    }
}

interface IESAPeriods {
    [round: number]: string
}
