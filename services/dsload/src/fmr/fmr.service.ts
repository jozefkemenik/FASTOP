import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { IDBLogUpload, IDBStatusTransition } from './index'
import { DataAccessApi } from '../../../lib/dist/api'


export class FmrService {

    private static readonly DEFAULT_PROVIDER = 'ECFIN'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createUpload
     *********************************************************************************************/
    public async createUpload(user: string, provider: string, dataset: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user_id', type: STRING, value: user },
                { name: 'p_provider', type: STRING, value: provider || FmrService.DEFAULT_PROVIDER },
                { name: 'p_dataset', type: STRING, value: dataset },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('DSLOAD_UPLOAD.createUpload', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method changeDataset
     *********************************************************************************************/
    public async changeDataset(uploadSid: number, provider: string, dataset: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_upload_sid', type: NUMBER, value: uploadSid },
                { name: 'p_provider', type: STRING, value: provider || FmrService.DEFAULT_PROVIDER },
                { name: 'p_dataset', type: STRING, value: dataset },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('DSLOAD_UPLOAD.changeDataset', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getLogUpload
     *********************************************************************************************/
    public async getLogUpload(user: string, uploadSid: number): Promise<IDBLogUpload> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_user_id', type: STRING, value: user || null},
                { name: 'p_upload_sid', type: NUMBER, value: uploadSid || null },

            ],
            fetchInfo: { STATE: { type: STRING } }
        }
        const dbResult = await DataAccessApi.execSP('DSLOAD_UPLOAD.getUpload', options)
        return dbResult.o_cur.length > 0 ? dbResult.o_cur[0] : undefined
    }

    /**********************************************************************************************
     * @method updateUpload
     *********************************************************************************************/
    public async updateUpload(uploadSid: number, status: string, state?: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_upload_sid', type: NUMBER, value: uploadSid },
                { name: 'p_status', type: STRING, value: status || null },
                { name: 'p_state', type: STRING, value: state || null },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('DSLOAD_UPLOAD.updateUpload', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getStatusTransition
     *********************************************************************************************/
    public async getStatusTransition(status: string): Promise<IDBStatusTransition> {
        const options: ISPOptions = {
            params: [
                { name: 'p_status', type: STRING, value: status },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('DSLOAD_UPLOAD.getStatusTransition', options)
        return dbResult.o_cur.length > 0 ? dbResult.o_cur[0] : undefined
    }
}

