import { FplmApi } from '../../../lib/dist/api/fplm.api'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class UploadController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method prepareUpload
     *********************************************************************************************/
    public async prepareUpload(uploadSid: number): Promise<number> {
        return FplmApi.prepareUpload(uploadSid)
    }

    /**********************************************************************************************
     * @method publishFiles
     *********************************************************************************************/
    public async publishFiles(uploadSid: number): Promise<void> {
        return FplmApi.publishFiles(uploadSid)
    }

    /**********************************************************************************************
     * @method validateFiles
     *********************************************************************************************/
    public async validateFiles(uploadSid: number): Promise<void> {
        return FplmApi.validateFiles(uploadSid)
    }
    

    /**********************************************************************************************
     * @method deleteFile
     *********************************************************************************************/
    public async deleteFile(uploadSid: number, file: string): Promise<void> {
        return FplmApi.deleteFile(uploadSid, file)
    }

}
