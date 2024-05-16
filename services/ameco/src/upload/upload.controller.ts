import {
    IDataUploadResult,
    IFdmsIndicator, IFdmsIndicatorMapping,
    IFdmsScale,
    IIndicatorDataUpload, IIndicatorUpload
} from '../../../fdms/src/upload/shared-interfaces'
import { EApps } from 'config'
import { UploadService } from './upload.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class UploadController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly uploadService: UploadService
    ) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getScales
     *********************************************************************************************/
    public getScales(): Promise<IFdmsScale[]> {
        return this.uploadService.getFdmsScales()
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public getIndicators(providerId: string): Promise<IFdmsIndicator[]> {
        return this.uploadService.getFdmsIndicators(providerId)
    }

    /**********************************************************************************************
     * @method getIndicatorsMappings
     *********************************************************************************************/
    public getIndicatorsMappings(providerId: string): Promise<IFdmsIndicatorMapping[]> {
        return this.uploadService.getFdmsIndicatorsMappings(providerId)
    }

    /**********************************************************************************************
     * @method uploadIndicatorData
     *********************************************************************************************/
    public async uploadIndicatorData(
        roundSid: number,
        storageSid: number,
        providerId: string,
        data: IIndicatorDataUpload,
        user: string
    ): Promise<IDataUploadResult> {
        return this.uploadService.uploadIndicatorData(
            roundSid, storageSid, providerId, data, user
        )
    }

    /**********************************************************************************************
     * @method getOutputGapUpload
     *********************************************************************************************/
    public async getOutputGapUpload(
        providerId: string, roundSid: number, storageSid: number, sendData: boolean
    ): Promise<IIndicatorUpload> {
        return this.uploadService.getOutputGapUpload(
            providerId, roundSid, storageSid, sendData
        )
    }

    /**********************************************************************************************
     * @method uploadFile
     *********************************************************************************************/
    public uploadFile(
        file: Express.Multer.File,
        countryId: string, providerId: string,
        roundSid: number, storageSid: number, custTextSid: number, user: string
    ): Promise<number> {
        return this.uploadService.uploadFile(
            file,
            countryId, providerId, roundSid, storageSid, custTextSid,
            user
        )
    }
}
