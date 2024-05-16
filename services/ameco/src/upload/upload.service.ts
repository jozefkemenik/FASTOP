import {
    IDataUploadResult,
    IFdmsIndicator, IFdmsIndicatorMapping,
    IFdmsScale,
    IIndicatorDataUpload, IIndicatorUpload
} from 'fdms/src/upload/shared-interfaces'
import { CacheMap } from '../../../lib/dist'
import { FdmsApi } from '../../../lib/dist/api'


export class UploadService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _scales: IFdmsScale[]
    private _indicators = new CacheMap<string, IFdmsIndicator[]>()
    private _indicatorsMappings = new CacheMap<string, IFdmsIndicatorMapping[]>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getFdmsScales
     *********************************************************************************************/
    public async getFdmsScales(): Promise<IFdmsScale[]> {
        if (!this._scales) {
            this._scales = await FdmsApi.getScales()
        }
        return this._scales
    }

    /**********************************************************************************************
     * @method getFdmsIndicators
     *********************************************************************************************/
    public async getFdmsIndicators(providerId: string): Promise<IFdmsIndicator[]> {
        if (!this._indicators.has(providerId)) {
            this._indicators.set(providerId,  await FdmsApi.getIndicators(providerId))
        }
        return this._indicators.get(providerId)
    }

    /**********************************************************************************************
     * @method getIndicatorsMappings
     *********************************************************************************************/
    public async getFdmsIndicatorsMappings(providerId: string): Promise<IFdmsIndicatorMapping[]> {
        if (!this._indicatorsMappings.has(providerId)) {
            this._indicatorsMappings.set(providerId,  await FdmsApi.getIndicatorsMappings(providerId))
        }
        return this._indicatorsMappings.get(providerId)
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
        return FdmsApi.uploadIndicatorData(
            roundSid, storageSid, providerId, data, user
        )
    }

    /**********************************************************************************************
     * @method getOutputGapUpload
     *********************************************************************************************/
    public async getOutputGapUpload(
        providerId: string, roundSid: number, storageSid: number, sendData: boolean
    ): Promise<IIndicatorUpload> {
        return FdmsApi.getOutputGapUpload(providerId, roundSid, storageSid, sendData)
    }

    /**********************************************************************************************
     * @method uploadFile
     *********************************************************************************************/
    public async uploadFile(
        file: Express.Multer.File,
        countryId: string, providerId: string,
        roundSid: number, storageSid: number, custTextSid: number, user: string
    ): Promise<number> {
        return FdmsApi.uploadFile(
            file, countryId, providerId, roundSid, storageSid, custTextSid, user
        )
    }
}
