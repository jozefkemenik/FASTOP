import { EApps } from 'config'

import { BIND_OUT, BLOB, BUFFER, CURSOR, DATE, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'

import {
    ICopyFromFDMSStorage,
    IDBCtyIndicatorScale,
    IDBDeskUpload,
    IDBEerIndicatorData,
    IDBFdmsIndicator,
    IDBFdmsIndicatorMapping,
    IDBFdmsScale,
    IDBIndicatorUpload,
    IDBProviderUpload,
    IDataUploadResult,
    IFdmsIndicatorUploadParam,
    IFileContent,
    IFileInfo,
    ITceUploadParam,
} from '.'

export class UploadService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method copyFromFDMSStorage
     *********************************************************************************************/
    public async copyFromFDMSStorage(params: ICopyFromFDMSStorage): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_ids', type: STRING, value: params.countryIds },
                { name: 'p_provider_ids', type: STRING, value: params.providerIds },
                { name: 'p_round_sid', type: NUMBER, value: params.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: params.storageSid },
                { name: 'p_indicator_ids', type: STRING, value: params.indicatorIds ?? [] },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_indicator.copyFromFDMSStorage', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getEerData
     *********************************************************************************************/
    public async getEerData(): Promise<IDBEerIndicatorData[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            fetchInfo: {
                timeserieData: { type: STRING },
            },
        }
        const dbResult = await DataAccessApi.execSP('fdms_upload.getEerData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getDeskUpload
     *********************************************************************************************/
    public async getDeskUpload(
        countryId: string,
        roundSid: number,
        storageSid: number,
        sendData: boolean,
    ): Promise<IDBDeskUpload> {
        const options: ISPOptions = {
            params: [
                { name: 'o_user', type: STRING, dir: BIND_OUT },
                { name: 'o_date', type: DATE, dir: BIND_OUT },
                { name: 'o_cur_annual', type: CURSOR, dir: BIND_OUT },
                { name: 'o_cur_quarterly', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_send_data', type: NUMBER, value: Number(sendData) },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_upload.getDeskUpload', options)
        return {
            user: dbResult.o_user,
            date: dbResult.o_date,
            annual: dbResult.o_cur_annual,
            quarterly: dbResult.o_cur_quarterly,
        }
    }

    /**********************************************************************************************
     * @method getProviderUpload
     *********************************************************************************************/
    public async getProviderUpload(
        providerId: string,
        periodicity: string,
        roundSid: number,
        storageSid: number,
        sendData: boolean,
    ): Promise<IDBIndicatorUpload> {
        const options: ISPOptions = {
            params: [
                { name: 'o_user', type: STRING, dir: BIND_OUT },
                { name: 'o_date', type: DATE, dir: BIND_OUT },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, value: providerId },
                { name: 'p_periodicity', type: STRING, value: periodicity },
                { name: 'p_send_data', type: NUMBER, value: Number(sendData) },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_upload.getProviderUpload', options)
        return {
            user: dbResult.o_user,
            date: dbResult.o_date,
            data: dbResult.o_cur,
        }
    }

    /**********************************************************************************************
     * @method getFdmsIndicators
     *********************************************************************************************/
    public async getFdmsIndicators(providerId: string): Promise<IDBFdmsIndicator[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }

        if (providerId) options.params.push({ name: 'p_provider_id', type: STRING, value: providerId })

        const dbResult = await DataAccessApi.execSP('fdms_indicator.getIndicators', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getFdmsIndicatorsMappings
     *********************************************************************************************/
    public async getFdmsIndicatorsMappings(providerId: string): Promise<IDBFdmsIndicatorMapping[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, value: providerId },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_indicator.getIndicatorsMappings', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getFdmsScales
     *********************************************************************************************/
    public async getFdmsScales(): Promise<IDBFdmsScale[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('fdms_getters.getScales', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method uploadFdmsIndData
     *********************************************************************************************/
    public async uploadFdmsIndData(
        roundSid: number,
        storageSid: number,
        params: IFdmsIndicatorUploadParam,
        user: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_id', type: STRING, value: params.countryId },
                { name: 'p_indicator_sids', type: NUMBER, value: params.indicatorSids },
                { name: 'p_scale_sids', type: NUMBER, value: params.scaleSids },
                { name: 'p_start_years', type: NUMBER, value: params.startYears },
                { name: 'p_time_series', type: STRING, value: params.timeSeries },
                { name: 'p_user', type: STRING, value: user },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_indicator.setIndicatorData', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method setIndicatorDataUpload
     *********************************************************************************************/
    public async setIndicatorDataUpload(
        roundSid: number,
        storageSid: number,
        providerId: string,
        countryId: string,
        user: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'p_provider_id', type: STRING, value: providerId },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        if (countryId) {
            options.params.push({ name: 'p_country_id', type: STRING, value: countryId })
        }

        const dbResult = await DataAccessApi.execSP('fdms_upload.setIndicatorDataUpload', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getIndicatorDataUploads
     *********************************************************************************************/
    public async getIndicatorDataUploads(roundSid: number, storageSid: number): Promise<IDBProviderUpload[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_upload.getIndicatorDataUploads', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method setTceMatrix
     *********************************************************************************************/
    public async setTceMatrix(providerId: string, roundSid: number, storageSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'p_provider_id', type: STRING, value: providerId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.setTceMatrix', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method uploadTceMatrixData
     *********************************************************************************************/
    public async uploadTceMatrixData(params: ITceUploadParam): Promise<IDataUploadResult> {
        const result = {}
        const options: ISPOptions = {
            params: [
                { name: 'p_matrix_sid', type: NUMBER, value: params.matrixSid },
                { name: 'p_exp_cty_id', type: STRING, value: params.expCtyId },
                { name: 'p_exp_line_nr', type: NUMBER, value: params.expLineNr },
                { name: 'p_prnt_cty_ids', type: STRING, value: params.prntCtyIds },
                { name: 'p_prnt_col_nbrs', type: NUMBER, value: params.prntColNrs },
                { name: 'p_values', type: STRING, value: params.values },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_tce.setTceMatrixData', options)
        result[params.expCtyId] = dbResult.o_res

        return result
    }

    /**********************************************************************************************
     * @method uploadFile
     *********************************************************************************************/
    public async uploadFile(
        countryId: string,
        providerId: string,
        roundSid: number,
        storageSid: number,
        custTextSid: number,
        fileName: string,
        mimeType: string,
        fileContent: Buffer,
        user: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid ?? null },
                { name: 'p_country_id', type: STRING, value: countryId ?? null },
                { name: 'p_provider_id', type: STRING, value: providerId },
                { name: 'p_file_name', type: STRING, value: fileName },
                { name: 'p_content_type', type: STRING, value: mimeType },
                { name: 'p_content', type: BLOB, value: fileContent },
                { name: 'p_last_change_user', type: STRING, value: user },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_upload.uploadFile', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getFiles
     *********************************************************************************************/
    public async getFiles(roundSid: number, storageSid: number, custTextSid: number): Promise<IFileInfo[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid ?? null },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_upload.getFiles', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method downloadFile
     *********************************************************************************************/
    public async downloadFile(fileSid: number): Promise<IFileContent> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_file_sid', type: NUMBER, value: fileSid },
            ],
            fetchInfo: {
                content: { type: BUFFER },
            },
        }

        const dbResult = await DataAccessApi.execSP('fdms_upload.downloadFile', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getCtyIndicatorScales
     *********************************************************************************************/
    public async getCtyIndicatorScales(providerId: string): Promise<IDBCtyIndicatorScale[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, value: providerId },
            ],
        }

        const dbResult = await DataAccessApi.execSP('fdms_indicator.getCtyIndicatorScales', options)
        return dbResult.o_cur
    }
}
