import * as JSZip from 'jszip'

import {
    EerProviders,
    ICsvFile,
    IEerCountry,
    IEerGeoGroup,
    IEerIndicatorData,
    IEerIndicatorDataUpload,
    IEerMatrixData,
    IEerMatrixDataUpload,
    IEerMatrixUploadResult,
    IEerProviderIndicatorData,
    IPublicationEertData,
    IXlsxFile,
    IXlsxRow,
    IXlsxSheet,
    IXlsxValue,
} from './shared-interfaces'
import {
    IDBEerIndicatorData,
    IDBPublicationEertData,
    IDBPublicationGeoArea,
    IDBPublicationWeightData,
    IGroupedPublicationGeo,
    IGroupedWeightData,
    IGroupedWeights,
    IPublicationConfig,
    IPublicationGeoAreas,
    IReerPeriodYear,
    IReerPubGroupPeriod,
} from '.'
import { EApps } from 'config'
import { EerService } from './eer.service'
import { IProviderUpload } from '../../../fdms/src/upload/shared-interfaces'
import { VectorService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class EerController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly START_YEAR__WEIGHT = 1993
    private static readonly XLSX_NA_FORMULA: IXlsxValue = { t: 's', f: 'NA()' }

    private static readonly REER_PUB_HICP: IPublicationConfig = { provider: EerProviders.REER_HICP, indicator: 'RHICP' }
    private static readonly REER_PUB_ULC: IPublicationConfig = {  provider: EerProviders.REER_ULC,  indicator: 'RULC' }
    private static readonly REER_PUB_GDP: IPublicationConfig = {  provider: EerProviders.REER_GDP,  indicator: 'RGDP' }
    private static readonly REER_PUB_XPI: IPublicationConfig = {  provider: EerProviders.REER_XPI,  indicator: 'RXPI' }

    private static readonly REER_PUB: IPublicationConfig[] = [
        EerController.REER_PUB_HICP,
        EerController.REER_PUB_ULC,
        EerController.REER_PUB_GDP,
        EerController.REER_PUB_XPI,
    ]
    private static readonly REER_PUB_GROUP_PERIOD: IReerPubGroupPeriod = {
        42: {
            A: [EerController.REER_PUB_HICP, EerController.REER_PUB_GDP],
            Q: [EerController.REER_PUB_HICP, EerController.REER_PUB_GDP],
            M: [EerController.REER_PUB_HICP],
            default: EerController.REER_PUB,
        },
        default: {
            M: [EerController.REER_PUB_HICP],
            default: EerController.REER_PUB
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, private readonly eerService: EerService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isCalculated
     *********************************************************************************************/
    public isCalculated(providerId: string): Promise<boolean> {
        return this.eerService.isCalculated(providerId)
    }

    /**********************************************************************************************
     * @method getUploads
     *********************************************************************************************/
    public getUploads(): Promise<IProviderUpload[]> {
        return this.eerService.getUploads()
    }

    /**********************************************************************************************
     * @method getProviderUpload
     *********************************************************************************************/
    public getProviderUpload(providerId: string): Promise<IProviderUpload> {
        return this.eerService.getProviderUpload(providerId)
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(
        providerId: string,
        group: string,
        periodicity: string,
    ): Promise<IEerProviderIndicatorData> {
        const dbData: IDBEerIndicatorData[] = await this.eerService.getProviderIndicatorData(
            providerId,
            group,
            periodicity,
        )

        const year = new Date().getFullYear()
        const startYears = {}
        const result: IEerProviderIndicatorData = dbData.reduce((acc, db) => {
            const indData: IEerIndicatorData = this.convertDbIndicatorData(db)
            const freq = db.periodicityId

            if (!startYears[freq]) startYears[freq] = year
            if (!acc[freq]) acc[freq] = []

            startYears[freq] = Math.min(db.startYear, startYears[freq])
            acc[freq].push(indData)

            return acc
        }, {})

        Object.keys(result).forEach(freq => this.normalizeIndicators(result[freq], startYears[freq], freq))

        return result
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public getCountries(): Promise<IEerCountry[]> {
        return this.eerService.getNeerCountries()
    }

    /**********************************************************************************************
     * @method uploadIndicatorData
     *********************************************************************************************/
    public async uploadIndicatorData(
        providerId: string,
        dataArray: IEerIndicatorDataUpload[],
        user: string,
    ): Promise<number> {
        const result = await Promise.all(
            dataArray.map(data =>
                this.eerService.uploadIndicatorData(
                    providerId,
                    data.indicatorId,
                    data.periodicityId,
                    data.geoGrpId,
                    data.startYear,
                    data.countries,
                    data.timeseries,
                    user,
                ),
            ),
        ).then(resultsArray => {
            let updatedRecords = 0
            for (const result of resultsArray) {
                if (result < 0) throw new Error('Internal error when uploading EER indicator data')
                updatedRecords += result
            }
            return updatedRecords
        })

        if (result > 0) {
            await this.setLastDataUploadInfo(providerId, user)
        }

        return result
    }

    /**********************************************************************************************
     * @method uploadMatrixData
     *********************************************************************************************/
    public async uploadMatrixData(
        providerId: string,
        dataArray: IEerMatrixDataUpload[],
        user: string,
    ): Promise<IEerMatrixUploadResult> {
        const result: IEerMatrixUploadResult = await Promise.all(
            dataArray.map(data =>
                this.eerService
                    .uploadMatrixData(
                        providerId,
                        data.year,
                        data.importers,
                        data.exporters,
                        data.geoGrpId,
                        data.values,
                        user,
                    )
                    .then(result => ({ year: data.year, result })),
            ),
        ).then(resultsArray => resultsArray.reduce((acc, value) => ((acc[value.year] = value.result), acc), {}))

        if (Array.from(Object.values(result)).find(v => v > 0) !== undefined) {
            await this.setLastDataUploadInfo(providerId, user)
        }

        return result
    }

    /**********************************************************************************************
     * @method getMatrixData
     *********************************************************************************************/
    public async getMatrixData(providerId: string, group: string, years: number[]): Promise<IEerMatrixData[]> {
        return this.eerService.getProviderMatrixData(providerId, group, years)
    }

    /**********************************************************************************************
     * @method getBaseYear
     *********************************************************************************************/
     public async getBaseYear(): Promise<number> {
       return this.eerService.getBaseYear()
    }

     /**********************************************************************************************
     * @method setBaseYear
     *********************************************************************************************/
     public async setBaseYear(year: number): Promise<number> {
        return this.eerService.setBaseYear(year)
     }

    /**********************************************************************************************
     * @method getGeoGroups
     *********************************************************************************************/
    public async getGeoGroups(activeOnly: boolean): Promise<IEerGeoGroup[]> {
        return this.eerService.getGeoGroups(activeOnly)
    }

    /**********************************************************************************************
     * @method getMatrixYears
     *********************************************************************************************/
    public async getMatrixYears(providerId: string): Promise<number[]> {
        return this.eerService.getMatrixYears(providerId)
    }

    /**********************************************************************************************
     * @method getExporter
     *********************************************************************************************/
    public async getExporter(type: string): Promise<Buffer> {
        const zip = new JSZip()
        return Promise.all([
            this.getPublicationCountries(),
            this.eerService.getPublicationWeightData(),
            this.eerService.getPublicationReerData(),
            this.eerService.getPublicationNeerData(),
        ]).then(([countries, weights, reer, neer]) => {
            switch (type) {
                case 'csv':
                    this.generateCsvPublicationZip(zip, countries, weights, reer, neer)
                    break
                case 'xlsx':
                    this.generateXlsxPublicationZip(zip, countries, weights, reer, neer)
                    break
            }
            //generate zip
            return zip.generateAsync({ compression: 'DEFLATE', type: 'nodebuffer' })
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getPublicationCountries
     *********************************************************************************************/
    private async getPublicationCountries(): Promise<IPublicationGeoAreas> {
        return Promise.all([
            this.eerService.getPublicationEerGeoColumns(),
            this.eerService.getPublicationWeightGeoColumns()
        ]).then(([eerGeoColumns, weightsGeoColumns]) => (
            {
                eerColumns: this.groupByGroupAlias(eerGeoColumns),
                weightColumns: this.groupByGroupAlias(weightsGeoColumns)
            })
        )
    }

    /**********************************************************************************************
     * @method groupByGroupAlias
     *********************************************************************************************/
    private groupByGroupAlias(data: IDBPublicationGeoArea[]): IGroupedPublicationGeo {
        return data.reduce((acc, geo) => {
            if (!acc[geo.groupAlias]) acc[geo.groupAlias] = []
            acc[geo.groupAlias].push(geo)

            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method setLastDataUploadInfo
     *********************************************************************************************/
    private async setLastDataUploadInfo(providerId: string, user: string): Promise<void> {
        const ret = await this.eerService.setDataUploads(providerId, user)
        if (ret < 0) {
            throw new Error(`Internal error when updating last upload information for provider: ${providerId}`)
        }
    }

    /**********************************************************************************************
     * @method convertDbIndicatorData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private convertDbIndicatorData({ timeserieData, periodicityId, ...rest }: IDBEerIndicatorData): IEerIndicatorData {
        return {
            timeserie: VectorService.stringToVector(timeserieData),
            ...rest,
        }
    }

    /**********************************************************************************************
     * @method normalizeIndicators
     *********************************************************************************************/
    private normalizeIndicators(indicators: IEerIndicatorData[], minStartYear: number, freq: string) {
        const multiplier = freq === 'M' ? 12 : freq === 'Q' ? 4 : 1
        for (const ind of indicators) {
            const missingLength = ind.startYear - minStartYear
            if (missingLength > 0) {
                ind.timeserie = Array.from({ length: missingLength * multiplier }, () => null).concat(ind.timeserie)
            }
        }
    }

    /**********************************************************************************************
     * @method convertXlsSheetsToCsvFiles
     *********************************************************************************************/
    private convertXlsSheetsToCsvFiles(sheets: IXlsxSheet[]): ICsvFile[] {
        const convertXlsValue = (value: IXlsxValue) => value?.v !== undefined ? value.v : `"=NA()"`
        return sheets.map(({ header, rows, name }) => ({
            header: header.join(','),
            rows: rows.map(row => header.map(h => convertXlsValue(row[h])).join(',')),
            name,
        }))
    }

    /**********************************************************************************************
     * @method generateXslPublicationFiles
     *********************************************************************************************/
    private generateXslPublicationFiles(
        publicationGeoAreas: IPublicationGeoAreas,
        weightData: IDBPublicationWeightData[],
        dbReerData: IDBPublicationEertData[],
        dbNeerData: IDBPublicationEertData[],
    ): IXlsxFile[] {
        return [
            ...this.getPublicationWeightData(publicationGeoAreas, weightData),
            ...this.getPublicationReerData(publicationGeoAreas.eerColumns, dbReerData),
            ...this.getPublicationNeerData(publicationGeoAreas.eerColumns, dbNeerData),
        ]
    }

    /**********************************************************************************************
     * @method generateCsvPublicationFiles
     *********************************************************************************************/
    private generateCsvPublicationFiles(
        publicationGeoAreas: IPublicationGeoAreas,
        weightData: IDBPublicationWeightData[],
        reerData: IDBPublicationEertData[],
        neerData: IDBPublicationEertData[],
    ): ICsvFile[] {
        const files: ICsvFile[] = []
        this.getPublicationWeightData(publicationGeoAreas, weightData).forEach(
            group => files.push(...this.convertXlsSheetsToCsvFiles(group.sheets)),
        )
        this.getPublicationReerData(publicationGeoAreas.eerColumns, reerData).forEach(
            group => files.push(...this.convertXlsSheetsToCsvFiles(group.sheets)),
        )
        this.getPublicationNeerData(publicationGeoAreas.eerColumns, neerData).forEach(
            group => files.push(...this.convertXlsSheetsToCsvFiles(group.sheets)),
        )
        return files
    }

    /**********************************************************************************************
     * @method convertDBPublicationEertData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private convertDBPublicationEertData({ timeserieData, ...rest }: IDBPublicationEertData): IPublicationEertData {
        return {
            timeserie: VectorService.stringToVector(timeserieData),
            ...rest,
        }
    }

    /**********************************************************************************************
     * @method getPublicationWeightData
     *********************************************************************************************/
    private getPublicationWeightData(
        publicationGeoAreas: IPublicationGeoAreas,
        weightData: IDBPublicationWeightData[],
    ): IXlsxFile[] {
        //distinct groups to generate files
        const groups = [...new Set(weightData.map(item => item.geoGroupAlias))]
        const groupedWeights: { [group: string]: IDBPublicationWeightData[] } = weightData.reduce((acc, item) => {
            acc[item.geoGroupAlias] = acc[item.geoGroupAlias] || []
            acc[item.geoGroupAlias].push(item)
            return acc
        }, {})

        return groups.map(group => (
            {
                sheets: this.getPublicationWeightDataByGroup(
                    publicationGeoAreas.weightColumns[group],
                    publicationGeoAreas.eerColumns[group],
                    groupedWeights[group],
                    group,
                ),
                name: `a${group}wghts`,
            })
        )
    }

    /**********************************************************************************************
     * @method getPublicationWeightDataByGroup
     *********************************************************************************************/
    private getPublicationWeightDataByGroup(
        geoColumns: IDBPublicationGeoArea[],
        geoRows: IDBPublicationGeoArea[],
        weightData: IDBPublicationWeightData[],
        group: string,
    ): IXlsxSheet[] {
        //distinct years ordered DESC, from current year until START_YEAR__WEIGHT
        const currentYear = new Date().getFullYear()
        const years = [...new Set(weightData.map(item => item.year))]
            .filter(year => year >= EerController.START_YEAR__WEIGHT && year <= currentYear)
            .sort()
            .reverse()

        const key = (year: number, importer: string, exporter: string) => `${year}_${importer}_${exporter}`
        const groupedData: IGroupedWeights = weightData.reduce((acc, item) => {
            if (!acc[item.year]) {
                acc[item.year] = { exporters: new Set<string>(), importers: new Set<string>(), data: {} }
            }
            const groupedWeightData: IGroupedWeightData = acc[item.year]
            groupedWeightData.exporters.add(item.expCtyId)
            groupedWeightData.importers.add(item.impCtyId)
            groupedWeightData.data[key(item.year, item.impCtyId, item.expCtyId)] = item.value

            return acc
        }, {})

        return years.map(year => {
            const groupedWeightData: IGroupedWeightData = groupedData[year]
            const xCountries = geoColumns
            const yCountries = geoRows

            const header: string[] = [`${year}`, ...xCountries.map(c => c.descr)]
            const rows: IXlsxRow[] = yCountries.map(exporter =>
                xCountries.reduce((acc, importer) => {
                    acc[`${year}`] = { t: 's', v: exporter.descr }
                    const value = groupedWeightData.data[key(year, importer.geoAreaId, exporter.geoAreaId)]
                    acc[importer.descr] =  this.getXlsxNumber(value)

                    return acc
                }, {} as IXlsxRow)
            )
            return { header, rows, name: `a${group}w${year}`.toUpperCase() }
        })
    }

    /**********************************************************************************************
     * @method hasValidValue
     *********************************************************************************************/
    private hasValidValue(data: unknown): boolean {
        const numeric = Number(data)
        return data !== null && data !== undefined && String(data).trim() !== '' && !isNaN(numeric)
    }

    /**********************************************************************************************
     * @method getPublicationReerData
     *********************************************************************************************/
    private getPublicationReerData(geoColumns: IGroupedPublicationGeo, data: IDBPublicationEertData[]): IXlsxFile[] {
        //distinct groups to generate files
        const [groups, frequencies] = this.getGroupsAndFrequencies(data)
        const groupedData: { [provider: string]: IDBPublicationEertData[] } = data.reduce((acc, item) => {
            acc[item.providerId] = acc[item.providerId] || []
            acc[item.providerId].push(item)
            return acc
        }, {})

        return frequencies.reduce((acc, frequency) => {
            acc.push(
                ...groups.map(group => ({
                    name: `${frequency}${group}reer`,
                    sheets: this.getReerPublicationConfigByGroupFrequency(group, frequency).map(pc =>
                        this.getPublicationEerDataByFreqAndGroup(
                            geoColumns[group],
                            groupedData[pc.provider],
                            frequency,
                            group,
                            `${frequency}${group}${pc.indicator}`,
                        ),
                    ),
                })),
            )
            return acc
        }, [])
    }

    /**********************************************************************************************
     * @method getReerPublicationConfigByGroupFrequency
     *********************************************************************************************/
    private getReerPublicationConfigByGroupFrequency(group: string, frequency: string): IPublicationConfig[] {
        return (EerController.REER_PUB_GROUP_PERIOD[group] ?? EerController.REER_PUB_GROUP_PERIOD['default'])[frequency] ??
               (EerController.REER_PUB_GROUP_PERIOD[group] ?? EerController.REER_PUB_GROUP_PERIOD['default'])['default']
    }

    /**********************************************************************************************
     * @method getPublicationNeerData
     *********************************************************************************************/
    private getPublicationNeerData(geoColumns: IGroupedPublicationGeo, data: IDBPublicationEertData[]): IXlsxFile[] {
        // distinct groups to generate files
        const [groups, frequencies] = this.getGroupsAndFrequencies(data)

        return frequencies.reduce((acc, frequency) => {
            acc.push(...groups.map(group => ({
                    name: `${frequency}${group}neer`,
                    sheets: [
                        this.getPublicationEerDataByFreqAndGroup(
                            geoColumns[group],
                            data,
                            frequency,
                            group,
                            `${frequency}${group}NEER`,
                        ),
                    ],
                })),
            )
            return acc
        }, [])
    }

    /**********************************************************************************************
     * @method getPublicationEerDataByFreqAndGroup
     *********************************************************************************************/
    private getPublicationEerDataByFreqAndGroup(
        geoAreas: IDBPublicationGeoArea[],
        allDBData: IDBPublicationEertData[],
        frequency: string,
        group: string,
        name: string,
    ): IXlsxSheet {
        const allData: IPublicationEertData[] = allDBData
            .filter(item => item.geoGroupAlias == group && item.periodicityId == frequency)
            .map(item => this.convertDBPublicationEertData(item))

        const header = ['0', ...geoAreas.map(c => c.descr)]
        const maxLength = allData.reduce((maxLength, indData) => Math.max(maxLength, indData.timeserie?.length), 0)
        const minStartYear = allData.reduce(
            (min, indData) => Math.min(min, indData.startYear),
            new Date().getFullYear(),
        )
        const fullYears = this.getPeriods(minStartYear, maxLength, frequency)

        const rows: IXlsxRow[] = Object.keys(fullYears).reduce(
            (acc, period, periodIndex) => (
                acc.push(
                    this.makePublicationEerDataRow(geoAreas, allData, minStartYear, period, periodIndex, fullYears)
                ), acc
            ),
            [] as IXlsxRow[],
        )
        return { header, rows, name: name }
    }

    /**********************************************************************************************
     * @method getGroupsAndFrequencies
     *********************************************************************************************/
    private getGroupsAndFrequencies(data: IDBPublicationEertData[]): [string[], string[]] {
        const groups = [...new Set(data.map(item => item.geoGroupAlias))]
        const frequencies = [...new Set(data.map(item => item.periodicityId))]

        return [groups, frequencies]
    }

    /**********************************************************************************************
     * @method makePublicationEerDataRow
     *********************************************************************************************/
    private makePublicationEerDataRow(
        geoAreas: IDBPublicationGeoArea[],
        data: IPublicationEertData[],
        minStartYear: number,
        period: string,
        periodIndex: number,
        periodRange: IReerPeriodYear
    ): IXlsxRow {
        return geoAreas.reduce(
            (acc, country) => {
                const ctyData: IPublicationEertData = data.find(
                    f => f.startYear <= periodRange[period].year && f.countryId === country.geoAreaId,
                )
                const timeserie = ctyData?.timeserie
                //calculate index within offset from the item (start year) including frequency behaviour
                const periodsOffset = (ctyData.startYear - minStartYear) * periodRange[period].multiplier

                const timeSeriesIndex = ctyData ? periodIndex - periodsOffset : -1
                acc[country.descr] = timeserie?.length > timeSeriesIndex ?
                    this.getXlsxNumber(timeserie[timeSeriesIndex]) : EerController.XLSX_NA_FORMULA

                return acc
            },
            { '0': { t: 's', v: period }},
        )
    }

    /**********************************************************************************************
     * @method getXlsxNumber
     *********************************************************************************************/
    private getXlsxNumber(value: unknown): IXlsxValue {
        return this.hasValidValue(value) ? { t: 'n', v: Number(value) } : EerController.XLSX_NA_FORMULA
    }

    /**********************************************************************************************
     * @method getPeriods
     *********************************************************************************************/
    private getPeriods(startYear: number, length: number, periodicity = 'A'): IReerPeriodYear {
        const multiplier = periodicity === 'M' ? 12 : periodicity === 'Q' ? 4 : 1

        const next = (index: number) => (periodicity === 'A' ? index : Math.floor(index / multiplier))
        const leadingZero = (value: number) => (periodicity !== 'A' && value < 10 ? `0${value}` : value)
        const suffix = (index: number) =>
            periodicity === 'A'
                ? ''
                : periodicity === 'Q'
                ? `.${leadingZero(formatQ(index))}`
                : `.${leadingZero((index % multiplier) + 1)}`
        const formatQ = (index: number) => ((index + 1) % multiplier == 0 ? 12 : ((index + 1) % multiplier) * 3)
        return Array.from({ length: length }, (_, index) => `${startYear + next(index)}${suffix(index)}`).reduce(
            (acc, value, index) => ((acc[value] = { year: startYear + next(index), multiplier}), acc),
            {} as IReerPeriodYear,
        )
    }

    /**********************************************************************************************
     * @method generateCsvPublicationZip
     *********************************************************************************************/
    private generateCsvPublicationZip(
        zip: JSZip,
        publicationGeoAreas: IPublicationGeoAreas,
        weights: IDBPublicationWeightData[],
        reer: IDBPublicationEertData[],
        neer: IDBPublicationEertData[]
    ) {
        const files: ICsvFile[] = this.generateCsvPublicationFiles(
            publicationGeoAreas,
            weights, reer, neer,
        )
        files.forEach(file => {
            const buffer = file.header + '\n' + file.rows.join('\n')
            zip.file(`${file.name.toLowerCase()}.csv`, buffer)
        })
    }

    /**********************************************************************************************
     * @method generateXlsxPublicationZip
     *********************************************************************************************/
    private generateXlsxPublicationZip(
        zip: JSZip,
        publicationGeoAreas: IPublicationGeoAreas,
        weights: IDBPublicationWeightData[],
        reer: IDBPublicationEertData[],
        neer: IDBPublicationEertData[]
    ) {
        const files: IXlsxFile[] = this.generateXslPublicationFiles(
            publicationGeoAreas,
            weights, reer, neer,
        )
        files.forEach(file => {
            const buffer = this.eerService.makeExcel(file.sheets)
            zip.file(file.name.toLowerCase() + '.xlsx', buffer)
        })
    }
}
