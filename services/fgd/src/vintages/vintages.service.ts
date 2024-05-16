import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

import { IDBVintageColumn, IVintageData, IVtAppAttrs } from '.'

import { FgdDbService } from '../db/db.service'

export class VintagesService extends FgdDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method getVintageData
     *********************************************************************************************/
     public async getVintageData(
        appId: string, year: number
    ): Promise<IVintageData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_year', type: NUMBER, value: year },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_vintages.getVintageData' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getVtAppAttrs
     *********************************************************************************************/
    public async getVtAppAttrs(
        appId: string
    ): Promise<IVtAppAttrs[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_vintages.getVtAppAttrs' , options)

        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getVintage
     *********************************************************************************************/
    public async getVintage(
        vintageType: string, viewType: string
    ): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_vintage_type', type: STRING, value: vintageType },
                { name: 'p_view_type', type: STRING, value: viewType },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fgd_cfg_scores.getVintage' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getVintageColumns
     *********************************************************************************************/
    public async getVintageColumns(
        vintageType: string, viewType: string
    ): Promise<IDBVintageColumn[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_vintage_type', type: STRING, value: vintageType },
                { name: 'p_view_type', type: STRING, value: viewType },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fgd_cfg_scores.getVintageColumns' , options)
        return dbResult.o_cur
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
