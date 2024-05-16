import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { IDBIndicator, IDBIndicatorCode } from './index'
import { DataAccessApi } from '../../../lib/dist/api'
import { IDBNameValue } from '../shared/shared-interfaces'

export class IndicatorsService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method setIndicatorCodes
     *********************************************************************************************/
    public async setIndicatorCodes(sid: number, descr: string, forecast: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_sid', type: NUMBER, value: sid },
                { name: 'p_descr', type: STRING, value: descr },
                { name: 'p_forecast', type: NUMBER, value: forecast },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_indicator.setIndicatorCodes', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getProviderPeriodicityIndCode
     *********************************************************************************************/
    public async getProviderPeriodicityIndCode(): Promise<IDBNameValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_pro', type: CURSOR, dir: BIND_OUT },
                { name: 'o_per', type: CURSOR, dir: BIND_OUT },
                { name: 'o_ind', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_getters.getProviderPeriodicityIndCode', options)
        return [dbResult.o_pro, dbResult.o_per, dbResult.o_ind]
    }

    /**********************************************************************************************
     * @method getIndicatorCodesByIds
     *********************************************************************************************/
    public async getIndicatorCodesByIds(sids: number[], forecast: number): Promise<IDBIndicatorCode[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_indicator_sids', type: NUMBER, value: sids },
                { name: 'p_forecast', type: NUMBER, value: forecast },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_getters.getIndicatorCodesByIds', options)
        return dbResult.o_cur
    }



    /**********************************************************************************************
     * @method getIndicatorsBySidProviderPeriodicity
     *********************************************************************************************/
    public async getIndicatorsBySidProviderPeriodicity(
        indicators: number[],
        periods: string[],
        providers: number[],
    ): Promise<IDBIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_indicator_sids', type: NUMBER, value: indicators },
                { name: 'p_periodicity_ids', type: STRING, value: periods },
                { name: 'p_provider_sids', type: NUMBER, value: providers },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_getters.getIndicatorsBySidProviderPeriodicity', options)
        return dbResult.o_cur
    }
}
