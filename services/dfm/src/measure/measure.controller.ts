import { EApps } from 'config'

import {
    IColumn,
    IGDPPonderation,
    IMeasureTable,
    IMeasuresRange,
    ITransparencyReport,
    LibMeasureController
} from '../../../lib/dist/measure'
import { IArchiveParams } from '../../../lib/dist/measure/shared'
import { IError } from '../../../lib/dist'
import { EMeasureViews as MV } from '../../../shared-lib/dist/prelib/measure'

import { ICountryMeasure, IDBCountryMeasure, IMeasureDetails } from '.'
import { IDictionaries } from '../shared'
import { MeasureService } from './measure.service'
import { SharedService } from '../shared/shared.service'
import { TransparencyReportService } from './transparency-report.service'
import { UploadService } from './upload.service'

export class MeasureController extends LibMeasureController<IMeasureDetails, UploadService, MeasureService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps,
        sharedService: SharedService,
        private transparencyReportService = new TransparencyReportService(
            appId, sharedService),
    ) {
        super(
            appId,
            sharedService,
            new MeasureService(appId, sharedService),
            new UploadService(sharedService)
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAllMeasures
     *********************************************************************************************/
    public getAllMeasures() {
        return this.measureService.getAllMeasures().catch((err: IError) => {
            err.method = 'MeasureController.getAllMeasures'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getCountryMeasures
     *********************************************************************************************/
    public async getCountryMeasures(countryId: string, gdp: boolean, archive: IArchiveParams) {
        let gdpPonderation: IGDPPonderation
        if (gdp) {
            gdpPonderation = await this.sharedService.getGDPPonderation(countryId)
        }
        return this.measureService.getCountryMeasures(countryId, archive).then(
            this.formatCountryMeasures(gdpPonderation),
            (err: IError) => {
                err.method = 'MeasureController.getCountryMeasures'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getValueWithGDP
     *********************************************************************************************/
    public getValueWithGDP(countryId: string, year: number, value: number) {
        return this.sharedService.getSingleValueGDP(countryId, year, value).catch(
            (err: IError) => {
                err.method = 'MeasureController.getValueWithGDP'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getMeasureColumns
     *********************************************************************************************/
    public async getMeasureColumns(page: string, year: number): Promise<IColumn[]> {
        const range = await this.getRange()
        let numDefaultYears = 3

        const columns: IColumn[] = [
            { field: 'MEASURE_SID', header: 'ID', width: 65, views: MV.DEFAULT + MV.ALL + MV.DATA },
            { field: 'TITLE', header: 'Title', views: MV.DEFAULT + MV.ALL + MV.DATA },
        ]

        if (page === 'enter') {
            numDefaultYears = 6

            columns.push(
                { field: 'YEAR', header: 'Year of first budgetary impact', views: MV.DEFAULT + MV.ALL + MV.DATA },

                { field: 'STATUS_DESCR', header: 'Status', views: MV.DEFAULT + MV.ALL },
                { field: 'LABELS_DESCR', header: 'Labels', views: MV.DEFAULT + MV.ALL },
                { field: 'DESCR', header: 'Description', views: MV.DEFAULT + MV.ALL },
                { field: 'ADOPT_DATE_YR', header: 'Adoption Year', views: MV.DEFAULT + MV.ALL },
                { field: 'ADOPT_DATE_MH_DESCR', header: 'Adoption Month', views: MV.ALL },
                { field: 'COMMENTS', header: 'General Comments', views: MV.DEFAULT + MV.ALL },
                { field: 'REV_EXP_DESCR', header: 'Rev/Exp', views: MV.DEFAULT + MV.ALL },
                { field: 'ESA_DESCR', header: 'ESA2010 Code', views: MV.DEFAULT + MV.ALL },
                { field: 'OVERVIEW_DESCR', header: 'Overview', views: MV.DEFAULT + MV.ALL },
                { field: 'ONE_OFF_DESCR', header: 'One-off', views: MV.DEFAULT + MV.ALL },
                { field: 'ONE_OFF_TYPE_DESCR', header: 'One-off type', width: 150, views: MV.DEFAULT + MV.ALL },
                { field: 'IS_EU_FUNDED_DESCR', header: 'Funded by EU', views: MV.DEFAULT + MV.ALL },
                { field: 'EU_FUND_DESCR', header: 'EU fund', views: MV.DEFAULT + MV.ALL },
            )
        } else {    // transaparency report
            columns.push(
                { field: 'DESCR', header: 'Description', views: MV.DEFAULT + MV.ALL },
                { field: 'ADOPT_DATE_YR', header: 'Adoption Year', width: 85, views: MV.DEFAULT + MV.ALL },
                { field: 'ESA_ID', header: 'ESA', width: 100, views: MV.DEFAULT + MV.ALL },
                { field: 'ONE_OFF_DESCR', header: 'One-off', width: 85, views: MV.DEFAULT + MV.ALL },
                { field: 'IS_EU_FUNDED_DESCR', header: 'Funded by EU', width: 85, views: MV.DEFAULT + MV.ALL },
            )
        }

        columns.push(
            { field: 'OO_PRINCIPLE_DESCR', header: 'Main principle for one-off classification', views: MV.ALL },
            { field: 'ONE_OFF_DISAGREE_DESCR', header: 'MS Disagrees on one-off treatment', views: MV.ALL },
            { field: 'ONE_OFF_COMMENTS', header: 'Comments on one-off treatment', views: MV.ALL },
        )

        columns.push(
            ...this.yearsRangeToShow(range.startYear, range.startYear + range.yearsCount).map(
                col => {
                    // for years between year - 1 and year + numDefaultYears add them to views: DEFAULT and ALL
                    const colYear = Number(col.field)
                    if (colYear >= year - 1 && colYear < year + numDefaultYears) {
                        col.views += MV.DEFAULT + MV.ALL
                    }
                    return col
                }
            )
        )
        return this.assignColumnOrder(columns)
    }

    /**********************************************************************************************
     * @method saveTransparencyReport
     *********************************************************************************************/
    public saveTransparencyReport(countryId: string, measureSids: number[]): Promise<number> {
        return this.measureService.saveTransparencyReport(countryId, measureSids).catch((err: IError) => {
            err.method = 'MeasureController.saveTransparencyReport'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getTransparencyReport
     *********************************************************************************************/
    public async getTransparencyReport(
        countryId: string, range: IMeasuresRange, roundSid?: number
    ): Promise<ITransparencyReport> {
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        const data = await this.getTransparencyReportMeasures(countryId, true, roundSid, true) as any

        return this.transparencyReportService.generateTransparencyReport(countryId, range, data, roundSid)
            .catch((err: IError) => {
                err.method = 'MeasureController.getTransparencyReport'
                throw err
            })
    }

    /**********************************************************************************************
     * @method getTransparencyReportMeasures
     *********************************************************************************************/
    public async getTransparencyReportMeasures(
        countryId: string, gdp: boolean, roundSid?: number, useNaN = false
    ) {
        let gdpPonderation: IGDPPonderation
        if (gdp) {
            gdpPonderation = await this.sharedService.getGDPPonderation(countryId)
        }

        return this.measureService.getTransparencyReportMeasures(countryId, roundSid).then(
            this.formatEnterMeasures(gdpPonderation, true, useNaN),
            (err: IError) => {
                err.method = 'MeasureController.getTransparencyReportMeasures'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method denormaliseMeasure
     *********************************************************************************************/
    protected denormaliseMeasure(
        {statuses, oneOffPrinciples, revexp, overviews, ...rest}: IDictionaries,
    ) {
        return ({
            STATUS_SID, ONE_OFF_DISAGREE_SID, OO_PRINCIPLE_SID, REV_EXP_SID, ...restMeasure
        }: IMeasureDetails) => ({
            STATUS_DESCR: statuses[STATUS_SID],
            ONE_OFF_DISAGREE_DESCR: rest.oneOff[ONE_OFF_DISAGREE_SID],
            OO_PRINCIPLE_DESCR: oneOffPrinciples[OO_PRINCIPLE_SID].descr,
            REV_EXP_DESCR: revexp[REV_EXP_SID],
            OVERVIEW_DESCR: overviews[rest.esaCodes[restMeasure.ESA_SID].overviewSid],
            ...super.denormaliseMeasure(rest)(restMeasure)
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatCountryMeasures
     *********************************************************************************************/
    private formatCountryMeasures(gdp?: IGDPPonderation) {

        return async (dbResult: IDBCountryMeasure[]): Promise<IMeasureTable<ICountryMeasure>> => {
            const range = await this.getRange()
            return {
                startYear: range.startYear,
                yearsCount: range.yearsCount,
                measures: await this.sharedService.dataToArray(dbResult, range, gdp) as ICountryMeasure[]
            }
        }
    }
}
