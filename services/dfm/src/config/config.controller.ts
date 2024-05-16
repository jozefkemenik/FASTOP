import { IError } from '../../../lib/dist'
import { MeasureConfigController } from '../../../lib/dist/measure'

import { ICustStorageText } from '.'
import { SharedService } from '../shared/shared.service'

export class ConfigController extends MeasureConfigController<SharedService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCustStorageTexts
     *********************************************************************************************/
    public getCustStorageTexts(roundSid: number): Promise<ICustStorageText[]> {
        return this.sharedService.getCustStorageTexts(roundSid).catch(
            (err: IError) => {
                err.method = 'ConfigController.getCustStorageTexts'
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getESAPeriod
     *********************************************************************************************/
    public getESAPeriod(roundSid = 0) {
        return this.sharedService.getESAPeriod(roundSid).catch((err: IError) => {
            err.method = 'ConfigController.getESAPeriod'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getOneOffPrinciples
     *********************************************************************************************/
    public getOneOffPrinciples() {
        return this.sharedService.getOneOffPrinciples().catch((err: IError) => {
            err.method = 'ConfigController.getOneOffPrinciples'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getOverviews
     *********************************************************************************************/
    public getOverviews(isFilter=false) {
        return this.sharedService.getOverviews(isFilter).catch((err: IError) => {
            err.method = 'ConfigController.getOverviews'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getRevExp
     *********************************************************************************************/
    public getRevExp() {
        return this.sharedService.getRevExp().catch((err: IError) => {
            err.method = 'ConfigController.getRevExp'
            throw err
        })
    }

    /**********************************************************************************************
     * @method getStatuses
     *********************************************************************************************/
    public getStatuses() {
        return this.sharedService.getStatuses().catch((err: IError) => {
            err.method = 'ConfigController.getStatuses'
            throw err
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
