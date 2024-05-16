import { EStatusRepo, ICountryStatus } from 'country-status'
import { EApps } from 'config'

import { DashboardHeader, EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { IRoundKeys, IStorage } from '../../../dashboard/src/config/shared-interfaces'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { DxmDashboardController } from '../../../lib/dist/dxm'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IDashboardDatas } from '../../../lib/dist/dashboard'
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

    protected get currentRoundKeys$(): Promise<IRoundKeys> {
        return DashboardApi.getCurrentRoundInfo(this.appId).then(
            ({roundSid, storageSid, storageId, textSid}) =>
                ({roundSid, storageSid, storageId, custTextSid: textSid || null})
        )
    }

    protected get storages$(): Promise<IStorage[]> {
        return DashboardApi.getStorages(this.appId)
    }

    protected get showDfmStatus(): boolean {
        return true
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

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
                return this.dashboardService.archiveCountry(countryId, roundKeys, user)
                    .then(result => result >= 0 ? EErrors.NO_ERROR : result)
        }
        return super.appAction(action, countryId, currentStatusId, roundKeys, user)
    }

    /**********************************************************************************************
     * @method calculateUpdatedRowData
     * @overrides
     *********************************************************************************************/
    protected calculateUpdatedRowData(countryStatus: ICountryStatus): IDashboardDatas {
        const data = {}
        if (countryStatus) {
            data[DashboardHeader.DFM_STATUS] = {
                statusDescr: countryStatus.statusDescr,
                statusId: countryStatus.statusId,
            }
            data[DashboardHeader.TR_STATUS] = {
                statusDescr: countryStatus.statusTrDescr,
                statusId: countryStatus.statusId,
            }
        }
        return data
    }

    /**********************************************************************************************
     * @method checkActionAppStatus
     * @overrides
     *********************************************************************************************/
    protected checkActionAppStatus(action: EDashboardActions, appStatusId: EStatusRepo) {
        switch (action) {
            case EDashboardActions.TR_SUBMIT:
            case EDashboardActions.TR_UNSUBMIT:
                return appStatusId === EStatusRepo.TR_OPENED ? EErrors.NO_ERROR : EErrors.APP_STATUS
            case EDashboardActions.ARCHIVE:
                return [EStatusRepo.OPENED, EStatusRepo.ARCHIVED].includes(appStatusId)
                    ? EErrors.NO_ERROR : EErrors.APP_STATUS
        }
        return super.checkActionAppStatus(action, appStatusId)
    }

    /**********************************************************************************************
     * @method checkActionCtyStatus
     *********************************************************************************************/
    protected checkActionCtyStatus(action: EDashboardActions, ctyStatusId: EStatusRepo, countryId: string) {
        return action === EDashboardActions.ARCHIVE && ctyStatusId === undefined
            ? EErrors.NO_ERROR
            : super.checkActionCtyStatus(action, ctyStatusId, countryId)
    }

    /**********************************************************************************************
     * @method checkActionRoundKeys
     * @overrides
     *********************************************************************************************/
    protected async checkActionRoundKeys(
        action: EDashboardActions, actionRoundKeys: IRoundKeys, currentRoundKeys: IRoundKeys
    ): Promise<EErrors> {
        switch (action) {
            case EDashboardActions.TR_SUBMIT:
            case EDashboardActions.TR_UNSUBMIT:
                if (currentRoundKeys.storageId !== 'FINAL') return EErrors.ROUND_KEYS
                break
            case EDashboardActions.ARCHIVE: {
                const storages = await this.storages$
                if (!storages.find(s => s.storageSid === actionRoundKeys.storageSid)) return EErrors.IGNORE
                break
            }
        }
        return super.checkActionRoundKeys(action, actionRoundKeys, currentRoundKeys)
    }

    /**********************************************************************************************
     * @method getStatusByAction
     * @overrides
     *********************************************************************************************/
    protected getStatusByAction(action: EDashboardActions): EStatusRepo {
        switch(action) {
            case EDashboardActions.TR_SUBMIT: return EStatusRepo.TR_SUBMITTED
            case EDashboardActions.TR_UNSUBMIT: return EStatusRepo.TR_OPENED
        }
        return super.getStatusByAction(action)
    }
}
