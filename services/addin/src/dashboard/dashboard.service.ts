import { BIND_OUT, CURSOR, ISPOptions,NUMBER, SIDSLIST, VARCHARLIST  } from '../../../lib/dist/db'
import { IDBAddinApp, IDBAddinTreeApp } from './index'
import { DataAccessApi } from '../../../lib/dist/api'

export class DashboardService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _apps: IDBAddinApp[]



    /**********************************************************************************************
     * @method getDashboardActiveApps
     *********************************************************************************************/
    public async getDashboardActiveApps(): Promise<IDBAddinApp[]> {
        if (!this._apps) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('addin_getters.getActiveApps', options)
            this._apps = dbResult.o_cur
        }

        return this._apps
    }

    /**********************************************************************************************
     * @method getDashboardTreeActiveApps
     *********************************************************************************************/
    public async getDashboardTreeActiveApps(): Promise<IDBAddinTreeApp[]> {    
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('addin_getters.getTreeActiveApps', options)
            return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method setDashboardTreeApps
     *********************************************************************************************/
    public async setDashboardTreeApps(tree_sids:number[],
        dashboard_sids:number[],
        parent_tree_sids:number[],
        titles:string[],
        json_datas:string[]):Promise<number>{

            const options: ISPOptions = {
                params: [
                    { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                    { name: 'tree_sids', type: SIDSLIST, value: tree_sids },
                    { name: 'dashboard_sids', type: SIDSLIST, value: dashboard_sids},
                    { name: 'parent_tree_sids', type: SIDSLIST, value: parent_tree_sids },
                    { name: 'titles', type: VARCHARLIST, value: titles },
                    { name: 'json_datas', type: VARCHARLIST, value: json_datas },                
                ],
            }
          
            const dbResult = await DataAccessApi.execSP('addin_setters.setTreeApps', options)
            return dbResult.o_res
}
}
