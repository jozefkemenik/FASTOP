import { EStatusRepo, IAction, ICountryStatus, ISetCountryStatusResult } from 'country-status'
import { EApps } from 'config'

import { DashboardHeader, EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

import { ICtyActionResult, IDashboard, IDashboardDatas, IDashboardRow } from '.'
import { CountryStatusApi } from '../api/country-status.api'
import { DashboardApi } from '../api/dashboard.api'
import { IError } from '../error.service'
import { LoggingService } from '../logging.service'

export abstract class LibDashboardController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _actions: IAction[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        protected readonly appId: EApps,
        protected readonly logs: LoggingService,
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected get currentRoundKeys$(): Promise<IRoundKeys> {
        return DashboardApi.getCurrentRoundInfo(this.appId).then(
            ({roundSid}) => ({roundSid, storageSid: null, custTextSid: null})
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActions
     *********************************************************************************************/
    public async getActions(): Promise<IAction[]> {
        if (!this._actions) {
            const actions = await CountryStatusApi.getActions()
            this._actions = actions.filter(action => this.getStatusByAction(action.ACTION_ID))
        }
        return this._actions
    }

    /**********************************************************************************************
     * @method getDashboard
     *********************************************************************************************/
    public abstract getDashboard(isAdmin: boolean, userCountries: string[]): Promise<IDashboard>

    /**********************************************************************************************
     * @method performAction
     *********************************************************************************************/
    public async performAction(
        action: EDashboardActions,
        countryId: string,
        currentStatusId: EStatusRepo,
        roundKeys: IRoundKeys,
        comment: string,
        userId: string,
        confirmed = false
    ): Promise<ICtyActionResult> {

        let error: EErrors
        const newStatusId: EStatusRepo = this.getStatusByAction(action)
        if (!newStatusId) return {result: EErrors.CTY_ACTION}

        error = this.checkActionCtyStatus(action, currentStatusId, countryId)
        if (error !== EErrors.NO_ERROR) {
            this.logs.log(`checkActionCtyStatus error: ${error} (${action}, ${currentStatusId})`)
            return {result: error}
        }

        const [appStatusId, currentRoundKeys] = await Promise.all([
            DashboardApi.getApplicationStatus(this.appId),
            this.currentRoundKeys$,
        ])

        error = this.checkActionAppStatus(action, appStatusId)
        if (error !== EErrors.NO_ERROR) {
            this.logs.log(`checkActionAppStatus error: ${error} (${action}, ${appStatusId})`)
            return {result: error}
        }

        error = await this.checkActionRoundKeys(action, roundKeys, currentRoundKeys)
        if (error !== EErrors.NO_ERROR) {
            this.logs.log(`checkActionRoundKeys error: ` +
                `${error} (${action}, ${JSON.stringify(roundKeys)}, ${JSON.stringify(currentRoundKeys)})`
            )
            return {result: error}
        }

        error = await this.appAction(action, countryId, currentStatusId, currentRoundKeys, userId, confirmed)
        if (error !== EErrors.NO_ERROR) {
            this.logs.log(`appAction error: ${error} (${action})`)
            return {result: error}
        }

        const setCountryStatusResult: ISetCountryStatusResult = await CountryStatusApi.setCountryStatus(
            this.appId,
            countryId,
            {
                oldStatusId: currentStatusId,
                newStatusId,
                roundKeys: currentRoundKeys,
                userId,
                comment,
            }
        )

        let updatedRow: IDashboardRow
        if (setCountryStatusResult.countryStatus) {
            updatedRow = Object.assign({
                lastChangeDate: setCountryStatusResult.countryStatus.lastChangeDate,
                lastChangeUser: setCountryStatusResult.countryStatus.lastChangeUser,
                canSubmit: true,
                data: this.calculateUpdatedRowData(setCountryStatusResult.countryStatus),
            }, await this.getRowChildProperties(countryId, currentRoundKeys))
        }

        const actionResult: ICtyActionResult = {
            result: setCountryStatusResult.result,
            updatedRow,
        }

        return actionResult
    }

    /**********************************************************************************************
     * @method presubmitCheck
     *********************************************************************************************/
    public abstract presubmitCheck(countryId: string, roundSid: number): Promise<number>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method appAction
     *********************************************************************************************/
    protected async appAction(
        /* eslint-disable @typescript-eslint/no-unused-vars */
        action: EDashboardActions,
        countryId: string,
        currentStatusId: EStatusRepo,
        roundKeys: IRoundKeys,
        user: string,
        confirmed?: boolean
        /* eslint-enable @typescript-eslint/no-unused-vars */
    ): Promise<number> {
        return EErrors.NO_ERROR
    }

    /**********************************************************************************************
     * @method calculateUpdatedRowData
     *********************************************************************************************/
    protected calculateUpdatedRowData(countryStatus: ICountryStatus): IDashboardDatas {
        const data = {}
        if (countryStatus) {
            data[DashboardHeader.CURRENT_STATUS] = {
                statusDescr: countryStatus.statusDescr,
                statusId: countryStatus.statusId,
            }
        }
        return data
    }

    /**********************************************************************************************
     * @method checkActionAppStatus
     *********************************************************************************************/
    protected checkActionAppStatus(action: EDashboardActions, appStatusId: EStatusRepo) {
        return appStatusId === EStatusRepo.OPENED ? EErrors.NO_ERROR : EErrors.APP_STATUS
    }

    /**********************************************************************************************
     * @method checkActionCtyStatus
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected checkActionCtyStatus(action: EDashboardActions, ctyStatusId: EStatusRepo, countryId: string) {
        return this.getActionAllowedStatuses(action).includes(ctyStatusId) ? EErrors.NO_ERROR : EErrors.CTY_STATUS
    }

    /**********************************************************************************************
     * @method checkActionRoundKeys
     *********************************************************************************************/
    protected async checkActionRoundKeys(
        action: EDashboardActions, actionRoundKeys: IRoundKeys, currentRoundKeys: IRoundKeys
    ): Promise<EErrors> {
        actionRoundKeys = actionRoundKeys ?? {} as IRoundKeys
        return Object.getOwnPropertyNames(actionRoundKeys).some(
            key => currentRoundKeys[key] && actionRoundKeys[key] !== currentRoundKeys[key]
        ) ? EErrors.ROUND_KEYS : EErrors.NO_ERROR
    }

    /**********************************************************************************************
     * @method exceptionHandler
     *********************************************************************************************/
    protected exceptionHandler(methodName: string) {
        return (err: IError) => {
            err.method = `LibDashboardController.${methodName}`
            throw err
        }
    }

    /**********************************************************************************************
     * @method getActionAllowedStatuses
     *********************************************************************************************/
    protected getActionAllowedStatuses(action: EDashboardActions): EStatusRepo[] {
        switch(action) {
            case EDashboardActions.SUBMIT: return [EStatusRepo.ACTIVE, EStatusRepo.REJECTED]
            case EDashboardActions.UNSUBMIT: return [EStatusRepo.SUBMITTED]
            case EDashboardActions.TR_SUBMIT: return [EStatusRepo.TR_OPENED, EStatusRepo.ARCHIVED]
            case EDashboardActions.TR_UNSUBMIT: return [EStatusRepo.TR_SUBMITTED]
            case EDashboardActions.VALIDATE: return [EStatusRepo.SUBMITTED]
            case EDashboardActions.UNVALIDATE: return [EStatusRepo.VALIDATED]
            case EDashboardActions.ACCEPT: return [EStatusRepo.SUBMITTED]
            case EDashboardActions.UNACCEPT: return [EStatusRepo.ACCEPTED, EStatusRepo.SUBMITTED]
            case EDashboardActions.REJECT: return [EStatusRepo.SUBMITTED]
            case EDashboardActions.ARCHIVE: return [EStatusRepo.SUBMITTED, EStatusRepo.ARCHIVED]
            default: return []
        }
    }

    /**********************************************************************************************
     * @method getRowChildProperties
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars, @typescript-eslint/no-explicit-any */
    protected async getRowChildProperties(countryId: string, roundKeys: IRoundKeys): Promise<any> {
        return {}
    }

    /**********************************************************************************************
     * @method getStatusByAction
     *********************************************************************************************/
    protected getStatusByAction(action: EDashboardActions): EStatusRepo {
        switch(action) {
            case EDashboardActions.SUBMIT: return EStatusRepo.SUBMITTED
            case EDashboardActions.UNSUBMIT: return EStatusRepo.ACTIVE
        }
    }
}
