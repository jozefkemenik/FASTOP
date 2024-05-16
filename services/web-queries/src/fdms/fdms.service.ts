import { EApps } from 'config'

import { FdmsApi } from '../../../lib/dist/api/fdms.api'

import { IWQCountryIndicators } from '../shared/shared-interfaces'
import { IWQFdmsRequestParams } from './index'
import { WqService } from '../shared/wq.service'

export class FdmsService extends WqService<IWQFdmsRequestParams, void> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps.FDMS | EApps.FDMSIE
    ) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public getIndicatorData(params: IWQFdmsRequestParams): Promise<IWQCountryIndicators> {
        const yearRangeOffset = params.yearRange.map(y => y - params.roundInfo.year)
        return FdmsApi.getProvidersIndicatorData(
            this.appId, params.providerId, params.countries, params.indicators,
            params.periodicity, params.countryGroup, yearRangeOffset, params.roundSid, params.storageSid,
        )
    }
}
