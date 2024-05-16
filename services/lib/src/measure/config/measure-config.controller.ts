import { ICountryCurrencyInfo } from '.'
import { IError } from '../..'
import { MeasureSharedService } from '..'

export abstract class MeasureConfigController<S extends MeasureSharedService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(protected readonly sharedService: S) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getESACodes
     *********************************************************************************************/
    public getESACodes(roundSid = 0) {
        return this.sharedService.getESACodes(roundSid).catch((err: IError) => {
            err.method = 'ConfigController.getESACodes'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getEuFunds
     *********************************************************************************************/
    public getEuFunds() {
        return this.sharedService.getEuFunds().catch((err: IError) => {
            err.method = 'ConfigController.getEuFunds'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getOneOff
     *********************************************************************************************/
    public getOneOff() {
        return this.sharedService.getOneOff().catch((err: IError) => {
            err.method = 'ConfigController.getOneOff'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getOneOffTypes
     *********************************************************************************************/
    public getOneOffTypes(roundSid = 0) {
        return this.sharedService.getOneOffTypes(roundSid).catch((err: IError) => {
            err.method = 'ConfigController.getOneOffTypes'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getCountryCurrencyInfo
     *********************************************************************************************/
    public getCountryCurrencyInfo(
        countryId: string, roundSid: number, version: number, force = false
    ): Promise<ICountryCurrencyInfo> {
        return this.sharedService.getCountryCurrencyInfo(countryId, roundSid, version, force)
            .then(currencyInfo => {
                return currencyInfo ?? {
                    sid: -1,
                    id: '',
                    descr: '<Not set>'
                }
            })
            .catch((err: IError) => {
                err.method = 'ConfigController.getCountryInfo'
                throw err
            })
    }

    /**********************************************************************************************
     * @method getMonths
     *********************************************************************************************/
    public getMonths() {
        return this.sharedService.getMonths().catch((err: IError) => {
            err.method = 'ConfigController.getMonths'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getLabels
     *********************************************************************************************/
    public getLabels() {
        return this.sharedService.getLabels().catch((err: IError) => {
            err.method = 'ConfigController.getLabels'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getAdoptionYears
     *********************************************************************************************/
    public getAdoptionYears() {
        return this.sharedService.getAdoptionYears().catch((err: IError) => {
            err.method = 'ConfigController.getAdoptionYears'
            throw err
        })
    }
}
