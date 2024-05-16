import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { ICountryCurrencyInfo, IDBSidType, ILibMeasureDetails, IRoundPeriod } from '..'
import { IReportFilter, IStandardReport } from '../../../../shared-lib/dist/prelib/report'
import { DataAccessApi } from '../../api/data-access.api'
import { EApps } from 'config'

import {
    IArchiveParams,
    ICountryMultipliers,
    IDBGDPPonderation,
    IDBStandardReport,
    IGDPPonderation,
    ILibDictionaries,
    IMeasuresRange,
    config
} from '.'
import { MeasureSharedConfigService } from './measure-shared-config.service'

export abstract class MeasureSharedService extends MeasureSharedConfigService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getReqArchiveParams
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static getReqArchiveParams(source: any): IArchiveParams {
        return {
            roundSid: Number(source.roundSid),
            storageSid: Number(source.storageSid),
            custTextSid: Number(source.custTextSid),
            storageId: source.storageId,
            ctyVersion: Number(source.ctyVersion),
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _countryMultipliers: ICountryMultipliers
    private _countriesInfo = {} as {[countryId: string]: ICountryCurrencyInfo}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryCurrencyInfo
     *********************************************************************************************/
    public async getCountryCurrencyInfo(
        countryId: string, roundSid: number, version: number, force = false
    ): Promise<ICountryCurrencyInfo> {
        if (force) delete this._countriesInfo[countryId]
        if (!this._countriesInfo[countryId]) {
            this._countriesInfo[countryId] = await this.fetchCountryCurrencyInfo(countryId, roundSid, version)
        }
        return this._countriesInfo[countryId]
    }

    /**********************************************************************************************
     * @method getColumnValue
     *********************************************************************************************/
    public getColumnValue(
        column: string,
        row: ILibMeasureDetails,
        dictionaries: ILibDictionaries
    ): string | number {
        switch (column) {
            case 'ESA_DESCR':
                return dictionaries.esaCodes[row.ESA_SID].descr
            case 'ESA_ID':
                return dictionaries.esaCodes[row.ESA_SID].id
            case 'ONE_OFF_DESCR':
                return dictionaries.oneOff[row.ONE_OFF_SID]
            case 'ONE_OFF_TYPE_DESCR':
                return dictionaries.oneOffTypes[row.ONE_OFF_TYPE_SID]
            case 'IS_EU_FUNDED_DESCR':
                return dictionaries.oneOff[row.IS_EU_FUNDED_SID]
            case 'EU_FUND_DESCR':
                return dictionaries.euFunds[row.EU_FUND_SID]
            case 'ADOPT_DATE_MH_DESCR':
                return dictionaries.months[row.ADOPT_DATE_MH]
            case 'LABELS_DESCR':
                return row.labelSids.map(sid => dictionaries.labels[sid]).join(', ')
            default:
                return row[column]
        }
    }

    /**********************************************************************************************
     * @method getDictionaries
     *********************************************************************************************/
    public getDictionaries(roundSid: number): Promise<ILibDictionaries> {
        roundSid = roundSid || 0
        return Promise.all([
            this.getESACodes(roundSid),
            this.getOneOff(),
            this.getOneOffTypes(roundSid),
            this.getEuFunds(),
            this.getMonths(),
            this.getLabels(),
        ]).then(
            ([esaCodes, oneOff, oneOffTypes, euFunds, months, labels]) =>
                ({esaCodes, oneOff, oneOffTypes, euFunds, months, labels})
        )
    }

    /**********************************************************************************************
     * @method getReportData
     *********************************************************************************************/
    public async getReportData(
        storedProcedure: string,
        countryId: string,
        countryIsOptional = false,
        archive?: IArchiveParams,
        filter?: IReportFilter,
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    ): Promise<any[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        if (filter) {
            options.params.push(
                { name: 'p_adopt_years', type: NUMBER, value: filter.yearAdoption || [] },
                { name: 'p_adopt_months', type: NUMBER, value: filter.monthAdoption || [] },
                { name: 'p_label_sids', type: NUMBER, value: filter.labels || [] },
                { name: 'p_is_eu_funded_sids', type: NUMBER, value: filter.isEuFunded || [] },
            )
        }

        if (countryIsOptional) {
            if (countryId !== undefined) {
                options.params.push({ name: 'p_country_id', type: STRING, value: countryId })
            }
        } else {
            options.params.unshift({ name: 'p_country_id', type: STRING, value: countryId || null })
        }

        if (archive && archive.roundSid && archive.ctyVersion) {
            options.params.push(
                { name: 'p_round_sid', type: NUMBER, value: archive.roundSid },
                { name: 'p_version', type: NUMBER, value: archive.ctyVersion },
            )
        } else if (archive && (archive.roundSid || archive.storageId)) {
            options.params.unshift(
                { name: 'p_round_sid', type: NUMBER, value: archive.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: archive.storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: archive.custTextSid },
                { name: 'p_storage_id', type: STRING, value: archive.storageId },
            )
            storedProcedure += 'Archived'
        }

        const dbResult = await DataAccessApi.execSP(storedProcedure, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method dataToArray
     *********************************************************************************************/
    public async dataToArray(
        rows: IDBStandardReport[],
        range: IMeasuresRange,
        gdp?: IGDPPonderation,
        dataWithoutGDP?: boolean,
    ): Promise<IStandardReport[]> {
        const countryMultipliers = await this.getCountryMultipliers()
        const labelsToArray = (row: IDBStandardReport): IStandardReport => {
            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
            const ret: IStandardReport = row as any
            if (row.LABEL_SIDS === undefined) return ret
            if (row.LABEL_SIDS?.length) {
                ret.labelSids = row.LABEL_SIDS.split(',').map(Number)
            } else {
                ret.labelSids = [-1]
            }
            delete row.LABEL_SIDS
            return ret
        }

        return rows.map(row => {
            row.DATA = row.DATA || ''
            let ary = row.DATA.split(',').map(Number).map(x => isNaN(x) ? 0 : x)
            const startYear = row.START_YEAR || range.startYear
            for (let i = range.startYear; i < startYear; i++) ary.unshift(0)
            while (ary.length < range.yearsCount) ary.push(0)
            ary = ary.slice(0, range.yearsCount)
            const currentRow: IStandardReport = labelsToArray(row)

            if (dataWithoutGDP) {
                currentRow.dataWithoutGDP = Array.from(ary)
            }
            if (gdp) {
                ary = this.calculateWithGDP(ary, gdp[row.COUNTRY_ID], countryMultipliers[row.COUNTRY_ID].multi)
            }
            currentRow.DATA = ary
            return currentRow
        })
    }

    /**********************************************************************************************
     * @method getCountryMultipliers
     *********************************************************************************************/
    public async getCountryMultipliers(): Promise<ICountryMultipliers> {
        if (!this._countryMultipliers) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('dfm_reports.getCountryMultiplier', options)

            this._countryMultipliers = {}
            dbResult.o_cur.forEach(row => {
                this._countryMultipliers[row.COUNTRY_ID] = { multi: row.MULTI, scale: row.SCALE }
            })
        }

        return this._countryMultipliers
    }

    /**********************************************************************************************
     * @method getGDPPonderation
     *********************************************************************************************/
    public async getGDPPonderation(
        countryId = '', withForecast = false, range: IMeasuresRange = config
    ): Promise<IGDPPonderation> {
        const gdpPonderation: IDBGDPPonderation[] = await this.getCurrentGDP(countryId, withForecast)
        const gdp = {} as IGDPPonderation
        gdpPonderation.forEach(country => {
            const vector = country.VECTOR.split(',')
            const offset = range.startYear - country.START_YEAR
            const dataStart = offset >= 0 ? 0 : 0 - offset
            const dataEnd = vector.length - offset
            const data: number[] = Array.from({ length: range.yearsCount }, () => NaN)

            for (let i = dataStart; i < range.startYear && i < dataEnd; i++) {
                if (vector[i + offset]) {
                    data[i] = Number(vector[i + offset])
                } else {
                    data[i] = NaN
                }
            }

            gdp[country.COUNTRY_ID] = data
        })

        return gdp
    }

    /**********************************************************************************************
     * @method getSingleValueGDP
     *********************************************************************************************/
    public async getSingleValueGDP(
        countryId: string,
        year: number,
        value: number,
    ): Promise<number> {
        const gdp = await this.getGDPPonderation(countryId)
        const countryMultipliers = await this.getCountryMultipliers()
        if (!gdp[countryId] || year < config.startYear) return NaN
        const gdpValue = gdp[countryId][year - config.startYear]
        return isNaN(gdpValue) ?
            NaN : ((value / countryMultipliers[countryId].multi) / gdpValue) * 100
    }

    /**********************************************************************************************
     * @method getRoundPeriod
     *********************************************************************************************/
    public async getRoundPeriod(appId: EApps, roundSid?: number): Promise<IRoundPeriod> {
        const options: ISPOptions = {
            params: [
                { name: 'o_round_sid', type: NUMBER, dir: BIND_OUT },
                { name: 'o_year', type: NUMBER, dir: BIND_OUT },
                { name: 'o_descr', type: STRING, dir: BIND_OUT },
                { name: 'o_period', type: STRING, dir: BIND_OUT },
                { name: 'o_period_id', type: STRING, dir: BIND_OUT },
                { name: 'o_version', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
            ],
        }
        if (roundSid) {
            options.params.push({ name: 'p_round_sid', type: NUMBER, value: roundSid })
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getRoundInfo', options)
        return {
            roundSid: Number(dbResult.o_round_sid),
            year: Number(dbResult.o_year),
            periodId: dbResult.o_period_id,
        }
    }

    /**********************************************************************************************
     * @method getDbpScale
     *********************************************************************************************/
    public async getDbpScale(countryId: string, roundSid: number): Promise<IDBSidType> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'p_version', type: NUMBER, dir: BIND_IN },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'o_scale_sid', type: STRING, dir: BIND_OUT },
                { name: 'o_scale_descr', type: STRING, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dbp_getters.getScale', options)
        return (!dbResult || !dbResult.o_scale_sid) ? undefined : {
            SID: Number(dbResult.o_scale_sid),
            DESCRIPTION: dbResult.o_scale_descr
        }
    }

    /**********************************************************************************************
     * @method getDrmScale
     *********************************************************************************************/
    public async getDrmScale(countryId: string): Promise<IDBSidType> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'o_scale_sid', type: STRING, dir: BIND_OUT },
                { name: 'o_scale_descr', type: STRING, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('drm_getters.getScale', options)
        return (!dbResult || !dbResult.o_scale_sid) ? undefined : {
            SID: Number(dbResult.o_scale_sid),
            DESCRIPTION: dbResult.o_scale_descr
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fetchCountryCurrencyInfo
     *********************************************************************************************/
    protected abstract fetchCountryCurrencyInfo(
        countryId: string, roundSid: number, version: number
    ): Promise<ICountryCurrencyInfo>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateWithGDP
     *********************************************************************************************/
    private calculateWithGDP = (values: number[], gdpYears: number[], multi: number) => {
        return values.map((value, idx) => {
            if (isNaN(gdpYears?.[idx])) {
                return value ? NaN : value
            } else {
                return ((value / multi) / gdpYears[idx]) * 100
            }
        })
    }

    /**********************************************************************************************
     * @method getCurrentGDP
     *********************************************************************************************/
     private async getCurrentGDP(countryId: string, withForecast: boolean): Promise<IDBGDPPonderation[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId || null },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_with_forecast', type: NUMBER, value: Number(withForecast) },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_getters.getCurrentGDP', options)
        return dbResult.o_cur
    }
}
