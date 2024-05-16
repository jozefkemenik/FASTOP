import { EApps } from 'config'

import { IColumn, ILibMeasureWizardUpload } from '../../../lib/dist/measure'
import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'
import { FDMeasureController } from '../../../lib/dist/measure/fisc-drm/measure/fd-measure.controller'
import { IError } from '../../../lib/dist/error.service'
import { EMeasureViews as MV } from '../../../shared-lib/dist/prelib/measure'

import { IMeasureDetails, IWizardMeasureDetails } from '.'
import { IDictionaries } from '../shared'
import { MeasureService } from './measure.service'
import { SharedService } from '../shared/shared.service'
import { UploadService } from './upload.service'

export class MeasureController extends FDMeasureController<IWizardMeasureDetails, UploadService, MeasureService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps,
        sharedService: SharedService,
    ) {
        super(
            appId,
            sharedService,
            new MeasureService(sharedService),
            new UploadService(appId, sharedService)
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
    * @method getMeasureColumns
    *********************************************************************************************/
    public async getMeasureColumns(page: string, year: number): Promise<IColumn[]> {
        const range = await this.getRange()
        const numDefaultYears = 6

        const columns: IColumn[] = [
            { field: 'MEASURE_SID', header: 'ID', width: 65, views: MV.DEFAULT + MV.ALL + MV.DATA },
            { field: 'TITLE', header: 'Title', views: MV.DEFAULT + MV.ALL + MV.DATA },

            { field: 'DESCR', header: 'Description', views: MV.DEFAULT + MV.ALL },
            { field: 'SOURCE_DESCR', header: 'Source', views: MV.DEFAULT + MV.ALL },
            { field: 'ESA_ID', header: 'ESA', views: MV.DEFAULT + MV.ALL },
            { field: 'ACC_PRINCIP_DESCR', header: 'Account principle', views: MV.DEFAULT + MV.ALL },
            { field: 'ADOPT_STATUS_DESCR', header: 'Adoption status', width: 150, views: MV.DEFAULT + MV.ALL },
        ]

        columns.push(
            ...this.yearsRangeToShow(range.startYear, range.startYear + range.yearsCount).map(
                col => {
                    // for years between year - 1 and year + numDefaultYears add them to views: DEFAULT and ALL
                    const colYear = Number(col.field)
                    if (colYear >= year - 1 && colYear < year + numDefaultYears) {
                        col.views += MV.DEFAULT + MV.ALL
                    }
                    return col
                })
        )
        return this.assignColumnOrder(columns)
    }

    /**********************************************************************************************
     * @method recalculateAggregatedMeasures
     *********************************************************************************************/
    public async recalculateAggregatedMeasures(countryId: string): Promise<number> {
        return this.measureService.recalculateAggregated(countryId)
    }

    /**********************************************************************************************
     * @method saveMeasure
     * @overrides
     *********************************************************************************************/
    public saveMeasure(measure: IMeasureDetails) {
        return super.saveMeasure(measure).then(
            result => {
                if (result > 0) {
                    CountryStatusApi.setStatusChangeDate(this.appId, measure.COUNTRY_ID, {statusChange: 'Input'})
                }
                return result
            },
            (err: IError) => {
                err.method = 'MeasureController.saveMeasure'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method uploadWizardMeasures
     * @overrides
     *********************************************************************************************/
    public uploadWizardMeasures(
        countryId: string, roundSid: number, uploadMeasures: ILibMeasureWizardUpload
    ): Promise<number> {
        return super.uploadWizardMeasures(countryId, roundSid, uploadMeasures).then(
            result => {
                if (result > 0) {
                    CountryStatusApi.setStatusChangeDate(this.appId, countryId, {statusChange: 'Input'})
                }
                return result
            },
            (err: IError) => {
                err.method = 'MeasureController.uploadWizardMeasures'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods /////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method denormaliseMeasure
     *********************************************************************************************/
     protected denormaliseMeasure({dbpSources, ...rest}: IDictionaries) {
        return ({SOURCE_SID, ...restMeasure}: IMeasureDetails) => ({
            SOURCE_DESCR: dbpSources[SOURCE_SID],
            ...super.denormaliseMeasure(rest)(restMeasure)
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
