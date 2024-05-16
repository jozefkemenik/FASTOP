import {
    IArchiveParams,
    IDBStandardReport,
    IGDPPonderation,
    ILibDictionaries,
    ILibMeasureWizardUpload,
    IMeasureUpload,
    IMeasuresRange,
    IScale,
    MeasureSharedService,
    MeasureUploadService,
} from '..'
import { EApps } from 'config'
import { EMeasureViews } from '../../../../shared-lib/dist/prelib/measure'
import { IError } from '../..'
import { IExcelExport } from '../../excel'

import {
    IColumn,
    IDBLibMeasureDetails,
    ILibMeasureDetails,
    IMeasureTable,
    IMeasuresDenormalised,
    IWizardDefinition,
    IWizardTemplate
} from '.'
import { LibMeasureService } from './measure.service'

export abstract class LibMeasureController<
    D extends ILibMeasureDetails,
    U extends MeasureUploadService<D>,
    M extends LibMeasureService,
> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _range: IMeasuresRange

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        protected readonly appId: EApps,
        protected readonly sharedService: MeasureSharedService,
        protected readonly measureService: M,
        protected readonly uploadService: U,
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method deleteMeasure
     *********************************************************************************************/
    public deleteMeasure(measureSid: number, countryId: string) {
        return this.measureService.deleteMeasure(measureSid, countryId).catch((err: IError) => {
            err.method = 'LibMeasureController.deleteMeasure'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getEnterMeasures
     *********************************************************************************************/
    public async getEnterMeasures(
        countryId: string, gdp: boolean, raw: boolean, archive: IArchiveParams, useNaN = false
    ) {
        let gdpPonderation: IGDPPonderation
        if (gdp) {
            gdpPonderation = await this.sharedService.getGDPPonderation(countryId)
        }

        return this.measureService.getEnterMeasures(countryId, archive).then(
            this.formatEnterMeasures(gdpPonderation, raw, useNaN),
            (err: IError) => {
                err.method = 'LibMeasureController.getEnterMeasures'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getEnterMeasuresExcel
     *********************************************************************************************/
    public async getEnterMeasuresExcel(
        countryId: string,
        gdp: boolean,
        archive: IArchiveParams,
        selectedColumns: IColumn[]
    ): Promise<IExcelExport> {
        const data: IMeasureTable<ILibMeasureDetails> =
            await this.getEnterMeasures(countryId, gdp, false, archive, true)
        const headers = selectedColumns.map(col => col.header)
        const keys = selectedColumns.map(col => col.field)

        const dictionaries = await this.sharedService.getDictionaries(archive.roundSid)
        const grid = data.measures.map(measure =>
            keys.map(column =>
                this.sharedService.getColumnValue(column, measure, dictionaries)))

        return {
                worksheetName: 'Excel Download',
                headers,
                data: grid
            }
    }

    /**********************************************************************************************
     * @method getMeasureDetails
     *********************************************************************************************/
    public getMeasureDetails(measureSid: number, countryId: string, archive: IArchiveParams) {
        return this.measureService.getMeasureDetails(measureSid, countryId, archive).then(
            this.formatMeasureDetails(),
            (err: IError) => {
                err.method = 'LibMeasureController.getMeasureDetails'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getMeasureColumns
     *********************************************************************************************/
    public abstract getMeasureColumns(page: string, year: number): Promise<IColumn[]>

    /**********************************************************************************************
     * @method getMeasuresDenormalised
     *********************************************************************************************/
    public async getMeasuresDenormalised(
        countryId: string, gdp: boolean, archive: IArchiveParams
    ): Promise<IMeasuresDenormalised> {
        const [table, dictionaries, columns] = await Promise.all([
            this.getEnterMeasures(countryId, gdp, false, archive),
            this.sharedService.getDictionaries(archive.roundSid),
            this.getMeasureColumns('enter', 0).then(cols => {
                cols.unshift({header: 'Country', field: 'COUNTRY_ID', views: 0})
                return cols
            }),
        ])
        return {
            columns,
            measures: table.measures.map(this.denormaliseMeasure(dictionaries)),
        }
    }

    /**********************************************************************************************
     * @method getRange
     *********************************************************************************************/
    public async getRange(): Promise<IMeasuresRange> {
        if (!this._range) {
            this._range = await this.measureService.getMeasuresRange()
        }
        return this._range
    }

    /**********************************************************************************************
     * @method getWizardTemplate
     *********************************************************************************************/
    public async getWizardTemplate(
        countryId: string, roundSid: number, withData: boolean, dataHistoryOffset: number
    ): Promise<IWizardTemplate<D>> {
        const measures: D[] = withData
            ? await this.formatMeasures(
                await this.measureService.getWizardMeasures(countryId, roundSid, dataHistoryOffset)
            )
            : []
        const range = await this.measureService.getMeasuresRange()

        return this.uploadService.getWizardTemplate(countryId, roundSid, withData, measures, range)
    }

    /**********************************************************************************************
     * @method saveMeasure
     *********************************************************************************************/
    public saveMeasure(measure: ILibMeasureDetails) {
        return this.measureService.saveMeasure(measure).catch((err: IError) => {
            err.method = 'LibMeasureController.saveMeasure'
            throw err
        })
    }

    /**********************************************************************************************
     * @method setMeasureValues
     *********************************************************************************************/
    public setMeasureValues(
        measureSid: number, countryId: string, year: number, startYear: number, values: number[]
    ) {
        return this.measureService.setMeasureValues(
            measureSid, countryId, year, startYear, values.join()
        ).catch((err: IError) => {
            err.method = 'LibMeasureController.setMeasureValues'
            throw err
        })
    }

    /**********************************************************************************************
     * @method uploadWizardMeasures
     *********************************************************************************************/
    public async uploadWizardMeasures(
        countryId: string, roundSid: number, uploadMeasures: ILibMeasureWizardUpload
    ): Promise<number> {
        const measureUpload: IMeasureUpload =
            this.uploadService.convertToMeasureUpload(countryId, roundSid, uploadMeasures)
        return this.measureService.storeUploadMeasures(measureUpload)
    }

    /**********************************************************************************************
     * @method getWizardDefinition
     *********************************************************************************************/
    public async getWizardDefinition(countryId: string, roundSid: number): Promise<IWizardDefinition> {
        const range = await this.getRange()
        return this.uploadService.getWizardDefinition(countryId, roundSid, range)
    }

    /**********************************************************************************************
     * @method getScales
     *********************************************************************************************/
    public async getScales(): Promise<IScale[]> {
        return this.sharedService.getScales()
    }

    /**********************************************************************************************
     * @method updateMeasureScale
     *********************************************************************************************/
    public async updateMeasureScale(countryId: string, scaleSid: number): Promise<number> {
        return this.measureService.updateMeasureScale(countryId, scaleSid)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method assignColumnOrder
     *********************************************************************************************/
    protected assignColumnOrder(columns: IColumn[]): IColumn[] {
        return columns.map((col, i) => Object.assign({}, col, { order: i }))
    }

    /**********************************************************************************************
     * @method denormaliseMeasure
     *********************************************************************************************/
    protected denormaliseMeasure({esaCodes, oneOff, oneOffTypes, euFunds, months, labels}: ILibDictionaries) {
        return ({
            ESA_SID, ONE_OFF_SID, ONE_OFF_TYPE_SID, IS_EU_FUNDED_SID, EU_FUND_SID, ADOPT_DATE_MH, labelSids, ...rest
        }: ILibMeasureDetails) => ({
            ESA_DESCR: esaCodes[ESA_SID].descr,
            ONE_OFF_DESCR: oneOff[ONE_OFF_SID],
            ONE_OFF_TYPE_DESCR: oneOffTypes[ONE_OFF_TYPE_SID],
            IS_EU_FUNDED_DESCR: oneOff[IS_EU_FUNDED_SID],
            EU_FUND_DESCR: euFunds[EU_FUND_SID],
            ADOPT_DATE_MH_DESCR: months[ADOPT_DATE_MH],
            LABELS_DESCR: labelSids?.map(sid => labels[sid]).join(', '),
            ...rest
        })
    }

    /**********************************************************************************************
     * @method yearsRangeToShow
     *********************************************************************************************/
    protected yearsRangeToShow(startYear: number, endYear: number): IColumn[] {
        return Array.from(
            { length: endYear - startYear },
            (_, idx) => {
                const year = (startYear + idx).toString()
                return { field: year, header: year, width: 120, views: EMeasureViews.DATA }
            }
        )
    }

    /**********************************************************************************************
     * @method formatEnterMeasures
     *********************************************************************************************/
    protected formatEnterMeasures(gdp: IGDPPonderation, raw: boolean, useNaN = false) {

        return async (dbResult: IDBStandardReport[]): Promise<IMeasureTable<ILibMeasureDetails>> => {
            const range: IMeasuresRange = await this.getRange()

            const enterMeasureTable: IMeasureTable<ILibMeasureDetails> = {
                measures: [],
                startYear: range.startYear,
                yearsCount: range.yearsCount
            }

            //// Convert data string to array & get GDP
            const allMeasuresValues = await this.sharedService.dataToArray(
                dbResult, range, gdp, raw
            )
            //// Put years & values as keys for PrimeNG
            allMeasuresValues.forEach(element => {
                let indexYear = range.startYear
                Object.assign(element, element.DATA.reduce((acc, value) => {
                    acc[indexYear++] = useNaN && (value === null || isNaN(value)) ? 'n/a' : value
                    return acc
                }, {}))
                delete element.DATA
            })

            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
            enterMeasureTable.measures = allMeasuresValues as any

            return enterMeasureTable
        }
    }

    /**********************************************************************************************
     * @method formatMeasureDetails
     *********************************************************************************************/
    protected formatMeasureDetails() {

        return async (dbResult: IDBLibMeasureDetails[]): Promise<IMeasureTable<ILibMeasureDetails>> => {
            const range: IMeasuresRange = await this.getRange()
            let ret = {}
            if (dbResult.length !== 0) {
                await this.sharedService.dataToArray(
                    dbResult,
                    range,
                    await this.sharedService.getGDPPonderation(dbResult[0].COUNTRY_ID),
                    true
                )
                ret = dbResult
            }

            return {
                startYear: range.startYear,
                yearsCount: range.yearsCount,
                /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                measures: ret as any
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatMeasures
     *********************************************************************************************/
    private formatMeasures(dbResult: IDBLibMeasureDetails[]): Promise<D[]> {
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        return this.getRange().then(range => this.sharedService.dataToArray(dbResult, range)) as any
    }
}
