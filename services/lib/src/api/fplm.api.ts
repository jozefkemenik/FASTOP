import { EApps } from 'config'
import { RequestService } from '../request.service'


export class FplmApi {


    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method prepareUpload
     *********************************************************************************************/
    public static async prepareUpload(uploadSid: number): Promise<number> {
       return RequestService.request(EApps.FPLM, `/upload/prepare/${uploadSid}`, 'put', {})
    }

    /**********************************************************************************************
     * @method publishFiles
     *********************************************************************************************/
    public static async publishFiles(uploadSid: number): Promise<void> {
        return RequestService.request(EApps.FPLM, `/upload/publish/${uploadSid}`, 'put', {})
    }

    /**********************************************************************************************
     * @method validateFiles
     *********************************************************************************************/
    public static async validateFiles(uploadSid: number): Promise<void> {
        return RequestService.request(EApps.FPLM, `/upload/validate/${uploadSid}`, 'put', {})
    }

    /**********************************************************************************************
     * @method deleteFile
     *********************************************************************************************/
    public static async deleteFile(uploadSid: number, file: string): Promise<void> {
        return RequestService.request(EApps.FPLM, `/upload/delete/${uploadSid}`, 'put', { file })
    }

    /**********************************************************************************************
     * @method finishUpload
     *********************************************************************************************/
    public static async finishUpload(uploadSid: number): Promise<void> {
        return RequestService.request(EApps.FPLM, `/upload/finish/${uploadSid}`, 'put', {})
    }

    /**********************************************************************************************
     * @method cancelUpload
     *********************************************************************************************/
    public static async cancelUpload(uploadSid: number): Promise<void> {
        return RequestService.request(EApps.FPLM, `/upload/cancel/${uploadSid}`, 'put', {})
    }

    /**********************************************************************************************
     * @method getDataflows
     *********************************************************************************************/
    public static async getDataflows(provider = 'ECFIN'): Promise<string[]> {
        return RequestService.request(EApps.FPLM, `/lake/dataflows/${provider}`)
    }

}
