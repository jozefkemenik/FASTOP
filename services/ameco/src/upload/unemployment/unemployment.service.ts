import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../../lib/dist/db'
import { DataAccessApi } from '../../../../lib/dist/api'
import { IDBAmecoIndicator } from '.'


export class UnemploymentService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method uploadIndicatorData
     *********************************************************************************************/
    public async uploadIndicatorData(
        countryId: string, startYear: number, indicatorSids: number[], timeSeries: string[], user: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_start_year', type: NUMBER, value: startYear },
                { name: 'p_indicator_sids', type: NUMBER, value: indicatorSids },
                { name: 'p_time_series', type: STRING, value: timeSeries },
                { name: 'p_user', type: STRING, value: user },
            ],
        }

        const dbResult = await DataAccessApi.execSP('ameco_upload.uploadIndicatorData', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public async getIndicators(providerId: string): Promise<IDBAmecoIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        if (providerId) options.params.push({ name: 'p_provider_id', type: STRING, value: providerId })

        const dbResult = await DataAccessApi.execSP('ameco_indicator.getIndicators', options)
        return dbResult.o_cur
    }
}
