import { EStatusRepo, ICountryStatus, ICtyStatusChanges } from 'country-status'
import { EApps } from 'config'

import { CountryStatusApi } from '../../api/country-status.api'
import { EDashboardActions } from '../../../../shared-lib/dist/prelib/dashboard'
import { EErrors } from '../../../../shared-lib/dist/prelib/error'
import { EucamLightApi } from '../../api/eucam-light.api'
import { IDashboard } from '../../dashboard'
import { IRoundKeys } from '../../../../dashboard/src/config/shared-interfaces'
import { LibDashboardController } from '../../dashboard/lib-dashboard.controller'
import { LoggingService } from '../../logging.service'

import { FiscDashboardService } from './fisc-dashboard.service'

export class FiscDashboardController extends LibDashboardController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps,
        logs: LoggingService,
        private readonly dashboardService = new FiscDashboardService(appId),
    ) {
        super(appId, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDashboard
     *********************************************************************************************/
    public async getDashboard(isAdmin: boolean, userCountries: string[]): Promise<IDashboard> {
        let countryStatuses: Promise<ICountryStatus[]>
        let statusChanges: Promise<ICtyStatusChanges[]>

        if (!userCountries.length && !isAdmin) {
            countryStatuses = Promise.resolve([])
            statusChanges = Promise.resolve([])
        } else {
            if (isAdmin) userCountries = []
            countryStatuses = CountryStatusApi.getCountryStatuses(this.appId, userCountries)
            statusChanges = CountryStatusApi.getStatusChanges(this.appId, userCountries)
        }

        return Promise.all([
            countryStatuses,
            statusChanges,
            this.dashboardService.getDashboardGlobalDates(),
            EucamLightApi.getEucamLightVersionFormatted().catch(() => null),
        ]).then(
            this.formatStatusChanges,
            this.exceptionHandler('getDashboard')
        )
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
     * @method appAction
     *********************************************************************************************/
    protected async appAction(
        action: EDashboardActions,
        countryId: string,
        currentStatusId: EStatusRepo,
        roundKeys: IRoundKeys,
        user: string,
        confirmed: boolean,
    ): Promise<number> {
        if (action === EDashboardActions.VALIDATE && !confirmed) {
            const hasMissingData = await this.dashboardService.hasMissingData(countryId, roundKeys.roundSid)
            return hasMissingData ? EErrors.NEEDS_CONFIRMATION : EErrors.NO_ERROR
        }
        return EErrors.NO_ERROR
    }

    /**********************************************************************************************
     * @method getRowChildProperties
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected async getRowChildProperties(countryId: string, roundKeys: IRoundKeys): Promise<any> {
        /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
        const {countryId: notUsed, ...logs} =
            (await CountryStatusApi.getStatusChanges(this.appId, [countryId], roundKeys))[0]
        return {changesLog: logs}
    }

    /**********************************************************************************************
     * @method getStatusByAction
     * @overrides
     *********************************************************************************************/
    protected getStatusByAction(action: EDashboardActions): EStatusRepo {
        switch(action) {
            case EDashboardActions.VALIDATE: return EStatusRepo.VALIDATED
            case EDashboardActions.UNVALIDATE: return EStatusRepo.SUBMITTED
        }
        return super.getStatusByAction(action)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatStatusChanges
     *********************************************************************************************/
    private formatStatusChanges = (
        [countryStatuses, statusChanges, globalDates, eucamVersion]:
            [ICountryStatus[], ICtyStatusChanges[], string[], [string, string]]
    ): IDashboard => {

        const rows = countryStatuses.reduce((acc, {countryId, statusId, statusDescr}) => {
            acc[countryId] = {data: {currentStatus: {statusId, statusDescr}}}
            return acc
        }, {})

        const globals: Array<[string, string]> = [
            ['Ameco last upload', globalDates[0]],
            ['Linked tables last upload', globalDates[1]],
            ['Fiscal parameters last upload', globalDates[2]],
        ]
        if (eucamVersion) globals.push(eucamVersion)
        return {
            countries: countryStatuses.map(({countryId, countryDescr}) => ({countryId, countryDescr})),
            rows: statusChanges.reduce((acc, {countryId, ...logs}) => {
                if (acc[countryId]) Object.assign(acc[countryId], {changesLog: logs})
                return acc
            }, rows),
            globals,
        }
    }
}
