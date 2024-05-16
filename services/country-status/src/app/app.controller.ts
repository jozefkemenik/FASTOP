import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { EErrors } from '../../../shared-lib/dist/prelib/error'
import { IError } from '../../../lib/dist'

import { ISetCountryStatus, ISetCountryStatusResult, ISetStatusChangeDate } from '.'
import { EApps } from 'config'
import { config } from '../../../config/config'

import { AppService } from './app.service'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

export class AppController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private appService: AppService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryLastAccepted
     *********************************************************************************************/
    public getCountryLastAccepted(
        appId: EApps, countries: string[], onlyFullStorage: boolean, onlyFullRound: boolean,
    ) {
        return this.appService.getCountryAcceptedDates(appId, countries, onlyFullStorage, onlyFullRound)
            .catch(this.errorHandler('getCountryLastAccepted'))
    }

    /**********************************************************************************************
     * @method getCountryRoundComments
     *********************************************************************************************/
    public getCountryRoundComments(appId: EApps, countryId: string, roundSid: number) {
        return this.appService.getCountryRoundComments(appId, countryId, roundSid)
            .catch(this.errorHandler('getCountryRoundComments'))
    }

    /**********************************************************************************************
     * @method getStatusChanges
     *********************************************************************************************/
    public async getStatusChanges(appId: EApps, countries: string[], roundKeys: IRoundKeys) {

        if (!roundKeys?.roundSid) roundKeys = await this.getCurrentRoundInfoParams(appId)

        return this.appService.getStatusChanges(countries, roundKeys)
            .catch(this.errorHandler('getStatusChanges'))
    }

    /**********************************************************************************************
     * @method getStatuses
     *********************************************************************************************/
    public async getStatuses(appId: EApps, countries: string[], roundKeys: IRoundKeys) {

        if (!roundKeys?.roundSid) roundKeys = await this.getCurrentRoundInfoParams(appId)

        return this.appService.getStatuses(appId, countries, roundKeys)
            .catch(this.errorHandler('getStatuses'))
    }

    /**********************************************************************************************
     * @method setCountryStatus
     *********************************************************************************************/
    public async setCountryStatus(
        appId: EApps, countryId: string, setStatus: ISetCountryStatus
    ): Promise<ISetCountryStatusResult> {

        const dbResult = await this.appService.setCountryStatus(appId, countryId, setStatus, config.mailNotifications)
            .catch(this.errorHandler('setCountryStatus'))

        const result = dbResult[0] < 0 ? EErrors.CTY_STATUS : dbResult[0]

        return {result, countryStatus: dbResult[1]}
    }

    /**********************************************************************************************
     * @method setManyCountriesStatus
     *********************************************************************************************/
    public setManyCountriesStatus(
        appId: EApps, countries: string[], setStatus: ISetCountryStatus
    ): Promise<number> {

        return this.appService.setManyCountriesStatus(appId, countries, setStatus)
            .catch(this.errorHandler('setManyCountriesStatus'))
    }

    /**********************************************************************************************
     * @method setStatusChangeDate
     *********************************************************************************************/
    public async setStatusChangeDate(appId: EApps, countryId: string, setChange: ISetStatusChangeDate) {

        const roundKeys = setChange.roundKeys ?? await this.getCurrentRoundInfoParams(appId)

        return this.appService.setStatusChangeDate(countryId, roundKeys.roundSid, setChange.statusChange)
            .catch(this.errorHandler('setStatusChangeDate'))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCurrentRoundInfoParams
     *********************************************************************************************/
    private async getCurrentRoundInfoParams(appId: EApps): Promise<IRoundKeys> {
        const {roundSid, storageSid, textSid} = await DashboardApi.getCurrentRoundInfo(appId)
        const useStorage = [EApps.DFM, EApps.FDMS].includes(appId)
        return {
            roundSid,
            storageSid: (useStorage && storageSid) || null,
            custTextSid: (useStorage && textSid) || null,
        }
    }

    /**********************************************************************************************
     * @method errorHandler
     *********************************************************************************************/
    private errorHandler(method: string) {
        return (err: IError) => {
            err.method = `AppController.${method}`
            throw err
        }
    }
}
