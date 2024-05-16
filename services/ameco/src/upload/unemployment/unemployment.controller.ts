import { IAmecoIndicator, IAmecoRawInputUpload } from '.'
import { EApps } from 'config'
import { IDataUploadResult } from '../../../../fdms/src/upload/shared-interfaces'
import { UnemploymentService } from './unemployment.service'
import { catchAll } from '../../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class UnemploymentController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly uploadService: UnemploymentService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method uploadAmecoRawInput
     *********************************************************************************************/
    public uploadAmecoRawInput(data: IAmecoRawInputUpload[], user: string): Promise<IDataUploadResult> {
        return Promise
            .all(
                data.map(upload =>
                    this.uploadService.uploadIndicatorData(
                        upload.countryId, upload.startYear, upload.indicatorSids, upload.timeSeries, user
                    ).then( (res) => {
                            const ret = {}
                            ret[upload.countryId] = res
                            return ret
                        },
                        (err) => this.handleCountryIndicatorUploadError(upload.countryId, err)
                    )
                )
            ).then((results) => results.reduce((acc, r) => Object.assign(acc, r), {}))
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public getIndicators(providerId: string): Promise<IAmecoIndicator[]> {
        return this.uploadService.getIndicators(providerId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method handleCountryIndicatorUploadError
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private handleCountryIndicatorUploadError(countryId: string, error: any): IDataUploadResult {
        if (countryId) {
            const result: IDataUploadResult = {}
            result[countryId] = error.code || -1
            return result
        } else throw error
    }
}
