import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, STRING } from '../../../lib/dist/db'
import { IDBDwhIndicator, IDBDwhIndicatorData } from './dwh'
import { DataAccessApi } from '../../../lib/dist/api'


export class DwhService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public async getIndicators(providers: string[]): Promise<IDBDwhIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_ids', type: STRING, dir: BIND_IN, value: providers },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dwh_getters.getIndicators', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(
        providers: string[], periodicityId: string, indicatorIds: string[]
    ): Promise<IDBDwhIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_ids', type: STRING, dir: BIND_IN, value: providers },
                { name: 'p_periodicity_id', type: STRING, dir: BIND_IN, value: periodicityId },
                { name: 'p_indicator_ids', type: STRING, dir: BIND_IN, value: indicatorIds },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            fetchInfo: {
                timeserie: { type: STRING }
            },
        }
        const dbResult = await DataAccessApi.execSP('dwh_getters.getIndicatorData', options)
        return dbResult.o_cur
    }
}
