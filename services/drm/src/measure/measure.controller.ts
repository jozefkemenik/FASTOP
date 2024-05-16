import { EStatusRepo, ICountryStatus } from 'country-status'
import { EApps } from 'config'

import { IColumn, IMeasuresRange } from '../../../lib/dist/measure'
import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'
import { DfmApi } from '../../../lib/dist/api/dfm.api'
import { FDMeasureController } from '../../../lib/dist/measure/fisc-drm/measure/fd-measure.controller'
import { ICountry } from '../../../lib/dist/menu'
import { IError } from '../../../lib/dist'
import { EMeasureViews as MV } from '../../../shared-lib/dist/prelib/measure'

import { IWizardMeasureDetails } from '.'
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
            new MeasureService(appId, sharedService),
            new UploadService(appId, sharedService),
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method copyPreviousRoundMeasures
     *********************************************************************************************/
     public copyPreviousRoundMeasures(roundSid: number, countryId: string): Promise<number> {
        return this.measureService.copyPreviousRoundMeasures(roundSid, countryId)
            .catch((err: IError) => {
                err.method = 'MeasureController.copyPreviousRoundMeasures'
                throw err
            })
    }

    /**********************************************************************************************
    * @method getMeasureColumns
    *********************************************************************************************/
    public async getMeasureColumns(page: string, year: number): Promise<IColumn[]> {
        const range = await this.getRange()
        const numDefaultYears = 7

        const columns: IColumn[] = [
            { field: 'MEASURE_SID', header: 'ID', width: 65, views: MV.DEFAULT + MV.ALL + MV.DATA },
            { field: 'TITLE', header: 'Title', views: MV.DEFAULT + MV.ALL + MV.DATA },
            { field: 'YEAR', header: 'Year of first budgetary impact', views: MV.DEFAULT + MV.ALL + MV.DATA },

            { field: 'LABELS_DESCR', header: 'Labels', views: MV.DEFAULT + MV.ALL },
            { field: 'DESCR', header: 'Description', views: MV.DEFAULT + MV.ALL },
            { field: 'ESA_ID', header: 'ESA', views: MV.DEFAULT + MV.ALL },
            { field: 'ONE_OFF_DESCR', header: 'One-off', views: MV.DEFAULT + MV.ALL },
            { field: 'ONE_OFF_TYPE_DESCR', header: 'One-off type', width: 150, views: MV.DEFAULT + MV.ALL },
            { field: 'IS_EU_FUNDED_DESCR', header: 'Funded by EU', views: MV.DEFAULT + MV.ALL },
            { field: 'EU_FUND_DESCR', header: 'EU fund', views: MV.DEFAULT + MV.ALL },
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
     * @method getSubmittedCountries
     *********************************************************************************************/
    public getSubmittedCountries(): Promise<ICountry[]> {
        return CountryStatusApi.getCountryStatuses(this.appId, [])
            .then(statuses => statuses
                .filter(MeasureController.isCountrySubmitted)
                .map(({countryId, countryDescr}) => ({COUNTRY_ID: countryId, DESCR: countryDescr} as ICountry))
            )
    }

    /**********************************************************************************************
     * @method getTransparencyReport
     *********************************************************************************************/
    public getTransparencyReport(countryId: string, range: IMeasuresRange, roundSid: number) {
        return DfmApi.getTransparencyReport(countryId, range, roundSid)
    }

    /**********************************************************************************************
     * @method isAnyCountrySubmitted
     *********************************************************************************************/
    public isAnyCountrySubmitted(countryIds: string[], roundSid?: number): Promise<boolean> {
        return CountryStatusApi.getCountryStatuses(this.appId, countryIds, {roundSid})
            .then(statuses => statuses.some(MeasureController.isCountrySubmitted))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isCountrySubmitted
     *********************************************************************************************/
    private static isCountrySubmitted(countryStatus: ICountryStatus): boolean {
        return countryStatus.statusId !== EStatusRepo.ACTIVE
    }
}
