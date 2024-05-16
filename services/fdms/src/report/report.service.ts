import { Workbook } from 'exceljs'

import {
    AmecoXferType,
    IBudgReport,
    ICompressedData,
    IIndicatorData,
    IIndicatorScale,
    IIndicatorTreeNode,
    IXferAmeco,
} from './shared-interfaces'
import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { CacheMap, IPoiCellValue, IPoiWorksheetData, PoiActionType, VectorService } from '../../../lib/dist'
import { DashboardApi, DataAccessApi } from '../../../lib/dist/api'
import {
    IBudgIndicator,
    ICtyScale,
    IDBDetailedTable,
    IDBIndicatorData,
    IDBIndicatorReport,
    IDBIndicatorScale,
    IDBProvider,
    IDBTableCol,
    IDBTableLine,
} from '.'
import { ICountry, IDBCountry } from '../../../lib/dist/menu'
import { EApps } from 'config'
import { IArchivedRoundInfo } from 'dashboard/src/config/shared-interfaces'
import { IAttachment } from 'notification'
import { SharedService } from '../shared/shared.service'


export class ReportService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static DT_ANNUAL_START_YEAR = 2010
    private static DT_QUARTERLY_START_YEAR = 2019
    private static CT_ANNUAL_START_YEAR = 2000

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _baseYear = new CacheMap<number, number>()
    private _detailedTables: IDBDetailedTable[]
    private _tableCols = new CacheMap<number, IDBTableCol[]>()
    private _tableIndicators = new CacheMap<number, Array<[string, string[]]>>()
    private _tableLines = new CacheMap<number, IDBTableLine[]>()
    private _tableFooter = new CacheMap<number, string>()
    private _ctyScales = new CacheMap<string, ICtyScale>()
    private _providers: IDBProvider[]
    private _indicator_countries: IDBCountry[]
    private _providerDataLocation = new CacheMap<string, string>()
    private _reportIndicators = new CacheMap<string, IDBIndicatorReport[]>()
    private _indicatorNames = new CacheMap<string, string>(1000)
    private _indicatorsTree: IIndicatorTreeNode[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly sharedService: SharedService
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorsScales
     *********************************************************************************************/
    public async getIndicatorsScales(
        provider: string, periodicity: string, countries: string[], indicators: string[],
    ): Promise<IDBIndicatorScale[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, value: provider },
                { name: 'p_periodicity_id', type: STRING, value: periodicity },
                { name: 'p_indicator_ids', type: STRING, value: indicators },
                { name: 'p_country_ids', type: STRING, value: countries },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_indicator.getIndicatorScales', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getBaseYear
     *********************************************************************************************/
    public async getBaseYear(roundSid?: number): Promise<number> {
        if (!roundSid || !this._baseYear.has(roundSid)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                    { name: 'o_year', type: NUMBER, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_detailed_table.getBaseYear', options)
            this._baseYear.set(roundSid, dbResult.o_year)
        }
        return this._baseYear.get(roundSid)
    }

    /**********************************************************************************************
     * @method getCountryTableData
     *********************************************************************************************/
    public async getCountryTableData(
        countryIds: string[], ogFull?: boolean, roundSid?: number, storageSid?: number, custTextSid?: number,
    ): Promise<IDBIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_ids', type: STRING, value: countryIds ?? [] },
                { name: 'p_og_full', type: NUMBER, value: ogFull ? 1 : null },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
                { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_indicator.getCountryTableData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCtyScale
     *********************************************************************************************/
    public async getCtyScale(countryId: string): Promise<ICtyScale> {
        if (!this._ctyScales.has(countryId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_country_id', type: STRING, value: countryId },
                    { name: 'o_scale_id', type: STRING, dir: BIND_OUT },
                    { name: 'o_descr', type: STRING, dir: BIND_OUT },
                    { name: 'o_exponent', type: NUMBER, dir: BIND_OUT },
                ],
            }
            const {o_scale_id, o_descr, o_exponent} =
                await DataAccessApi.execSP('fdms_getters.getCtyScale', options)
            this._ctyScales.set(countryId, {
                id: o_scale_id,
                name: o_descr,
                exponent: o_exponent
            })
        }
        return this._ctyScales.get(countryId)
    }

    /**********************************************************************************************
     * @method getDetailedTables
     *********************************************************************************************/
    public async getDetailedTables(): Promise<IDBDetailedTable[]> {
        if (!this._detailedTables) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_detailed_table.getTables', options)
            this._detailedTables = dbResult.o_cur
        }
        return this._detailedTables
    }

    /**********************************************************************************************
     * @method getDetailedTablesData
     *********************************************************************************************/
    public async getDetailedTablesData(
        countryIds: string[],
        periodicity = 'A',
        ogFull?: boolean,
        roundSid?: number,
        storageSid?: number,
        custTextSid?: number,
    ): Promise<IDBIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_ids', type: STRING, value: countryIds ?? [] },
                { name: 'p_og_full', type: NUMBER, value: ogFull ? 1 : null },
                { name: 'p_periodicity_id', type: STRING, value: periodicity },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
                { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_indicator.getDetailedTablesData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndicatorNames
     *********************************************************************************************/
    public async getIndicatorNames(indicatorIds: string[]): Promise<Record<string, string>> {
        const missing = indicatorIds.filter(indicatorId => !this._indicatorNames.has(indicatorId))
        if (missing.length) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_indicator_ids', type: STRING, value: missing },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
                arrayFormat: true,
            }
            const dbResult = await DataAccessApi.execSP('fdms_indicator.getIndicatorNames', options)
            for (const [id, name] of dbResult.o_cur) this._indicatorNames.set(id, name)
        }
        return Object.fromEntries(this._indicatorNames)
    }

    /**********************************************************************************************
     * @method getReportIndicators
     *********************************************************************************************/
    public async getReportIndicators(reportId: string): Promise<IDBIndicatorReport[]> {
        if (!this._reportIndicators.has(reportId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_report_id', type: STRING, value: reportId },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_indicator.getReportIndicators', options)
            this._reportIndicators.set(reportId, dbResult.o_cur)
        }
        return this._reportIndicators.get(reportId)
    }

    /**********************************************************************************************
     * @method getProviders
     *********************************************************************************************/
    public async getProviders(): Promise<IDBProvider[]> {
        if (!this._providers) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                    { name: 'p_app_id', type: STRING, value: this.appId },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getProviders', options)
            this._providers = dbResult.o_cur
        }
        return this._providers
    }

    /**********************************************************************************************
     * @method getProviderDataLocation
     *********************************************************************************************/
    public async getProviderDataLocation(providerId: string): Promise<string> {
        if (!this._providerDataLocation.has(providerId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_provider_id', type: STRING, value: providerId },
                    { name: 'o_res', type: STRING, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getProviderDataLocation', options)
            this._providerDataLocation.set(providerId, dbResult.o_res)
        }
        return this._providerDataLocation.get(providerId)
    }

    /**********************************************************************************************
     * @method getTableCols
     *********************************************************************************************/
    public async getTableCols(tableSid: number): Promise<IDBTableCol[]> {
        if (!this._tableCols.has(tableSid)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_table_sid', type: NUMBER, value: tableSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_detailed_table.getTableCols', options)
            this._tableCols.set(tableSid, dbResult.o_cur)
        }
        return this._tableCols.get(tableSid)
    }

    /**********************************************************************************************
     * @method getTableFooter
     *********************************************************************************************/
    public async getTableFooter(tableSid: number): Promise<string> {
        if (!this._tableFooter.has(tableSid)) {
            const tables = await this.getDetailedTables()
            this._tableFooter.set(tableSid, tables.find(table => table.TABLE_SID === tableSid)?.FOOTER ?? undefined)
        }
        return this._tableFooter.get(tableSid)
    }

    /**********************************************************************************************
     * @method getTableIndicators
     *********************************************************************************************/
    public async getTableIndicators(tableSid: number): Promise<Array<[string, string[]]>> {
        if (!this._tableIndicators.has(tableSid)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_table_sid', type: NUMBER, value: tableSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
                arrayFormat: true,
            }
            const dbResult = await DataAccessApi.execSP('fdms_detailed_table.getTableIndicators', options)
            this._tableIndicators.set(tableSid, this.formatTableIndicators(dbResult.o_cur))
        }
        return this._tableIndicators.get(tableSid)
    }

    /**********************************************************************************************
     * @method getTableLines
     *********************************************************************************************/
    public async getTableLines(tableSid: number): Promise<IDBTableLine[]> {
        if (!this._tableLines.has(tableSid)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_table_sid', type: NUMBER, value: tableSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_detailed_table.getTableLines', options)
            this._tableLines.set(tableSid, dbResult.o_cur)
        }
        return this._tableLines.get(tableSid)
    }

    /**********************************************************************************************
     * @method getIndicatorCountries
     *********************************************************************************************/
    public async getIndicatorCountries(): Promise<IDBCountry[]> {
        if (!this._indicator_countries) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_app_id', type: STRING, value: this.appId },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getIndicatorGeoAreas', options)
            this._indicator_countries = dbResult.o_cur
        }
        return this._indicator_countries
    }

    /**********************************************************************************************
     * @method getIndicatorsTree
     *********************************************************************************************/
    public async getIndicatorsTree(): Promise<IIndicatorTreeNode[]> {
        if (!this._indicatorsTree) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('fdms_getters.getIndicatorsTree', options)
            this._indicatorsTree = dbResult.o_cur
        }
        return this._indicatorsTree
    }

    /**********************************************************************************************
     * @method getAmecoXferFile
     *********************************************************************************************/
    public async getAmecoXferFile(xferType: AmecoXferType): Promise<IAttachment> {
        const fileType = xferType === AmecoXferType.CF ? 'CF' :
            (xferType === AmecoXferType.BRICS ? 'BRICS' : undefined)

        return this.getXferAmeco(xferType)
            .then(xferAmeco => this.convertAmecoXferToExcel(xferAmeco))
            .then(buffer => ({
                filename: `AMECO_${fileType}_desk_transfer.xlsx`,
                contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                raw: buffer,
            }))
    }

    /**********************************************************************************************
     * @method getBudgetReport
     *********************************************************************************************/
    public async getBudgetReport(convertUnits = false): Promise<IBudgReport[]> {
        const [codes, countries] = await Promise.all([
            this.getReportIndicators('BUDG'),
            this.getCountryGroupCountries('BUDG'),
        ])

        const periodicity = 'A'
        const indicatorIds = codes.map(code => code.INDICATOR_ID)
        const data: IIndicatorData[] = countries.length
            ? await this.getProviderData(
                'PRE_PROD', countries, indicatorIds, periodicity
            ) as IIndicatorData[] : []

        if (convertUnits) await this.convertUnits(data, 'BUDG', periodicity, indicatorIds, countries)
        const dataMap: Map<string, IBudgIndicator> = this.prepareBudgIndicatorMap(data)

        return codes.map(code => {
            const budgInd: IBudgIndicator = dataMap.get(code.INDICATOR_ID)
            return {
                indicatorId: code.INDICATOR_ID,
                descr: code.INDICATOR_DESCR,
                startYear: budgInd?.startYear || 1960,
                endYear: budgInd?.endYear || new Date().getFullYear() + 1,
                data: countries
                    .filter(
                        cty => !(code.INDICATOR_ID === 'XNE.1.0.99.0' && ['EU27', 'EU28', 'EA19'].includes(cty))
                    ).map(country => ({
                        country,
                        scale: budgInd?.data[country]?.SCALE_DESCR,
                        vector: budgInd?.data[country]?.TIMESERIE_DATA || [],
                    }))
            }
        })
    }

    /**********************************************************************************************
     * @method getProviderData
     *********************************************************************************************/
    public async getProviderData(
        providerId: string, countryIds: string[], indicatorIds: string[],
        periodicityId: string, roundSid?: number, storageSid?: number, custTextSid?: number, compress?: boolean
    ): Promise<ICompressedData | IIndicatorData[]> {
        return this.sharedService.getCompressedIndicatorsData(
            [providerId], countryIds, indicatorIds, periodicityId, roundSid, storageSid, custTextSid, compress,
        )
    }

    /**********************************************************************************************
     * @method prepareDetailedTablesPoiRequest
     *********************************************************************************************/
    public async prepareDetailedTablesPoiRequest(
        country: ICountry, annualData: IIndicatorData[], quarterlyData: IIndicatorData[], roundInfo: IArchivedRoundInfo
    ): Promise<IPoiWorksheetData[]> {

        const dataA = this.normaliseVectors(annualData, false, ReportService.DT_ANNUAL_START_YEAR)
        const dataQ = this.normaliseVectors(quarterlyData, true, ReportService.DT_QUARTERLY_START_YEAR)
        const forecastYear = roundInfo.year + 1 + (roundInfo.periodId === 'AUT' ? 1 : 0)

        const settingsPoi: IPoiWorksheetData = {
            worksheet: 'Settings',
            cellData: [
                { cellRef: 'A4', value: { n: forecastYear } },
                { cellRef: 'J1', value: { s: country.COUNTRY_ID } },
                { cellRef: 'J4', value: { d: this.formatPoiDate(new Date()) } },
            ]
        }

        const annualPoi: IPoiWorksheetData = {
            worksheet: 'Annual data',
            tableData: [{
                cellRef: 'A2',
                data: dataA.map(row => {
                    return [
                        { s: row.INDICATOR_ID }, // Code
                        { s: row.COUNTRY_ID }, //  Country
                        { s:  `${row.COUNTRY_ID}.${row.INDICATOR_ID}` }, // Identifier
                        { s: `${this.addinKey('A', row, '//ECFIN/FDMS_PRE_PROD_CURRENT/')}` }, // #EcDatabase#
                        { s: `${this.addinKey('A', row)}` }, // Key (refreshable by add-in)
                        { s: row.INDICATOR_ID }, // Indicator (refreshable by add-in)
                        { s: row.COUNTRY_ID }, // Country (refreshable by add-in)
                        { s: roundInfo.roundDescr }, // Round (refreshable by add-in)
                        { s: roundInfo.storageDescr }, // Storage (refreshable by add-in)
                        { d: this.formatPoiDate(new Date(row.UPDATE_DATE)) }, // Last updated (refreshable by add-in)
                        { s: '' }, // Indicator name (refreshable by add-in)
                        ...this.mapVectorToPoi(row.TIMESERIE_DATA) // vector data (refreshable by add-in)
                    ]
                })
            }]
        }

        const quarterlyPoi: IPoiWorksheetData = {
            worksheet: 'Quarterly data',
            tableData: [{
                cellRef: 'A2',
                data: dataQ.map(row => {
                    return [
                        { s: row.INDICATOR_ID }, // Code
                        { s: row.COUNTRY_ID }, //  Country
                        { s:  `${row.COUNTRY_ID}.${row.INDICATOR_ID}` }, // Identifier
                        { s: `${this.addinKey('Q', row, '//ECFIN/FDMS_PRE_PROD_CURRENT/')}` }, // #EcDatabase#
                        { s: `${this.addinKey('Q', row)}` }, // Key (refreshable by add-in)
                        { s: row.INDICATOR_ID }, // Indicator (refreshable by add-in)
                        { s: row.COUNTRY_ID }, // Country (refreshable by add-in)
                        { s: roundInfo.roundDescr }, // Round (refreshable by add-in)
                        { s: roundInfo.storageDescr }, // Storage (refreshable by add-in)
                        { d: this.formatPoiDate(new Date(row.UPDATE_DATE)) }, // Last updated (refreshable by add-in)
                        { s: '' }, // Indicator name (refreshable by add-in)
                        ...this.mapVectorToPoi(row.TIMESERIE_DATA) // vector data (refreshable by add-in)
                    ]
                })
            }]
        }

        const countryPoi: IPoiWorksheetData = {
            worksheet: 'country',
            actions: [
                {
                    type: PoiActionType.RENAME,
                    newName: country.COUNTRY_ID,
                }
            ]
        }

        return [countryPoi, settingsPoi, annualPoi, quarterlyPoi]
    }


    /**********************************************************************************************
     * @method prepareCountryTablesPoiRequest
     *********************************************************************************************/
    public async prepareCountryTablesPoiRequest(
        country: ICountry, annualData: IIndicatorData[], roundInfo: IArchivedRoundInfo
    ): Promise<IPoiWorksheetData[]> {

        const dataA = this.normaliseVectors(annualData, false, ReportService.CT_ANNUAL_START_YEAR)
        const forecastYear = roundInfo.year + 1 + (roundInfo.periodId === 'AUT' ? 1 : 0)

        const settingsPoi: IPoiWorksheetData = {
            worksheet: 'Settings',
            cellData: [
                { cellRef: 'A4', value: { n: forecastYear - 3 } },
                { cellRef: 'B4', value: { n: forecastYear } },
                { cellRef: 'C4',
                    value: {
                        s: `${(forecastYear - 2021).toLocaleString(undefined, {minimumIntegerDigits: 2})}-` +
                           `${(forecastYear - 2006).toLocaleString(undefined, {minimumIntegerDigits: 2})}`
                    }
                }
            ]
        }

        const annualPoi: IPoiWorksheetData = {
            worksheet: 'Data',
            tableData: [{
                cellRef: 'A4',
                data: dataA.map(row => {
                    return [
                        { s: row.INDICATOR_ID }, // Code
                        { s: row.COUNTRY_ID }, //  Country
                        { s:  `${row.COUNTRY_ID}.${row.INDICATOR_ID}` }, // Identifier
                        { s: row.SCALE_ID }, // Scale
                        { d: this.formatPoiDate(new Date(row.UPDATE_DATE)) }, // Last updated
                        ...this.mapVectorToPoi(row.TIMESERIE_DATA) // vector data
                    ]
                })
            }]
        }

        const countryPoi: IPoiWorksheetData = {
            worksheet: 'country',
            cellData: [
                { cellRef: 'R2', value: { s: country.COUNTRY_ID } },
            ],
            actions: [
                {
                    type: PoiActionType.RENAME,
                    newName: country.COUNTRY_ID,
                }
            ]
        }

        return [countryPoi, settingsPoi, annualPoi]
    }

    /**********************************************************************************************
     * @method mapVectorToPoi
     *********************************************************************************************/
    private mapVectorToPoi(vector: number[]): IPoiCellValue[] {
        return vector.map(v => v === null || v === undefined || isNaN(v) ? { f: 'NA()' } : { n: v })
    }

    /**
     * @method formatPoiDate
     * @return date as iso string
     */
    private formatPoiDate(date: Date): string {
        return date.toISOString()
    }

    /**********************************************************************************************
     * @method addinKey
     *********************************************************************************************/
    private addinKey(freq: string, row: IIndicatorData, ecDB = ''): string {
        return `${ecDB}${row.COUNTRY_ID}.${row.INDICATOR_ID}.${freq}`
    }

    /**********************************************************************************************
     * @method normaliseVectors
     *********************************************************************************************/
    private normaliseVectors(
        data: IIndicatorData[], isQuarterly = false, startYear = 2000
    ): IIndicatorData[] {
        return data.map(row => {
            const startDiff = (startYear - row.START_YEAR) * (isQuarterly ? 4 : 1)
            row.TIMESERIE_DATA.splice(0, startDiff, ...Array(Math.max(0, -startDiff)).fill(null))
            row.START_YEAR = startYear
            return row
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatTableIndicators
     * @returns indicators grouped by periodicity: array of tuples [periodicity, [indicators]]
     *********************************************************************************************/
    private formatTableIndicators(indicators: string[][]): Array<[string, string[]]> {
        return indicators.reduce((acc, indicator) => {
            if (!acc.length || acc[0][0] !== indicator[0]) acc.unshift([indicator[0], []])
            acc[0][1].push(indicator[1])
            return acc
        }, [] as Array<[string, string[]]>)
    }

    /**********************************************************************************************
     * @method convertAmecoXferToExcel
     *********************************************************************************************/
    private async convertAmecoXferToExcel(xferAmeco: IXferAmeco): Promise<Buffer> {
        const numYears = xferAmeco.yearsRange[1] - xferAmeco.yearsRange[0] + 1
        const workbook: Workbook = new Workbook()
        const sheet = workbook.addWorksheet('desk')
        for (const country of xferAmeco.countries) {
            const row = sheet.addRow([
                country,
                null,
                ...Array.from({length: numYears}, (_, idx) => xferAmeco.yearsRange[0] + idx),
            ])
            row.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FFFFFF00' },
            }

            xferAmeco.indicators.forEach((indicator, i) => sheet.addRow([
                `${i + 1}.`,
                indicator,
                ...Array.from(
                    {length: numYears},
                    (_, idx) => this.getXferValue(xferAmeco.data[country][indicator]?.[idx]),
                )
            ]))
        }

        return workbook.xlsx.writeBuffer().then(raw => Buffer.from(raw))
    }

    /**********************************************************************************************
     * @method getXferValue
     *********************************************************************************************/
    private getXferValue(data: number): number {
        return !isNaN(data) && data !== undefined && data !== null ? data : -9999
    }

    /**********************************************************************************************
     * @method getXferAmeco
     *********************************************************************************************/
    private async getXferAmeco(ctyGroup: string): Promise <IXferAmeco> {
        const numYears = 10
        const [codes, baseYear, countries] = await Promise.all([
            this.getReportIndicators('AMECO'),
            this.getBaseYear(),
            this.getCountryGroupCountries(ctyGroup),
        ])
        const data: IIndicatorData[] = countries.length
            ? await this.getProviderData(
                'DESK', countries, codes.map(code => code.INDICATOR_ID), 'A'
            ) as IIndicatorData[] : []
        const yearsRange: [number, number] = [baseYear - numYears + 2, baseYear + 1]

        const codesMap = Object.assign(
            { 180: 'ICI' },
            Array(11).fill('Quarterly').reduce((acc, cur, idx) => (acc[15 + idx] = cur, acc), {}),
            Array(6).fill('Quarterly').reduce((acc, cur, idx) => (acc[166 + idx] = cur, acc), {}),
            codes.reduce((acc, code) => (acc[code.ORDER_BY] = code.INDICATOR_ID, acc), {}),
        )
        const indicators = Array.from({length: 180}, (_, idx) => codesMap[idx + 1] ?? 'For future use')
        return {
            countries,
            indicators,
            yearsRange,
            data: data.reduce(
                (acc, cur) => (
                    acc[cur.COUNTRY_ID][cur.INDICATOR_ID] = VectorService.normaliseVector(
                        yearsRange[0], numYears, 1, cur.START_YEAR, cur.TIMESERIE_DATA
                    ),
                        acc
                ),
                countries.reduce((acc, country) => (
                    acc[country] = {
                        'ICI': [country === 'RS' ? 0 : 1].concat(Array(numYears - 1).fill(NaN))
                    },
                        acc
                ), {})
            ),
        }
    }

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    private getCountryGroupCountries(ctyGroup: string): Promise<string[]> {
        return DashboardApi.getCountryGroupCountries(ctyGroup).then(gc => gc.map(country => country.COUNTRY_ID))
    }

    /**********************************************************************************************
     * @method convertUnits
     *********************************************************************************************/
    private async convertUnits(
        data: IIndicatorData[], provider: string, periodicity: string,
        indicators: string[], countries: string[],
    ): Promise<void> {
        const scaleKey = (indicatorId, countryId) => `${indicatorId}_${countryId}`
        const scalesMap: Map<string, IIndicatorScale>  =  (await this.getIndicatorsScales(
            provider, periodicity, countries, indicators,
        )).reduce((acc, scale) =>
            acc.set(scaleKey(scale.INDICATOR_ID, scale.COUNTRY_ID), scale), new Map<string, IIndicatorScale>()
        )

        data.forEach(indData => {
            const scale: IIndicatorScale = scalesMap.get(scaleKey(indData.INDICATOR_ID, indData.COUNTRY_ID))
            if (scale?.EXPONENT) {
                indData.TIMESERIE_DATA = indData.TIMESERIE_DATA.map(
                    v => isNaN(v) ? v : v / Math.pow(10, scale.EXPONENT)
                )
                indData.SCALE_ID = scale.SCALE_ID
                indData.SCALE_DESCR = scale.DESCR
            }
        })
    }

    /**********************************************************************************************
     * @method prepareBudgIndicatorMap
     *********************************************************************************************/
    private prepareBudgIndicatorMap(data: IIndicatorData[]): Map<string, IBudgIndicator> {
        const dataMap: Map<string, IBudgIndicator> = data.reduce((acc, indData) => {
            const endYear = indData.START_YEAR + indData.TIMESERIE_DATA.length - 1
            const budgInd: IBudgIndicator = acc.get(indData.INDICATOR_ID) || {
                startYear: indData.START_YEAR,
                endYear,
                data: {}
            }
            budgInd.startYear = Math.min(budgInd.startYear, indData.START_YEAR)
            budgInd.endYear = Math.max(budgInd.endYear, endYear)
            budgInd.data[indData.COUNTRY_ID] = indData

            acc.set(indData.INDICATOR_ID, budgInd)
            return acc
        }, new Map<string, IBudgIndicator>())

        // align vectors' start year
        dataMap.forEach((budgInd) => {
                Object.keys(budgInd.data).forEach((cty) => {
                    const yearDiff = budgInd.data[cty].START_YEAR - budgInd.startYear
                    budgInd.data[cty].TIMESERIE_DATA = Array.from(
                        { length: yearDiff }, () => undefined)
                        .concat(budgInd.data[cty].TIMESERIE_DATA.map(v => isNaN(v) ? undefined : v))
                })
            }
        )

        return dataMap
    }
}
