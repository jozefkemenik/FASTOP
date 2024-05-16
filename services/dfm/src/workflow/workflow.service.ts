import { EApps } from 'config'

import { BIND_OUT, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { IArchiveParams } from '../../../lib/dist/measure'
import { LibWorkflowService } from '../../../lib/dist/workflow/workflow.service'

import { ICustStorageText } from '../config'

export class WorkflowService extends LibWorkflowService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super(EApps.DFM)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method archiveMeasures
     *********************************************************************************************/
    public async archiveMeasures(archive: IArchiveParams, userId: string, countryIds: string[]): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: archive.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: archive.storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: archive.custTextSid || null },
                { name: 'p_country_ids', type: STRING, value: countryIds ?? []},
                { name: 'p_user', type: STRING, value: userId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_app_status.archiveMeasures', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method newCustomStorage
     *********************************************************************************************/
    public async newCustomStorage(roundSid: number, storage: ICustStorageText): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_title', type: STRING, value: storage.TITLE },
                { name: 'p_descr', type: STRING, value: storage.DESCR },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_app_status.createCustomStorage', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method closeApplication
     * @overrides
     *********************************************************************************************/
    public async closeApplication(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_app_status.setApplicationClosed', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method openTransparencyReport
     *********************************************************************************************/
    public async openTransparencyReport(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_app_status.setApplicationTROpen', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method publishTransparencyReport
     *********************************************************************************************/
    public async publishTransparencyReport(archive: IArchiveParams): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: archive.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: archive.storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: archive.custTextSid || null },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_app_status.setApplicationTRPublish', options)
        return dbResult.o_res
    }
}
