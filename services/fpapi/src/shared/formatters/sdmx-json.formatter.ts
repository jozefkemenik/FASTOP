import { IFpapiParams, IObservations } from '../shared-interfaces'
import { BaseFormatter } from './base.formatter'
import { ISdmxData } from '../../../../lib/dist/sdmx/shared-interfaces'

export class SdmxJsonFormatter extends BaseFormatter<ISdmxData, IObservations> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method format
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    public format(data: ISdmxData, params: IFpapiParams): IObservations {
        // TODO: transform to new json model (change timestamps to periods)
        return data
    }

}
