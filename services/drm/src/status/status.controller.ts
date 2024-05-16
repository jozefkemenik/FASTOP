import { EStatusRepo, ICountryStatus } from 'country-status'

import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { EApps } from 'config'
import { ICountry } from '../../../lib/dist/menu'
import { IError } from '../../../lib/dist'
import { IRoundKeys } from '../../../dashboard/src/config/shared-interfaces'

import { EFastopStorages } from '../../../shared-lib/dist/dxm-measure'

export class StatusController {

    // cache
    private _finalStorageSid: number

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTransparencyReportReadyCountries
     *********************************************************************************************/
    public async getTransparencyReportReadyCountries(roundSid: number) {
        const roundKeys: IRoundKeys = roundSid && {
            roundSid,
            storageSid: await this.getFinalStorageSid$(),
        }

        return CountryStatusApi.getCountryStatuses(EApps.DFM, [], roundKeys).then(
            this.formatCountries,
            (err: IError) => {
                err.method = 'StatusController.getTransparencyReportReadyCountries'
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method formatCountries
     *********************************************************************************************/
    private formatCountries = (dfmData: ICountryStatus[]): ICountry[] => {
        if (!dfmData) return []

        return dfmData
            .filter(country => EStatusRepo.ACTIVE !== country.statusId)
            .map(country => ({
                COUNTRY_ID: country.countryId,
                DESCR: country.countryDescr,
            } as ICountry))
    }

    /**********************************************************************************************
     * @method getFinalStorageSid$
     *********************************************************************************************/
     private async getFinalStorageSid$(): Promise<number> {
        this._finalStorageSid = this._finalStorageSid
            ?? await DashboardApi.getStorages(EApps.DFM).then(storages => storages
                ?.find(s => s.storageId === EFastopStorages.FINAL)
                ?.storageSid
            )
        return this._finalStorageSid
    }
}
