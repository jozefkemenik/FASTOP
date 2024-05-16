import { ForecastType } from '../../../fdms/src/forecast/shared-interfaces'
import { IRoundStorage } from '../shared/shared-interfaces'
import { SharedService } from '../shared/shared.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class ForecastController {


    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly sharedService: SharedService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getForecastRoundAndStorage
     *********************************************************************************************/
    public async getForecastRoundAndStorage(forecastType: ForecastType): Promise<IRoundStorage> {
        return this.sharedService.getForecastRoundAndStorage(forecastType)
    }

}
