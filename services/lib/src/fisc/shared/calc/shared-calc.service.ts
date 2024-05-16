import { EApps } from 'config'

import { BIND_OUT, CURSOR, DATE, ISPOptions, NUMBER, STRING } from '../../../db'
import { DataAccessApi } from '../../../api/data-access.api'
import { SharedLibService } from '../shared-lib.service'

import { ICalcIndicDataParams, IDBCalculatedIndicator, IDBGridLine, IDBIndicator, IDBLineData, ILine, ISemiElasticity } from '.'

export abstract class SharedCalcService extends SharedLibService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    protected _gridLines: {[ratsIdRoundSid: string]: IDBGridLine} = {}
    protected _indicators: {[id: string]: IDBIndicator} = {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method uploadCalculatedIndicatorData
     *********************************************************************************************/
    public async uploadCalculatedIndicatorData(params: ICalcIndicDataParams): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: params.p_round_sid },
                { name: 'p_indicator_sid', type: NUMBER, value: params.p_indicator_sid },
                { name: 'p_country_id', type: STRING, value: params.p_country_id },
                { name: 'p_start_year', type: NUMBER, value: params.p_start_year },
                { name: 'p_vector', type: STRING, value: params.p_vector },
                { name: 'p_last_change_user', type: STRING, value: params.p_last_change_user },
                { name: 'p_source', type: STRING, value: params.p_source },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_calculated.UploadCalculatedIndicatorData', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getAmecoLastChangeDate
     *********************************************************************************************/
    public async getAmecoLastChangeDate(countryId: string, roundSid: number): Promise<Date> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: DATE, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_calculated.getAmecoLastChangeDate', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getAmecoIndicators
     *********************************************************************************************/
    public async getAmecoIndicators(
        countryId: string, indicators: string[], roundSid: number,
    ): Promise<IDBCalculatedIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_indicators', type: STRING, value: indicators },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_calculated.getAmecoIndicators', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndicatorById
     *********************************************************************************************/
    public async getIndicatorById(id: string): Promise<IDBIndicator> {
        if (!this._indicators[id]) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_indicator_id', type: STRING, value: id },
                ],
            }
            const dbResult = await DataAccessApi.execSP('idr_getters.getIndicatorById', options)
            this._indicators[id] = dbResult.o_cur[0]
        }
        return this._indicators[id]
    }

    /**********************************************************************************************
     * @method getSemiElasticityInfo
     *********************************************************************************************/
     public async getSemiElasticityInfo(countryId: string, roundSid: number): Promise<ISemiElasticity> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_calculated.getSemiElasticityInfo', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getCalculatedIndicators
     *********************************************************************************************/
    public async getCalculatedIndicators(
        countryId: string, sources: string[], indicators: string[], roundSid: number,
    ): Promise<IDBCalculatedIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_sources', type: STRING, value: sources },
                { name: 'p_indicators', type: STRING, value: indicators },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_calculated.getCalculatedIndicators', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getLineDataNoLevel
     *********************************************************************************************/
    public async getLineDataNoLevel(
        appId: EApps, lineId: string, countryId: string, roundSid?: number, version?: number
    ): Promise<IDBLineData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_line_id', type: STRING, value: lineId },
                { name: 'p_country_id', type: STRING, value: countryId },
            ],
        }
        if (roundSid || version) options.params.push({ name: 'p_round_sid', type: NUMBER, value: roundSid })
        if (version) options.params.push({ name: 'p_version', type: NUMBER, value: version })

        const dbResult = await DataAccessApi.execSP('gd_grid_data.getLineDataNoLevel', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getLineByRatsId
     *********************************************************************************************/
    public async getLineByRatsId(ratsId: string, roundSid: number): Promise<IDBGridLine> {
        const key = `a${roundSid}b${ratsId}`
        if (!this._gridLines[key]) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_rats_id', type: STRING, value: ratsId },
                    { name: 'p_round_sid', type: NUMBER, value: roundSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('gd_getters.getGridLineByRatsId', options)
            this._gridLines[key] = dbResult.o_cur[0]
        }
        return this._gridLines[key]
    }

    /**********************************************************************************************
     * @method canModifyCountry
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    public canModifyCountry(ctyStatus: string): boolean {
        return true // EStatusRepo.ARCHIVED !== ctyStatus && EStatusRepo.VALIDATED !== ctyStatus
    }

    /**********************************************************************************************
     * @method getCalculatedIndicatorLastChangeDate
     *********************************************************************************************/
    public async getCalculatedIndicatorLastChangeDate(indicatorId: string,
                                                      countryId: string,
                                                      roundSid: number): Promise<Date> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: DATE, dir: BIND_OUT },
                { name: 'p_indicator_id', type: STRING, value: indicatorId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_calculated.getCalculatedLastChangeDate', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getRequiredLinesForWorkbook
     *********************************************************************************************/
    public async getRequiredLinesForWorkbook(workbookId: string, roundSid: number): Promise<ILine[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_workbook_id', type: STRING, value: workbookId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getRequiredLinesForWorkbook', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getGridLinesWithCountryDeskValues
     *********************************************************************************************/
    public async getGridLinesWithCountryDeskValues(roundSid: number, countryId: string, lineIds: string[]
    ): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_line_ids', type: STRING, value: lineIds },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getGridLinesForLinkedTables', options)
        return dbResult.o_cur && dbResult.o_cur.length > 0 ? dbResult.o_cur.map(val => val.LINE_ID) : null
    }

    /**********************************************************************************************
     * @method getScpLatestRoundSid
     *********************************************************************************************/
    public async getScpLatestRoundSid(roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: 'SCP' },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getLatestApplicationRound', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getYearsRange
     *********************************************************************************************/
    public async getYearsRange(appId: EApps): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getYearsRange', options)
        return dbResult.o_res
    }
}
