import { CountryStatusApi, DashboardApi, DrmApi, FdmsApi } from '../../../lib/dist/api'
import {
    IActivateRoundValidation,
    IBaseRoundInfo,
    ICustomRoundResult,
    INewRoundResult,
    INewRoundValidation,
    INextRoundInfo,
    IPeriod
} from '.'
import { EApps } from 'config'
import { EStatusRepo } from 'country-status'
import { RoundService } from './round.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class RoundController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly roundService: RoundService,
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getNextRoundInfo
     *********************************************************************************************/
    public async getNextRoundInfo(): Promise<INextRoundInfo> {
        return this.roundService.getNextRoundInfo()
    }

    /**********************************************************************************************
     * @method getRounds
     *********************************************************************************************/
    public async getRounds(): Promise<IBaseRoundInfo[]> {
        return this.roundService.getRounds()
    }

    /**********************************************************************************************
     * @method checkNewRound
     *********************************************************************************************/
    public async checkNewRound(year: number, periodSid: number): Promise<INewRoundValidation> {
        return this.roundService.checkNewRound(year, periodSid)
    }

    /**********************************************************************************************
     * @method createNewRound
     *********************************************************************************************/
    public async createNewRound(year: number, periodSid: number, roundDesc: string): Promise<INewRoundResult> {
        return this.roundService.createNewRound(year, periodSid, roundDesc)
    }

    /**********************************************************************************************
     * @method createCustomRound
     *********************************************************************************************/
    public async createCustomRound(
        year: number, periodSid: number, version: number, roundDesc: string
    ): Promise<ICustomRoundResult> {
        return this.roundService.createCustomRound(year, periodSid, version, roundDesc ?? `ver.${ version }`)
    }

    /**********************************************************************************************
     * @method checkRoundActivation
     *********************************************************************************************/
    public async checkRoundActivation(roundSid: number): Promise<IActivateRoundValidation> {
        return Promise.all([
            this.roundService.checkRoundActivation(roundSid),
            this.getForecastAggregationStatus()
        ]).then(([roundActivation, forecastAggStatusId]) => Object.assign(roundActivation, { forecastAggStatusId }))
    }

    /**********************************************************************************************
     * @method activateRound
     *********************************************************************************************/
    public async activateRound(roundSid: number, user: string): Promise<number> {
        let result = await this.acceptForecastAggregation(user)
        if (result > 0) {
            const currentRoundInfo = await DashboardApi.getCurrentRoundInfo(EApps.FDMS)
            const activated = await this.roundService.activateRound(roundSid, user)
            result = activated ? 1 : 0
            if (activated) await DrmApi.newRound(currentRoundInfo.roundSid, roundSid, user)
        }
        return result
    }

    /**********************************************************************************************
     * @method getPeriods
     *********************************************************************************************/
    public async getPeriods(): Promise<IPeriod[]> {
        return this.roundService.getPeriods()
    }

    /**********************************************************************************************
     * @method getLatestRoundVersion
     *********************************************************************************************/
    public async getLatestRoundVersion(year: number, periodSid: number): Promise<number> {
        return this.roundService.getLatestRoundVersion(year, periodSid)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method acceptForecastAggregation
     *********************************************************************************************/
    private async acceptForecastAggregation(user: string): Promise<number> {
        return this.getForecastAggregationStatus().then(
            aggStatusId => aggStatusId === EStatusRepo.ACTIVE ?
                FdmsApi.acceptForecastAggregation(aggStatusId, user).then(actionResult => actionResult.result ) : 1
        )
    }

    /**********************************************************************************************
     * @method getForecastAggregationStatus
     *********************************************************************************************/
    private async getForecastAggregationStatus(): Promise<EStatusRepo> {
        return CountryStatusApi.getCountryStatusId(EApps.FDMS, 'AGG')
    }
}
