import { BIND_OUT, CURSOR, ISPOptions, NUMBER } from '../../db'
import { DataAccessApi } from '../../api'
import { ILineIndicator } from '../shared'

export class LibLineIndicatorService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getLineIndicators
     *********************************************************************************************/
    public async getLineIndicators(lineSid: number): Promise<ILineIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_line_sid', type: NUMBER, value: lineSid },
                { name: 'o_res', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_line_pkg.getLineIndicators', options) 
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method saveLineIndicator
     *********************************************************************************************/
    public async saveLineIndicator(lineSid: number,
                                 dataTypeSid: number,
                                 indicatorSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_line_sid', type: NUMBER, value: lineSid },
                { name: 'p_data_type_sid', type: NUMBER, value: dataTypeSid },
                { name: 'p_indicator_sid', type: NUMBER, value: indicatorSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_line_pkg.saveLineIndicator', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method deleteLineIndicator
     *********************************************************************************************/
     public async deleteLineIndicator(lineSid: number, dataTypeSid: number) {
        const options: ISPOptions = {
            params: [
                { name: 'p_line_sid', type: NUMBER, value: lineSid },
                { name: 'p_data_type_sid', type: NUMBER, value: dataTypeSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_line_pkg.deleteLineIndicator', options) 
        return dbResult.o_res        
    }
}
