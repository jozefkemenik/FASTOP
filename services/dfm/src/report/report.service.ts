import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { ICountryMultipliers, IDBESACode, IGDPPonderation, config } from '../../../lib/dist/measure'
import { DataAccessApi } from '../../../lib/dist/api'
import { sumTotalImpact } from '../../../shared-lib/dist/dxm-report'

import {
    IAdditionalImpact,
    IAdditionalImpactData,
    IAdditionalImpactParams,
    IAdditionalImpactReport,
    IDBAdditionalImpact,
    IDBReportMeasure,
    IImpactParams,
    ITransferMatrixRecord
} from '.'
import { IDBOverview } from '../config'
import { SharedService } from '../shared/shared.service'

export class ReportService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private sharedService: SharedService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAdditionalImpactAll
     *********************************************************************************************/
    public async getAdditionalImpactAll(
        gdp: IGDPPonderation,
        { archive, countryId, filter }: IAdditionalImpactParams,
        forExcel = false,
    ): Promise<IAdditionalImpactData[]> {
        const descr = ['Impact on budget balance', 'Impact on total expenditure', 'Impact on total revenue']

        const data: IDBAdditionalImpact[] = await this.sharedService.getReportData(
            'dfm_reports.getAdditionalImpactAll', countryId, true, archive, filter
        )
        const dataInArray: IAdditionalImpact[] = await this.sharedService.dataToArray(
            data, config, gdp
            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        ) as any

        return this.toArrayWithTotals(dataInArray, descr, forExcel)
    }

    /**********************************************************************************************
     * @method getAdditionalImpactOneOff
     *********************************************************************************************/
    public async getAdditionalImpactOneOff(
        gdp: IGDPPonderation,
        { archive, countryId, filter }: IAdditionalImpactParams,
        forExcel = false,
    ): Promise<IAdditionalImpactData[]> {
        const descr = ['Total one-off Impact', 'One-off expenditure', 'One-off revenue']

        const data: IDBAdditionalImpact[] = await this.sharedService.getReportData(
            'dfm_reports.getAdditionalImpactOO', countryId, true, archive, filter
        )
        const dataInArray: IAdditionalImpact[] = await this.sharedService.dataToArray(
            data, config, gdp
            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        ) as any

        return this.toArrayWithTotals(dataInArray, descr, forExcel)
    }

    public async getImpact(gdp: IGDPPonderation, params: IImpactParams): Promise<IAdditionalImpactData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_adopt_years', type: NUMBER, value: params.filter?.yearAdoption || [] },
                { name: 'p_adopt_months', type: NUMBER, value: params.filter?.monthAdoption || [] },
                { name: 'p_label_sids', type: NUMBER, value: params.filter?.labels || [] },
                { name: 'p_is_eu_funded_sids', type: NUMBER, value: params.filter?.isEuFunded || [] },
                { name: 'p_country_id', type: STRING, value: params.countryId }
            ]
        }
        let descr: string[], dbProc: string

        if (params.groupBy === 'OO') {
            descr = ['Total one-off Impact', 'One-off expenditure', 'One-off revenue']   
            dbProc = 'dfm_reports.getAdditionalImpactOO'       
        } else {
            descr = ['Impact on budget balance', 'Impact on total expenditure', 'Impact on total revenue']
            if (params.filter?.oneOff?.length > 0) {
                options.params.push({ name: 'p_one_off_sid', type: NUMBER, value: params.filter?.oneOff[0] })
            }
            dbProc = 'dfm_reports.getAdditionalImpactAll'
        }
        
        const dbResult = await DataAccessApi.execSP(dbProc, options)

        const dataInArray: IAdditionalImpact[] = await this.sharedService.dataToArray(
            dbResult.o_cur, config, gdp
            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        ) as any

        return this.toArrayWithTotals(dataInArray, descr, true)
          
    }

    /**********************************************************************************************
     * @method getTransferMatrixRecords
     *********************************************************************************************/
    public async getTransferMatrixRecords(
        params: IAdditionalImpactParams, addImpactReport: IAdditionalImpactReport
    ): Promise<ITransferMatrixRecord[]> {

        addImpactReport.oneOff.forEach((data) => {
            sumTotalImpact(data.values, true, params.gdp, config.startYear - addImpactReport.startYear,
                (newValue, index) => data[addImpactReport.startYear + index] = newValue)
        })
        // Do not take the multi overviews because they need specific process! (see getMultiEsaOverviewTransferMatrixRecords)
        const matrixParams = await Promise.all([this.getOverviews(), this.getEsaOverviews(), this.getEsaMultiOverviews()])
            .then( ([overviews, esaOverviews, esaMultiOverviews]) => {
                return {
                    overviews: overviews.filter(
                        o => !esaMultiOverviews.map(o => o.OVERVIEW_SID).includes(o.OVERVIEW_SID),
                    ),
                    esaOverviews,
                }
            })
        return matrixParams.overviews.map(overview => {
            return this.processTransferMatrixRecord(overview, addImpactReport, params.countryId, matrixParams.esaOverviews)
        })
    }

    /**********************************************************************************************
     * @method getMultiEsaOverviewTransferMatrixRecords
     *********************************************************************************************/
        public async getMultiEsaOverviewTransferMatrixRecords(
            params: IAdditionalImpactParams, addImpactReport: IAdditionalImpactReport
        ): Promise<ITransferMatrixRecord[]> {
    
            // Get total impact
            addImpactReport.all.forEach( (measure) => {
                const totalValues = []
                sumTotalImpact(
                    measure.values,
                    false,
                    params.gdp,
                    config.startYear - addImpactReport.startYear,
                    (newValue,) => totalValues.push(newValue)
                )
                measure.values = totalValues
            })
            // Get Overviews for multi only
            const matrixParams = await Promise.all([this.getOverviews(), this.getEsaMultiOverviews()])
                .then( ([overviews, esaOverviews]) => {
                    return {
                        overviews: overviews.filter(o =>
                            esaOverviews.map(o => o.OVERVIEW_SID).includes(o.OVERVIEW_SID),
                        ),
                        esaOverviews,
                    }
                })
            return matrixParams.overviews.map(overview => {
                return this.processTransferMatrixRecord(overview, addImpactReport, params.countryId, matrixParams.esaOverviews)
            })
        }

    /**********************************************************************************************
     * @method getEUCountries
     *********************************************************************************************/
    public async getEUCountries(): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_group_id', type: STRING, value: 'EU' },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getCountryGroupCountries', options)
        return dbResult.o_cur.map(data => data.COUNTRY_ID)
    }

    /**********************************************************************************************
     * @method getReportMeasures
     *********************************************************************************************/
    public async getReportMeasures(countryId: string): Promise<IDBReportMeasure[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_reports.getReportMeasures', options)
        return dbResult.o_cur
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSubtotalRows
     *********************************************************************************************/
    private getSubtotalRows(code: number, descr: string, totalRevExp: ITotalRevExp): IRow[] {
        const rows: IRow[] = []
        Object.getOwnPropertyNames(totalRevExp).forEach(country => {
            const newRow: IRow = {
                code, descr, country: totalRevExp[country].country, values: totalRevExp[country].data
            }

            // for excel add more keys
            if (totalRevExp[country].scale) {
                newRow.country_id = totalRevExp[country].country_id
                newRow.scale = totalRevExp[country].scale
                newRow.series = totalRevExp[country].series
                newRow.rev_exp = totalRevExp[country].rev_exp
            }
            rows.push(newRow)
        })

        return rows.sort((a, b) => {
            const countryA = a.country.toUpperCase()
            const countryB = b.country.toUpperCase()
            return countryA > countryB ? 1 : countryA < countryB ? -1 : 0
        })
    }

    /**********************************************************************************************
     * @method getTotalRows
     *********************************************************************************************/
    private getTotalRows(descr: string, totals: ITotals) {
        const KEY_FACTOR = [-1, 1]
        const countries: ITotalRevExp = {}

        Object.getOwnPropertyNames(totals).forEach(revExp => {
            Object.getOwnPropertyNames(totals[revExp]).forEach(country => {
                if (countries[country] === undefined) {
                    countries[country] = {
                        country: totals[revExp][country].country,
                        data: Array.from({length: config.yearsCount}, () => 0),
                    }
                    // for excel add more keys
                    if (totals[revExp][country].scale) {
                        countries[country].country_id = totals[revExp][country].country_id
                        countries[country].scale = totals[revExp][country].scale
                        countries[country].series = totals[revExp][country].series
                        countries[country].rev_exp = totals[revExp][country].rev_exp
                    }
                }

                totals[revExp][country].data.forEach(
                    (value, idx) => countries[country].data[idx] += KEY_FACTOR[+revExp - 1] * value
                )
            })
        })

        return this.getSubtotalRows(0, descr, countries)
    }

    /**********************************************************************************************
     * @method toArrayWithTotals
     *********************************************************************************************/
    private async toArrayWithTotals(
        calculated: IAdditionalImpact[],
        descr: string[],
        forExcel = false,
    ): Promise<IAdditionalImpactData[]> {
        let rows = []
        const totals: ITotals = {}

        if (!calculated.length) return rows
        let currentRevExp = calculated[0].REV_EXP_SID

        let countryMultipliers: ICountryMultipliers
        if (forExcel) countryMultipliers = await this.sharedService.getCountryMultipliers()

        calculated.forEach(row => {
            if (row.REV_EXP_SID !== currentRevExp) {
                // add totals for this rev exp
                rows = rows.concat(
                    this.getSubtotalRows(1000 + currentRevExp, descr[currentRevExp], totals[currentRevExp])
                )
                currentRevExp = row.REV_EXP_SID
            }

            // make sure currentRevExp exists in totals
            totals[currentRevExp] = totals[currentRevExp] || {}

            if (totals[currentRevExp][row.COUNTRY_ID] === undefined) {
                // create entry for this country in totals
                totals[currentRevExp][row.COUNTRY_ID] = {
                    country: row.COUNTRY,
                    data: Array.from({length: config.yearsCount}, () => 0)
                }
                if (forExcel) {
                    totals[currentRevExp][row.COUNTRY_ID].country_id = row.COUNTRY_ID
                    totals[currentRevExp][row.COUNTRY_ID].scale = countryMultipliers[row.COUNTRY_ID].scale
                    totals[currentRevExp][row.COUNTRY_ID].series = ''
                    totals[currentRevExp][row.COUNTRY_ID].rev_exp = currentRevExp
                }
            }
            // add current row data to totals
            row.DATA.forEach((value, idx) => totals[currentRevExp][row.COUNTRY_ID].data[idx] += value)

            const newRow: IRow = {
                code: row.TYPE_SID,
                descr: row.DESCR,
                country: row.COUNTRY,
                values: row.DATA,
            }
            if (forExcel) {
                newRow.country_id = row.COUNTRY_ID
                newRow.scale = countryMultipliers[row.COUNTRY_ID].scale
                newRow.series = row.SERIES
                newRow.rev_exp = row.REV_EXP_SID
            }

            rows.push(newRow)
        })

        if (calculated.length) {
            rows = rows.concat(this.getSubtotalRows(1000 + currentRevExp, descr[currentRevExp], totals[currentRevExp]))
            rows = rows.concat(this.getTotalRows(descr[0], totals))
        }

        return rows
    }

    /**********************************************************************************************
     * @method getOverviews
     *********************************************************************************************/
    private async getOverviews(): Promise<IDBOverview[]> {
        return this.sharedService.getDBOverviews().then(overviews => overviews.filter(o => o.OVERVIEW_SID > 0))
    }

    /**********************************************************************************************
     * @method getEsaOverviews
     *********************************************************************************************/
    private async getEsaOverviews(): Promise<IDBESACode[]> {
        return this.sharedService.getDBEsaCodes().then(esaCodes => esaCodes.filter(e => e.ESA_SID > 0))
    }

    /**********************************************************************************************
     * @method getEsaMultiOverviews
     *********************************************************************************************/
    private async getEsaMultiOverviews(): Promise<IDBESACode[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_getters.getEsaMultiOverviews', options)

        return dbResult.o_cur;
    }

    /**********************************************************************************************
     * @method sumVectors
     *********************************************************************************************/
    private sumVectors(vectors: number[][]): number[] {
        return vectors.reduce(
            (acc, value) => acc.map((v, index) => v + value[index]),
            Array(vectors[0].length).fill(0)
        )
    }

    /**********************************************************************************************
     * @method getImpactVector
     *********************************************************************************************/
    private getImpactVector(impact: IAdditionalImpactData, years: number[]): number[] {
        return years.map(y => impact[y])
    }

    /**********************************************************************************************
     * @method processTransferMatrixRecord
     *********************************************************************************************/
    private processTransferMatrixRecord(
        overview: IDBOverview, 
        addImpactReport: IAdditionalImpactReport, 
        countryId: string, 
        esaOverviews: IDBESACode[]
    ): ITransferMatrixRecord {
        // Build Record
        const result: ITransferMatrixRecord = {
            countryId: countryId,
            overviewSid: overview.OVERVIEW_SID,
            overviewDesc: overview.DESCR,
            overviewCodes: overview.CODES?.split(','),
            orderBy: overview.ORDER_BY,
            startYear: addImpactReport.startYear,
            vector: Array.from({length: addImpactReport.yearsCount}, () => 0),
        }
        const years = Array.from({ length: addImpactReport.yearsCount }, (v, k) => k + addImpactReport.startYear)
        
        // Depending on OPERATOR, calculate the vector values
        switch (overview.OPERATOR) {
            case 'SUM':
            case 'SUM-': {
                const esaSids: number[] = esaOverviews
                    .filter(e => e.OVERVIEW_SID === overview.OVERVIEW_SID)
                    .map(e => e.ESA_SID)
                const impacts = addImpactReport.all.filter(i => esaSids.includes(i.code))
                if (impacts.length) {
                    result.vector = this.sumVectors(impacts.map(i => i.values))
                }
                // when SUM of expenditure, change sign
                if (overview.OPERATOR === 'SUM-') {
                    result.vector = result.vector.map(v => -1 * v)
                }
                break
            }
            case '+': {
                const oneOffRevenue = addImpactReport.oneOff.find(o => o.code === 1002)
                if (oneOffRevenue) {
                    result.vector = this.getImpactVector(oneOffRevenue, years)
                }
                break
            }
            case '-': {
                const oneOffExpenditure = addImpactReport.oneOff.find(o => o.code === 1001)
                if (oneOffExpenditure) {
                    result.vector = this.getImpactVector(oneOffExpenditure, years).map(v => -1 * v)
                }
                break
            }
        }
        return result
    }
}

interface IForExcel {
    country_id?: string
    scale?: string
    series?: string
    rev_exp?: number
}

interface IRow extends IForExcel {
    code: number
    descr: string
    country: string
    values: number[]
}

interface ITotalRevExpCountry extends IForExcel {
    country: string
    data: number[]
}

interface ITotalRevExp {
    [countryId: string]: ITotalRevExpCountry
}

interface ITotals {
    [revExp: number]: ITotalRevExp
}
