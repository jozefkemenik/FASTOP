import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'

export abstract class SharedLibService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getEU27CountyCodes
     *********************************************************************************************/
    public async getEU27CountyCodes(): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getEU27CountryCodes', options)
        return dbResult.o_cur.map(data => data.COUNTRY_ID)
    }

   /**********************************************************************************************
     * @method getCountryCodes
     *********************************************************************************************/
    public async getCountryCodes(countryGroupId: string): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_group_id', type: STRING, value: countryGroupId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getCountryGroupCountries', options)
        return dbResult.o_cur.map(data => data.COUNTRY_ID)
    }

    /**********************************************************************************************
     * @method getRoundYear
     *********************************************************************************************/
    public async getRoundYear(roundSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`core_getters.getRoundYear`, options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
