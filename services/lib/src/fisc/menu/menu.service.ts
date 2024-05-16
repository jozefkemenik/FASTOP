import { BIND_OUT, CURSOR, ISPOptions } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { IDBGrid } from '../shared'
import { LibMenuService } from '../../menu/menu.service'

export class MenuService extends LibMenuService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getGrids
     *********************************************************************************************/
    public async getGrids(): Promise<IDBGrid[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.app}_getters.getGrids`, options)
        return dbResult.o_cur
    }
}
