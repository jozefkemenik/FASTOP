import { EStatusRepo, ICountryStatus } from 'country-status'
import { EApps } from 'config'

import { DashboardHeader, EDashboardActions } from '../../../../shared-lib/dist/prelib/dashboard'
import { CountryStatusApi } from '../../api/country-status.api'

import { IDashboard, IDashboardRow } from '../../dashboard'
import { DxmDashboardService } from './dxm-dashboard.service'
import { LibDashboardController } from '../../dashboard/lib-dashboard.controller'
import { LoggingService } from '../../logging.service'

export abstract class DxmDashboardController<D extends DxmDashboardService> extends LibDashboardController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        appId: EApps,
        logs: LoggingService,
        protected readonly dashboardService: D
    ) {
        super(appId, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected abstract get showDfmStatus(): boolean

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDashboard
     *********************************************************************************************/
    public async getDashboard(isAdmin: boolean, userCountries: string[]): Promise<IDashboard> {
        const dashboard: IDashboard = { countries: [], rows: {} }

        if (isAdmin) userCountries = []
        else if (!userCountries.length) return dashboard

        const [dfmStatuses, drmStatuses] = await Promise.all([
            CountryStatusApi.getCountryStatuses(EApps.DFM, userCountries)
                .catch(this.exceptionHandler('getDfmStatuses')),
            CountryStatusApi.getCountryStatuses(EApps.DRM, userCountries)
                .catch(this.exceptionHandler('getDrmStatuses')),
        ])

        dashboard.countries = dfmStatuses.map(({countryId, countryDescr}) => ({countryId, countryDescr}))
        dashboard.rows = dfmStatuses.reduce((acc, c) => {
            const row: IDashboardRow = {
                lastChangeDate: c.lastChangeDate,
                lastChangeUser: c.lastChangeUser,
                data: {},
            }

            if (this.showDfmStatus) {
                row.data[DashboardHeader.DFM_STATUS] = {
                    statusDescr: c.statusDescr,
                    statusId: c.statusId
                }
            }

            row.data[DashboardHeader.TR_STATUS] = {
                statusDescr: c.statusTrDescr,
                statusId: c.statusId
            }

            acc[c.countryId] = row
            return acc
        }, {})

        drmStatuses.forEach(c => {
            const row = dashboard.rows[c.countryId]
            row.data[DashboardHeader.DRM_STATUS] = {
                statusDescr: c.statusDescr,
                statusId: c.statusId
            }
            Object.assign(row, this.getLatestChangeInfo(row, c))
        })

        return dashboard
    }

    /**********************************************************************************************
     * @method presubmitCheck
     *********************************************************************************************/
    public presubmitCheck(countryId: string, roundSid: number): Promise<number> {
        return this.dashboardService.presubmitCheck(countryId, roundSid)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getStatusByAction
     * @overrides
     *********************************************************************************************/
    protected getStatusByAction(action: EDashboardActions): EStatusRepo {
        switch(action) {
            case EDashboardActions.ARCHIVE: return EStatusRepo.ARCHIVED
        }
        return super.getStatusByAction(action)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getLatestChangeInfo
     *********************************************************************************************/
    private getLatestChangeInfo(current: IDashboardRow, update: ICountryStatus) {
        if (update.lastChangeDate) {
            if (!current.lastChangeDate || new Date(update.lastChangeDate) > new Date(current.lastChangeDate)) {
                return {
                    lastChangeDate: update.lastChangeDate,
                    lastChangeUser: update.lastChangeUser
                }
            }
        }
        return {}
    }
}
