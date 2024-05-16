import {
    AmecoXferType,
    IBudgReport,
    ICompressedData,
    ICountryTable,
    IDetailedTable,
    IHeaderCol,
    IIndicatorData,
    IIndicatorReport,
    IIndicatorScale,
    IIndicatorTreeNode,
    ITableRow,
    IValidationStepIndicator,
    IValidationTable,
} from './shared-interfaces'
import { CountryStatusApi, DashboardApi, ExcelPoiApi } from '../../../lib/dist/api'
import { EErrors, FastopError } from '../../../shared-lib/dist/prelib/error'
import { ENotificationTemplate, IAttachment, INotificationTemplate } from 'notification'
import { ICtyScale, IDBIndicatorData, IDBTableCol, IDBTableLine, INumericString, ProviderDataLocation } from '.'
import { Level, LoggingService } from '../../../lib/dist'
import { EApps } from 'config'
import { EStatusRepo } from 'country-status'
import { ETasks } from 'task'
import { ETemplateTypes } from '../../../shared-lib/dist/prelib/files'
import { IBinaryFile } from '../../../lib/dist/template/shared-interfaces'
import { ICountry } from '../../../lib/dist/menu'
import { NotificationApi } from '../../../lib/dist/api/notification.api'
import { ReportService } from './report.service'
import { RequestService } from '../../../lib/dist/request.service'
import { SharedService } from '../shared/shared.service'
import { TaskApi } from '../../../lib/dist/api/task.api'
import { TceService } from './tce/tce.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class ReportController {

    private static readonly MILLION_DIVISOR = 1000000.0

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _validationTableTemplate: IValidationTable

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly reportService: ReportService,
        private readonly tceService: TceService,
        private readonly logs: LoggingService,
        private readonly sharedService: SharedService
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryTable
     *********************************************************************************************/
    public async getCountryTable(
        taskId: ETasks, roundSid: number, storageSid: number, countryId: string,
    ): Promise<ICountryTable> {
        if (taskId === ETasks.TCE) {
            return this.tceService.getTceCountryTable(roundSid, storageSid, countryId)
        } else {
            const query = this.appId === EApps.FDMSIE ? '?ie=true' : ''
            return Promise.all([
                RequestService.request(EApps.FDMSSTAR, `/reports/countryTable/${countryId}/${roundSid}/${storageSid}${query}`),
                this.sharedService.isOgFull(countryId, roundSid, storageSid),
            ]).then(([countryTable, ogFull]) => Object.assign(countryTable, { ogFull }))
        }
    }

    /**********************************************************************************************
     * @method getCountryTableData
     *********************************************************************************************/
    public async getCountryTableData(
        countryId: string, roundSid?: number, storageSid?: number, custTextSid?: number,
    ): Promise<IIndicatorData[]> {
        return this.reportService.getCountryTableData([countryId], null, roundSid, storageSid, custTextSid)
            .then(SharedService.indicatorsDataVectorToArray)
    }

    /**********************************************************************************************
     * @method getDetailedTable
     *********************************************************************************************/
    public async getDetailedTable(
        tableSid: number, countryId: string, roundSid: number, storageSid: number
    ): Promise<ICountryTable> {
        return Promise.all([
            this.reportService.getCtyScale(countryId),
            this.reportService.getBaseYear(roundSid),
            this.reportService.getTableCols(tableSid),
            this.reportService.getTableLines(tableSid),
            this.reportService.getTableFooter(tableSid),
            this.reportService.getTableIndicators(tableSid)
                .then(indicatorsPerPeriodicity => Promise.all(
                    indicatorsPerPeriodicity.map(periodicity => this.sharedService.getProvidersIndicatorData(
                        ['PRE_PROD'], [countryId], periodicity[1], periodicity[0], null, roundSid, storageSid
                    )),
                )).then(dataPerPeriodicity => dataPerPeriodicity.flat().reduce((acc, indicator) => {
                    acc[indicator.INDICATOR_ID] = Object.assign(indicator, {
                        values: indicator.TIMESERIE_DATA.split(',').map(value => value ? Number(value) : '')
                    })
                    return acc
                }, {})),
            this.sharedService.isOgFull(countryId, roundSid, storageSid),
        ]).then(this.formatDetailedTable.bind(this))
    }

    /**********************************************************************************************
     * @method getDetailedTables
     *********************************************************************************************/
    public async getDetailedTables(): Promise<IDetailedTable[]> {
        return this.reportService.getDetailedTables()
    }

    /**********************************************************************************************
     * @method getDetailedTablesData
     *********************************************************************************************/
    public async getDetailedTablesData(
        countryId: string, periodicity: string, roundSid?: number, storageSid?: number, custTextSid?: number,
    ): Promise<IIndicatorData[]> {
        return this.reportService.getDetailedTablesData(
            [countryId], periodicity, null, roundSid, storageSid, custTextSid
        ).then(SharedService.indicatorsDataVectorToArray)
    }

    /**********************************************************************************************
     * @method getDetailedTablesExcel
     *********************************************************************************************/
    public async getDetailedTablesExcel(
        countryId: string, roundSid?: number, storageSid?: number, custTextSid?: number,
    ): Promise<IBinaryFile> {
        return Promise.all([
            DashboardApi.getActiveTemplate(this.appId, ETemplateTypes.DETAILED_TABLES).then(
                template => {
                    if (!template) throw new FastopError(EErrors.NO_FILE)
                    return template
                }
            ),
            this.getDetailedTablesData(countryId, 'A', roundSid, storageSid, custTextSid),
            this.getDetailedTablesData(countryId, 'Q', roundSid, storageSid, custTextSid),
            DashboardApi.getRoundInfo(this.appId, roundSid, storageSid),
            DashboardApi.getCountry(countryId),
        ]).then(
            ([template, dataA, dataQ, roundInfo, country]) =>
                this.reportService.prepareDetailedTablesPoiRequest(
                    country, dataA, dataQ, roundInfo
                ).then(poiRequest => ExcelPoiApi.processTemplate(template.content, poiRequest))
                 .then(poiResponse => this.bufferToExcelBinaryFile(poiResponse, `detailed_table_${countryId}.xlsx`))
        ).catch(err => {
            if (err.code === EErrors.NO_FILE) return undefined
            this.logs.log(`Failed generating details table excel!, ${err.toString()}`, Level.ERROR)
            throw err
        })
    }


    /**********************************************************************************************
     * @method getCountryTableExcel
     *********************************************************************************************/
    public async getCountryTableExcel(
        countryId: string, roundSid?: number, storageSid?: number, custTextSid?: number,
    ): Promise<IBinaryFile> {
        return Promise.all([
            DashboardApi.getActiveTemplate(this.appId, ETemplateTypes.COUNTRY_TABLE).then(
                template => {
                    if (!template) throw new FastopError(EErrors.NO_FILE)
                    return template
                }
            ),
            this.getCountryTableData(countryId, roundSid, storageSid, custTextSid),
            DashboardApi.getRoundInfo(this.appId, roundSid, storageSid),
            DashboardApi.getCountry(countryId),
        ]).then(
            ([template, dataA, roundInfo, country]) =>
                this.reportService.prepareCountryTablesPoiRequest(
                    country, dataA, roundInfo
                ).then(poiRequest => ExcelPoiApi.processTemplate(template.content, poiRequest))
                 .then(poiResponse => this.bufferToExcelBinaryFile(poiResponse, `country_table_${countryId}.xlsx`))
        ).catch(err => {
            if (err.code === EErrors.NO_FILE) return undefined
            this.logs.log(`Failed generating country table excel!, ${err.toString()}`, Level.ERROR)
            throw err
        })
    }

    /**********************************************************************************************
     * @method getProviderData
     *********************************************************************************************/
    public async getProviderData(
        providerId: string, periodicityId: string, roundSid: number, storageSid: number, custTextSid: number,
        countryIds?: string[], indicatorIds?: string[], compress?: boolean,
    ): Promise<IIndicatorData[] | ICompressedData> {

        const providerDataLocation: string = await this.reportService.getProviderDataLocation(providerId)
        switch (providerDataLocation) {
            case ProviderDataLocation.INDICATOR_DATA:
                return this.reportService.getProviderData(
                    providerId, countryIds, indicatorIds, periodicityId, roundSid, storageSid, custTextSid, compress,
                )
            case ProviderDataLocation.TCE_RESULTS_DATA:
                return this.tceService.getTceResultsData(
                    countryIds, indicatorIds, undefined, periodicityId, roundSid, storageSid, compress,
                )
            default:
                throw Error(`Unknown source of data for provider: ${providerId}!`)
        }
    }

    /**********************************************************************************************
     * @method getProviders
     *********************************************************************************************/
    public async getProviders() {
        return this.reportService.getProviders()
    }

    /**********************************************************************************************
     * @method getValidationStepDetails
     *********************************************************************************************/
    public async getValidationStepDetails(
        countryId: string, step: number, roundSid: number, storageSid: number
    ): Promise<IValidationStepIndicator[]> {
        const stepDetails = await TaskApi.getValidationStep(this.appId, step, countryId, {roundSid, storageSid})
        const indicatorNames = await this.reportService.getIndicatorNames(stepDetails.map(d => d.INDICATOR_ID))
        return stepDetails.map(detail => ({
            indicatorId: detail.INDICATOR_ID,
            indicatorName: indicatorNames[detail.INDICATOR_ID],
            labels: detail.LABELS.split(','),
            actual: detail.ACTUAL.split(',').map(Number),
            validation1: detail.VALIDATION1?.split(',').map(Number),
            validation2: detail.VALIDATION2?.split(',').map(Number),
            failed: detail.FAILED.split(',').map(b => Boolean(Number(b))),
        }))
    }

    /**********************************************************************************************
     * @method getValidationTable
     *********************************************************************************************/
    public async getValidationTable(countryId: string, roundSid: number, storageSid: number): Promise<IValidationTable> {
        const table$ = this._validationTableTemplate
            ? Promise.resolve(this._validationTableTemplate)
            : RequestService.request(EApps.FDMSSTAR, `/reports/validationTable`).then(table => {
                this._validationTableTemplate = table
                return table
            })

        return Promise.all([
            table$,
            TaskApi.getCtyTaskExceptions(this.appId, ETasks.VALIDATION, countryId, {roundSid, storageSid}).then(
                exceptions => exceptions.reduce((acc, e) => {
                    acc[e.STEP_NUMBER] = [e.STEP_EXCEPTIONS, e.TASK_STEP_TYPE_ID]
                    return acc
                }, {})
            )
        ]).then(([table, exceptionsMapping]: [IValidationTable, Record<number, [number, string]>]) =>
            Object.assign(table, {data: table.data.map(row => {
                const [exceptions, stepType] = exceptionsMapping[row[1]] ?? [undefined, undefined]
                row[5] = exceptions
                row[0] = stepType
                return row
            })})
        )
    }

    /**********************************************************************************************
     * @method getReportIndicators
     *********************************************************************************************/
    public async getReportIndicators(reportId: string): Promise<IIndicatorReport[]> {
        return this.reportService.getReportIndicators(reportId)
    }

    /**********************************************************************************************
     * @method getBaseYear
     *********************************************************************************************/
    public async getBaseYear(roundSid?: number): Promise<number> {
        return this.reportService.getBaseYear(roundSid)
    }

    /**********************************************************************************************
     * @method getIndicatorScales
     *********************************************************************************************/
    public async getIndicatorScales(
        provider: string, periodicity: string, countries: string[], indicators: string[],
    ): Promise<IIndicatorScale[]> {
        return this.reportService.getIndicatorsScales(provider, periodicity, countries, indicators)
    }

    /**********************************************************************************************
     * @method getIndicatorCountries
     *********************************************************************************************/
    public async getIndicatorCountries(): Promise<ICountry[]> {
        return this.reportService.getIndicatorCountries()
    }

    /**********************************************************************************************
     * @method getIndicatorsTree
     *********************************************************************************************/
    public async getIndicatorsTree(): Promise<IIndicatorTreeNode[]> {
        return this.reportService.getIndicatorsTree()
    }

    /**********************************************************************************************
     * @method getXferAmecoFile
     *********************************************************************************************/
    public async getXferAmecoFile(ctyGrp: string): Promise<IAttachment> {
        return this.reportService.getAmecoXferFile(ctyGrp as AmecoXferType)
    }

    /**********************************************************************************************
     * @method getBudgetReport
     *********************************************************************************************/
    public async getBudgetReport(convertUnits = false): Promise<IBudgReport[]> {
        return this.reportService.getBudgetReport(convertUnits)
    }

    /**********************************************************************************************
     * @method sendXferAmecoFiles
     *********************************************************************************************/
    public async sendXferAmecoFiles(user: string): Promise<number> {
        const error = await Promise.all([
            DashboardApi.getCurrentStorage(this.appId).then(storage => storage.isFull),
            DashboardApi.getApplicationCountries(this.appId).then(
                countries => CountryStatusApi.getCountryStatuses(this.appId, countries)
            ).then(
                statuses =>
                    statuses.find(status => status.statusId !== EStatusRepo.ACCEPTED) === undefined
            )
        ]).then(([isFullStorage, allCountriesAccepted]) => {
            if (!isFullStorage) return EErrors.NOT_FULL_STORAGE
            if (!allCountriesAccepted) return EErrors.ALL_ACCEPTED

            return 1
        })

        if (error < 0) return error

        const notificationTemplate: INotificationTemplate = await Promise.all([
            this.reportService.getAmecoXferFile(AmecoXferType.CF),
            this.reportService.getAmecoXferFile(AmecoXferType.BRICS),
            DashboardApi.getCurrentRoundInfo(this.appId),
        ]).then(([cfFile, bricsFile, roundInfo]) => ({
            attachments: [cfFile, bricsFile],
            params: {
                '{ROUND_DESC}': roundInfo.roundDescr,
                '{STORAGE_DESC}': roundInfo.storageDescr,
            }
        }))

        return await NotificationApi.sendEmailWithTemplate(
            ENotificationTemplate.AMECO_TRANSFER,
            notificationTemplate,
            user, this.appId, true
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method bufferToExcelBinaryFile
     *********************************************************************************************/
    private bufferToExcelBinaryFile(binaryData: Buffer, fileName: string): IBinaryFile {
        return  {
            content: binaryData,
            fileName,
            contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        }
    }

    /**********************************************************************************************
     * @method assignDynamicValues
     *********************************************************************************************/
    private assignDynamicValues(baseYear: number) {
        return (match: string, p1: string) => {
            switch (p1) {
                case 'YEARS-5-2': return `${baseYear - 5}-${baseYear - 2}`
                default: return `{${p1}}`
            }
        }
    }

    /**********************************************************************************************
     * @method formatDetailedTable
     *********************************************************************************************/
    private formatDetailedTable(
        [ctyScale, baseYear, cols, lines, footer, indicatorMap, ogFull]:
            [ICtyScale, number, IDBTableCol[], IDBTableLine[], string, Record<string, ILocalIndicatorData>, boolean]
    ): ICountryTable {
        let dataColumnOffset = 2
        const indexCols: IHeaderCol = { header: 'index', colSpan: 2, rowSpan: lines[0]?.LINE_SPAN }
        const header = [
            // first header row
            cols.reduce((acc: IHeaderCol[], col) => {
                const latest = acc[acc.length - 1]
                const colName = col.COL_TYPE_ID === 'CODE' ? col.DESCR : (baseYear + col.YEAR_VALUE).toString()

                if (colName === latest.header) latest.colSpan += 1
                else {
                    const column = { header: colName, colSpan: 1 }
                    if (col.COL_TYPE_ID === 'CODE') {
                        Object.assign(column, { rowSpan: indexCols.rowSpan })
                        dataColumnOffset++
                    }
                    acc.push(column)
                }
                return acc
            }, [indexCols]),
            // optional additional header rows
            ...lines.slice(1, indexCols.rowSpan).map(line =>
                cols.map(col => {
                    if (col.COL_TYPE_ID === 'CODE') return { header: '', colSpan: 0 }
                    else {
                        const colName = line.LINE_TYPE_ID === 'QUARTER' ? col.DESCR : ''
                        return { header: colName, colSpan: 1 }
                    }
                })
            )
        ]

        // table data
        const dataLines = lines.slice(indexCols.rowSpan)
        const data = dataLines.map(line => {
            const indicatorsSet = new Set<string>()
            const indexValues: Array<string|number> = [
                line.LINE_ID,
                line.DESCR?.replace(/{(.*)}/, this.assignDynamicValues(baseYear))
            ]
            const row: ITableRow = cols.reduce((acc, col, idx) => {
                switch(col.COL_TYPE_ID) {
                    case 'CODE':
                        acc.values.push(line.ESA_CODE)
                        break
                    case 'DATA':
                    case 'ALT_DATA':
                    case 'ALT2_DATA': {
                        const colSpansLength = acc.colSpans.length
                        switch(line.LINE_TYPE_ID) {
                            case 'HEADER':
                                if (line[col.COL_TYPE_ID] === acc.values[acc.values.length - 1] && colSpansLength) {
                                    acc.colSpans[colSpansLength - 1]++
                                } else {
                                    acc.values.push(line[col.COL_TYPE_ID])
                                    acc.colSpans.push(1)
                                }
                                break
                            case 'DATA':
                                if (
                                    colSpansLength && ((
                                        line.COL_TYPE_SPAN &&
                                        line.COL_TYPE_SPAN !== col.COL_TYPE_ID &&
                                        cols[idx - 1].COL_TYPE_ID === line.COL_TYPE_SPAN
                                    ) || (
                                        line.SPAN_YEARS_OFFSET !== null &&
                                        cols[idx - 1].COL_TYPE_ID === col.COL_TYPE_ID
                                    ))
                                ) {
                                    acc.colSpans[colSpansLength - 1]++
                                } else {
                                    const indicator = indicatorMap[line[col.COL_TYPE_ID]]
                                    if (line[col.COL_TYPE_ID]) indicatorsSet.add(` ${line[col.COL_TYPE_ID]}`)
                                    let value: INumericString = ''
                                    if (indicator) {
                                        const yearOffset = baseYear + col.YEAR_VALUE - indicator.START_YEAR
                                            + (line.SPAN_YEARS_OFFSET ?? 0)
                                        value = indicator.PERIODICITY_ID === 'A'
                                            ? indicator.values[yearOffset]
                                            : indicator.values[yearOffset * 4 + col.QUARTER - 1]

                                        value = this.convertWithScale(value, ctyScale, col, line)
                                    }
                                    acc.values.push(value)
                                    acc.colSpans.push(1)
                                }
                                break
                        }
                        break
                    }
                }
                return acc
            }, {values: indexValues, colSpans: []})

            row.rowType = line.LINE_TYPE_ID
            row.styles = line.STYLES
            row.indicators = indicatorsSet.size ? Array.from(indicatorsSet) : undefined
            return row
        })
        return {
            header,
            data,
            dataColumnOffset,
            footer,
            ogFull,
        } as ICountryTable
    }

    /**********************************************************************************************
     * @method convertWithScale
     *********************************************************************************************/
    private convertWithScale(
        value: INumericString, ctyScale: ICtyScale, col: IDBTableCol, line: IDBTableLine
    ): INumericString {
        let newValue = value
        if (value && this.shouldConvertWithScale(col, line)) {
            newValue = Number(value) / this.getScaleDivisor(ctyScale, col, line)
        }
        return newValue
    }

    /**********************************************************************************************
     * @method shouldConvertWithScale
     *********************************************************************************************/
    private shouldConvertWithScale(col: IDBTableCol, line: IDBTableLine): boolean {
        return col.USE_CTY_SCALE && line.USE_CTY_SCALE && (col.USE_CTY_SCALE === line.USE_CTY_SCALE)
    }

    /**********************************************************************************************
     * @method getScaleDivisor
     *********************************************************************************************/
    private getScaleDivisor(ctyScale: ICtyScale, col: IDBTableCol, line: IDBTableLine): number {
        if (col.USE_CTY_SCALE === 2 && line.USE_CTY_SCALE === 2) return ReportController.MILLION_DIVISOR
        else return 10 ** ctyScale.exponent
    }

    /**********************************************************************************************
     * @method isMillionsScaleDivisor
     *********************************************************************************************/
    private isMillionsScaleDivisor(columnUseScale: number, rowUseScale: number): boolean {
        return columnUseScale === 2 && rowUseScale === 2
    }
}

interface ILocalIndicatorData extends IDBIndicatorData {
    values: Array<number|string>
}
