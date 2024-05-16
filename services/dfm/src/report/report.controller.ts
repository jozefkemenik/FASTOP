import { ICountryMultipliers, IGDPPonderation, config, excelConfig } from '../../../lib/dist/measure'
import { IWQIndicator, IWQIndicators } from '../../../web-queries/src/shared/shared-interfaces'
import { IError } from '../../../lib/dist'

import {
    IAdditionalImpactParams,
    IAdditionalImpactReport,
    IDetailedReport,
    IFilteredTransferMatrix,
    IImpactParams,
    IImpactReport,
    IReportMeasure,
    ITransferMatrixRecord,
    ITransferMatrixReport
} from '.'
import { ReportService } from './report.service'
import { SharedService } from '../shared/shared.service'
import { sumTotalImpact } from '../../../shared-lib/dist/dxm-report'

export class ReportController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////// Static variables /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////


    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _excludeYes$: Promise<number[]>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly reportService: ReportService,
        private readonly sharedService: SharedService,
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private get excludeYes$(): Promise<number[]> {
        if (!this._excludeYes$) {
            this._excludeYes$ = this.sharedService.getOneOff().then(
                oneOff => Object.entries(oneOff)
                    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
                    .filter(([_, descr]) => descr !== 'Yes')
                    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
                    .map(([sid, _]) => Number(sid))
            )
        }
        return this._excludeYes$
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAdditionalImpact
     *********************************************************************************************/
    public async getAdditionalImpact(
        params: IAdditionalImpactParams, forExcel = false
    ): Promise<IAdditionalImpactReport> {
        const gdpPonderation: IGDPPonderation = params.gdp
            ? await this.sharedService.getGDPPonderation(params.countryId)
            : undefined

        const reports = await Promise.all([
            this.reportService.getAdditionalImpactAll(
                gdpPonderation, params, forExcel
            ),
            this.reportService.getAdditionalImpactOneOff(
                gdpPonderation, params, forExcel
            ),
        ]).catch((err: IError) => {
            err.method = 'ReportController.getAdditionalImpact'
            throw err
        })

        return {
            startYear: config.startYear,
            yearsCount: config.yearsCount,
            all: reports[0],
            oneOff: reports[1],
            excelRange: forExcel ? excelConfig : undefined
        }
    }

    /**********************************************************************************************
     * @method getTotalImpact
     * Data is the same as for additional impact. Sum is calculated on client side.
     *********************************************************************************************/
    public async getTotalImpact(
        params: IAdditionalImpactParams, forExcel = false
    ): Promise<IAdditionalImpactReport> {
        return this.getAdditionalImpact(params, forExcel)
    }

    /**********************************************************************************************
     * @method getImpact
     *********************************************************************************************/
    public async getImpact(params: IImpactParams): Promise<IImpactReport> {
        const gdpPonderation: IGDPPonderation = params.gdp
            ? await this.sharedService.getGDPPonderation(params.countryId)
            : undefined

        const report = await this.reportService.getImpact(gdpPonderation, params).catch((err: IError) => {
            err.method = 'ReportController.getImpact'
            throw err
        })

        return {
            startYear: config.startYear,
            yearsCount: config.yearsCount,
            all: report,
        }
    }


    /**********************************************************************************************
     * @method getFdmsMeasures
     *********************************************************************************************/
    public async getFdmsMeasures(
        countryIds: string[], params: IAdditionalImpactParams
    ): Promise<Array<[string, string, string, number, string]>> {
        const countryMultipliers: ICountryMultipliers = await this.sharedService.getCountryMultipliers()

        const mapRecord = (includeEuFunded: boolean) =>
            ({countryId, startYear, overviewCodes, vector}: ITransferMatrixRecord) => ([
                countryId,
                overviewCodes[Number(includeEuFunded)] + '.1.0.0.0',
                countryMultipliers[countryId]?.scale,
                startYear,
                vector.join(','),
            ])

        return [].concat(...await Promise.all(countryIds.map(countryId =>
            this.getFilteredTransferMatrix({...params, countryId}).then(
                ({withoutEuFunded, all}) => all.map(mapRecord(true)).concat(withoutEuFunded.map(mapRecord(false)))
            )
        )))
    }

    /**********************************************************************************************
     * @method getCountryTransferMatrix
     *********************************************************************************************/
    public async getCountryTransferMatrix(params: IAdditionalImpactParams): Promise<ITransferMatrixReport> {
        const {indicators, ...rest} = await this.getCountryWqTransferMatrix(params, false)
        return {withoutEuFunded: indicators, ...rest}
    }

    /**********************************************************************************************
     * @method getCountryWqTransferMatrix
     *********************************************************************************************/
    public async getCountryWqTransferMatrix(
        params: IAdditionalImpactParams, mergeRecords = true,
    ): Promise<IWQIndicators & {all: IWQIndicator[]}> {
        const [meta, data] = await Promise.all([
            this.getWQIndicatorsMetaData(params.countryId),
            this.getFilteredTransferMatrix(params),
        ])
        const mapRecord = (includingEuFunded: boolean) =>
            (xferRecord: ITransferMatrixRecord) => ({
                indicatorId: '1.0.0.0.' + xferRecord.overviewCodes[Number(includingEuFunded)] + '.A',
                descr: `${xferRecord.overviewDesc} - ${includingEuFunded ? 'incl.' : 'excl.'} EU financed`,
                vector: this.normalizeVector(xferRecord.startYear, xferRecord.vector, meta.startYear, meta.yearsCount),
            })

        const indicators = data.withoutEuFunded.map(mapRecord(false))
        const all = data.all.map(mapRecord(true))
        const records = mergeRecords
            ? {indicators: indicators.concat(all), all: undefined}
            : {indicators, all}           
        return {...meta, ...records}
    }

    /**********************************************************************************************
     * @method getCountryWqAdditionalImpact
     *********************************************************************************************/
    public async getCountryWqAdditionalImpact(params: IAdditionalImpactParams): Promise<IWQIndicators> {
        const [meta, esaCodes, data] = await Promise.all([
            this.getWQIndicatorsMetaData(params.countryId),
            this.sharedService.getESACodes(0),
            this.getAdditionalImpact(params),
        ])

        const indicators = data.all
            .filter(row => esaCodes[row.code])
            .map(row => ({
                indicatorId: esaCodes[row.code].id,
                descr: row.descr,
                vector: this.normalizeVector(data.startYear, row.values, meta.startYear, meta.yearsCount),
            }))
        return {...meta, indicators}
    }

    /**********************************************************************************************
     * @method getWqImpact
     *********************************************************************************************/
    public async getWqImpact(params: IImpactParams): Promise<IWQIndicators> {
        const [meta, data] = await Promise.all([
            this.getWQIndicatorsMetaData(params.countryId),
            this.getImpact(params),
        ])

        // By default base year = 2010
        let baseYear = 2010
        if (params.baseYear > 0) {
            baseYear = params.baseYear
        }
        // Recalculate yearsCount and startYear with baseYear
        meta.yearsCount = meta.yearsCount + (meta.startYear - baseYear)
        meta.startYear = baseYear

        // Force oneOff filter when group by OO
        if (params.groupBy === 'OO') {
            params.filter.oneOff = [1]
        }

        // Calculate totalImpact 
        if (params.isTotalImpact) {
            data.all.forEach( (measure) => {
                const totalValues = []
                sumTotalImpact(
                    measure.values,
                    params.filter?.oneOff?.includes(1),
                    params.gdp,
                    baseYear - data.startYear,
                    (newValue,) => totalValues.push(newValue)
                )
                measure.values = totalValues
            })
        }
        // Group by One-Off type
        if (params.groupBy === 'OO') {
            const indicators = data.all
                .map(row => ({ 
                    indicatorId: row.code.toString(),
                    descr: row.descr,
                    vector: this.normalizeVector(data.startYear, row.values, meta.startYear, meta.yearsCount),
                    aggregationType: params.groupBy,                   
                    country: row.country,
                    countryId: row.country_id,
                    isTotalImpact: params.isTotalImpact,
                    isOneOff: params.filter?.oneOff?.includes(1),
                    isEuFunded: !params.filter?.isEuFunded?.includes(2),
                    isExpenditure: (row.rev_exp === 1)
                }))
            return {...meta, indicators}
        }
        // Group by ESA 
        if (params.groupBy === 'ESA') {
            const esaCodes = await this.sharedService.getESACodes(0)
            const indicators = data.all
                .filter(row => esaCodes[row.code])
                .map(row => ({
                    indicatorId: esaCodes[row.code].id,
                    descr: row.descr,
                    vector: this.normalizeVector(data.startYear, row.values, meta.startYear, meta.yearsCount),
                    aggregationType: params.groupBy,
                    country: row.country,
                    countryId: row.country_id,
                    isTotalImpact: params.isTotalImpact,
                    isOneOff: params.filter?.oneOff?.includes(1),
                    isEuFunded: !params.filter?.isEuFunded?.includes(2),
                    isExpenditure: (row.rev_exp === 1)
                }))  
            return {...meta, indicators}          
        } else {
            throw new Error('Invalid aggregation type')
        }
    }

    
    /**********************************************************************************************
     * @method getReportMeasures
     *********************************************************************************************/
     public async getReportMeasures(params: IAdditionalImpactParams): Promise<IDetailedReport> {
        const gdpPonderation: IGDPPonderation = params.gdp
            ? await this.sharedService.getGDPPonderation(params.countryId, true)
            : undefined

        return this.reportService.getReportMeasures(params.countryId)
            .then(measures => this.sharedService.dataToArray(measures, config, gdpPonderation))
            .then((data: IReportMeasure[]) => ({ ...config, data, gdp: params.gdp }))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getFilteredTransferMatrix
     *********************************************************************************************/
    private async getFilteredTransferMatrix(params: IAdditionalImpactParams): 
    Promise<IFilteredTransferMatrix> {

        const excludeEuFunded = await this.excludeYes$
        const paramsExcludeEuFunded: IAdditionalImpactParams = 
            {...params, filter: {...params.filter, isEuFunded: excludeEuFunded}}

        const [all, withoutEuFunded] = await Promise.all([params, paramsExcludeEuFunded].map(
            p => this.getAdditionalImpact(p).then(
                report => this.reportService.getTransferMatrixRecords(p, report)
            )
        ))

        // Specific process for OO by ESA (or MultiEsaOverview)
        // Update params to have data: TOTAL impact (ONE-OFF measures included in FC) grouped by ESA
        const paramOObyESA: IImpactParams = 
            {...params, groupBy: 'ESA', isTotalImpact: true, filter: {...params.filter, oneOff: [1]}}
        // Take same but excluded in FC
        const paramOObyESAExcludeEuFunded: IImpactParams = 
            {...paramOObyESA, filter: {...paramOObyESA.filter, isEuFunded: excludeEuFunded}}

        const [allOObyESA, withoutEuFundedOObyESA] = await Promise.all(
            [paramOObyESA, paramOObyESAExcludeEuFunded].map(p =>
                this.getImpact(p).then(report =>
                    // specific process for MultiEsaOverview, no need of oneOff array in IAdditionalImpactReport
                    this.reportService.getMultiEsaOverviewTransferMatrixRecords(p, { oneOff: [], ...report })
                ),
            ),
        )
        // Add OObyESA results and sort
        return {
            all: all.concat(allOObyESA).sort((a, b) => a.orderBy - b.orderBy),
            withoutEuFunded: withoutEuFunded.concat(withoutEuFundedOObyESA).sort((a, b) => a.orderBy - b.orderBy),
        }


    }

    /**********************************************************************************************
     * @method getWQIndicatorsMetaData
     *********************************************************************************************/
    private async getWQIndicatorsMetaData(countryId: string): Promise<Omit<IWQIndicators, 'indicators'>> {
        const startYear = config.startYear + 6
        const yearsCount = config.yearsCount - 6
        const multi = await this.sharedService.getCountryMultipliers()

        return {
            countryId,
            startYear,
            yearsCount,
            scale: multi[countryId]?.scale,
        }
    }

    /**********************************************************************************************
     * @method normalizeVector
     *********************************************************************************************/
    private normalizeVector(
        vectorStartYear: number, vector: number[], newStartYear: number, newVectorLength: number,
    ): number[] {
        const result = Array.from(
            {length: vectorStartYear > newStartYear ? vectorStartYear - newStartYear: 0}, () => 0)
            .concat(vector)
            .slice(newStartYear > vectorStartYear ? newStartYear - vectorStartYear : 0)
            .slice(0, newVectorLength)

        if (newVectorLength > result.length) {
            result.concat(Array.from({length: newVectorLength - result.length}, () => 0))
        }
        return result
    }
}
