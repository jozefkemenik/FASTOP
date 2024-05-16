import { EStatusRepo, ICountryStatus } from 'country-status'
import { EApps } from 'config'

import { DashboardHeader, EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { DxmDashboardController } from '../../../lib/dist/dxm'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IDashboardDatas } from '../../../lib/dist/dashboard'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'
import { LoggingService } from '../../../lib/dist'

import { DashboardService } from './dashboard.service'

export class DashboardController extends DxmDashboardController<DashboardService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, logs: LoggingService, dashboardService: DashboardService) {
        super(appId, logs, dashboardService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected get showDfmStatus(): boolean {
        return false
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method appAction
     * @overrides
     *********************************************************************************************/
    protected appAction(
        action: EDashboardActions, countryId: string, currentStatusId: EStatusRepo, roundKeys: IRoundKeys, user: string
    ): Promise<number> {

        switch (action) {
            case EDashboardActions.ARCHIVE:
                return this.dashboardService.archiveCountry(countryId, roundKeys.roundSid)
                    .then(result => result >= 0 ? EErrors.NO_ERROR : result)
        }
        return super.appAction(action, countryId, currentStatusId, roundKeys, user)
    }

    /**********************************************************************************************
     * @method calculateUpdatedRowData
     *********************************************************************************************/
    protected calculateUpdatedRowData(countryStatus: ICountryStatus): IDashboardDatas {
        const data = {}
        if (countryStatus) {
            data[DashboardHeader.DRM_STATUS] = {
                statusDescr: countryStatus.statusDescr,
                statusId: countryStatus.statusId,
            }
        }
        return data
    }
}
