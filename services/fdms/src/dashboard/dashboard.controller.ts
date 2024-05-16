import { CountryStatusApi, DashboardApi, EucamLightApi, NotificationApi } from '../../../lib/dist/api'
import { DashboardHeader, EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'
import { EStatusRepo, ICtyAccepted } from 'country-status'
import { IDashboard, IDashboardRow } from '../../../lib/dist/dashboard'
import { Level, LoggingService } from '../../../lib/dist'
import { DashboardService } from './dashboard.service'
import { EApps } from 'config'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { ENotificationTemplate } from 'notification'
import { ForecastType } from '../../../fdms/src/forecast/shared-interfaces'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'
import { LibDashboardController } from '../../../lib/dist/dashboard/lib-dashboard.controller'
import { SharedService } from '../shared/shared.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class DashboardController extends LibDashboardController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps,
        logs: LoggingService,
        private readonly dashboardService: DashboardService,
        private readonly sharedService: SharedService,
    ) {
        super(appId, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected get currentRoundKeys$(): Promise<IRoundKeys> {
        return DashboardApi.getCurrentRoundInfo(this.appId).then(
            ({roundSid, storageSid}) => ({roundSid, storageSid, custTextSid: null})
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryLastAccepted
     *********************************************************************************************/
    public getCountryLastAccepted(
        appId: EApps, userCountries: string[], onlyFullStorage = false, onlyFullRound = false,
    ): Promise<Map<string, ICtyAccepted>> {
        return (appId === this.appId
            ? Promise.resolve([] as ICtyAccepted[])
            : CountryStatusApi.getCountryLastAccepted(EApps.FDMS, userCountries, onlyFullStorage, onlyFullRound)
        ).then(countries =>
            countries.reduce((acc, country) =>
                acc.set(country.countryId, country), new Map<string, ICtyAccepted>()
            )
        )
    }

    /**********************************************************************************************
     * @method getDashboard
     *********************************************************************************************/
    public async getDashboard(isAdmin: boolean, userCountries: string[]): Promise<IDashboard> {
        const dashboard: IDashboard = { countries: [], rows: {} }

        if (isAdmin) userCountries = []
        else if (!userCountries.length) return dashboard

        const [countryStatuses, eucamVersion, aggAccepted, countryUploads, lastAccepted] = await Promise.all([
            CountryStatusApi.getCountryStatuses(this.appId, userCountries),
            EucamLightApi.getEucamLightVersionFormatted().catch(() => null),
            CountryStatusApi.getCountryLastAccepted(EApps.FDMS, ['AGG'], true, true).then(accepted => {
                const ctyAccepted: ICtyAccepted = accepted[0]
                return DashboardApi.getRoundInfo(
                    EApps.FDMS, ctyAccepted.roundSid, ctyAccepted.storageSid
                ).then(ri => `${ri.periodDescr.toUpperCase()} ${ri.year} ${ri.storageDescr}`
                            + (ctyAccepted.lastAcceptedDate ?
                               ` | ${new Date(ctyAccepted.lastAcceptedDate).toLocaleString()}` : '')
                )
            }),
            this.dashboardService.getCountryUploads(this.appId, userCountries).then(uploads =>
                uploads.reduce((acc, upload) =>
                    acc.set(upload.COUNTRY_ID, upload.UPDATE_DATE), new Map<string, Date>()
                )
            ),
            this.getCountryLastAccepted(EApps.FDMS, userCountries),
        ])

        dashboard.countries = countryStatuses.map(({countryId, countryDescr}) => ({countryId, countryDescr}))
        dashboard.globals = [['Last accepted forecast aggregation', aggAccepted]]
        if (eucamVersion) dashboard.globals.push(eucamVersion)

        dashboard.rows = countryStatuses.reduce((acc, c) => {
            const row: IDashboardRow = {
                lastChangeDate: c.lastChangeDate,
                lastChangeUser: c.lastChangeUser,
                data: {},
                changesLog: {}
            }
            row.changesLog[DashboardHeader.LAST_UPLOAD] = countryUploads.get(c.countryId)
            row.changesLog[DashboardHeader.LAST_ACCEPTED] = lastAccepted.get(c.countryId)?.lastAcceptedDate

            row.data[DashboardHeader.CURRENT_STATUS] = {
                statusDescr: c.statusDescr,
                statusId: c.statusId
            }

            acc[c.countryId] = row
            return acc
        }, {})

        return dashboard
    }

    /**********************************************************************************************
     * @method presubmitCheck
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    public presubmitCheck(countryId: string, roundSid: number): Promise<number> {
        return Promise.resolve(0)
    }

    /**********************************************************************************************
     * @method performMultiAction
     *********************************************************************************************/
    public async performMultiAction(
        action: EDashboardActions, countryIds: string[], roundKeys: IRoundKeys, comment: string, userId: string
    ): Promise<number> {
        if (!countryIds.length) return EErrors.NO_COUNTRIES

        let error: EErrors
        const newStatusId: EStatusRepo = this.getStatusByAction(action)
        if (!newStatusId) return EErrors.CTY_ACTION

        const [appStatusId, currentRoundKeys, ctyStatusesMap] = await Promise.all([
            DashboardApi.getApplicationStatus(this.appId),
            this.currentRoundKeys$,
            CountryStatusApi.getCountryStatuses(this.appId, countryIds, roundKeys).then(
                statuses => statuses.reduce((acc, {countryId, statusId}) => (acc[countryId] = statusId, acc), {})
            )
        ])

        error = this.checkActionAppStatus(action, appStatusId)
        if (error !== EErrors.NO_ERROR) {
            this.logs.log(`checkActionAppStatus error: ${error} (${action}, ${appStatusId})`)
            return error
        }

        error = await this.checkActionRoundKeys(action, roundKeys, currentRoundKeys)
        if (error !== EErrors.NO_ERROR) {
            this.logs.log(`checkActionRoundKeys error: ${error} (${action}, ${roundKeys}, ${currentRoundKeys})`)
            return error
        }

        error = countryIds.reduce((err: EErrors, countryId) => {
            const check = this.checkActionCtyStatus(action, ctyStatusesMap[countryId], countryId)
            if (check < 0) {
                err = check
                this.logs.log(`checkMultiActionCtyStatus error: ${err} (${countryId}, ${action}, ${ctyStatusesMap[countryId]})`)
            }
            return err
        }, EErrors.NO_ERROR)
        if (error !== EErrors.NO_ERROR) return error

        return CountryStatusApi.setManyCountriesStatus(
            this.appId,
            countryIds,
            {
                oldStatusId: null,
                newStatusId,
                roundKeys,
                userId,
                comment,
            }
        )
    }

    /**********************************************************************************************
     * @method transferToScopax
     *********************************************************************************************/
    public async transferToScopax(roundSid: number, storageSid: number): Promise<number> {
        const isOgFull = await this.isOgFull(roundSid, storageSid)
        let result = EErrors.NOT_FULL_OG
        if (isOgFull) {
            result = await this.dashboardService.transferAmecoIndicatorsToScopax(roundSid, storageSid)
            this.logs.log(
                `Transferred ${result} ameco indicators to SCOPAX`,
                Level.INFO,
            )
        }
        return result
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method appAction
     *********************************************************************************************/
    protected async appAction(
        action: EDashboardActions, countryId: string, currentStatusId: EStatusRepo, roundKeys: IRoundKeys, user: string
    ): Promise<number> {
        if (countryId === 'AGG' && action === EDashboardActions.ACCEPT) {
            await this.acceptAggregates(roundKeys, user)
        }
        return super.appAction(action, countryId, currentStatusId, roundKeys, user)
    }

    /**********************************************************************************************
     * @method checkActionCtyStatus
     *********************************************************************************************/
    protected checkActionCtyStatus(action: EDashboardActions, ctyStatusId: EStatusRepo, countryId: string) {
        return ['AGG', 'AGGIE', 'TCE'].includes(countryId) &&
                [EDashboardActions.ACCEPT, EDashboardActions.REJECT].includes(action)
            ? EErrors.NO_ERROR
            : super.checkActionCtyStatus(action, ctyStatusId, countryId)
    }

    /**********************************************************************************************
     * @method getStatusByAction
     * @overrides
     *********************************************************************************************/
    protected getStatusByAction(action: EDashboardActions): EStatusRepo {
        switch(action) {
            case EDashboardActions.ACCEPT: return EStatusRepo.ACCEPTED
            case EDashboardActions.UNACCEPT: return EStatusRepo.ACTIVE
            case EDashboardActions.REJECT: return EStatusRepo.REJECTED
        }
        return super.getStatusByAction(action)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isOgFull
     *********************************************************************************************/
    private async isOgFull(roundSid: number, storageSid: number): Promise<boolean> {
        return await this.sharedService.isOgFull('EA19', roundSid, storageSid)
    }

    /**********************************************************************************************
     * @method acceptAggregates
     *********************************************************************************************/
    private async acceptAggregates(roundKeys: IRoundKeys, user: string) {

        const isOgFull = await this.isOgFull(roundKeys.roundSid, roundKeys.storageSid)
        if (isOgFull) {
            const xfered = await this.dashboardService.transferAmecoIndicatorsToScopax(
                roundKeys.roundSid, roundKeys.storageSid,
            )
            this.logs.log(
                `ACCEPT aggregates with full OG results. Transferred ${ xfered } ameco indicators to SCOPAX`,
                Level.INFO,
            )
        } else {
            this.logs.log(
                `ACCEPT aggregates with approximate OG results.`,
                Level.INFO,
            )
        }

        await this.sharedService.markForecast(ForecastType.LATEST_AGGREGATES, user).then(
            () => this.notifyAggregatesAccepted(user)
        )
    }

    /**********************************************************************************************
     * @method notifyAggregatesAccepted
     *********************************************************************************************/
    private async notifyAggregatesAccepted(user: string) {
        await DashboardApi.getCurrentRoundInfo(this.appId).then(
            roundInfo =>
                NotificationApi.sendCnsNotificationWithTemplate(
                    ENotificationTemplate.FDMS_AGGREGATES_ACCEPTATION,
                    {
                        notificationGroupCode: 'FC_NEW_ROUND_STORAGE',
                        params: {
                            '{ROUND_DESC}': roundInfo.roundDescr,
                            '{STORAGE_DESC}': roundInfo.storageDescr,
                        }
                    },
                    user, this.appId, true
                ).catch(err => {
                    this.logs.log(
                        `Failed sending "aggregates acceptation" CNS notification: ${err.toString()}`,
                        Level.ERROR
                    )
                })
        )
    }
}
