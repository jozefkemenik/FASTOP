import { IPoiWorksheetData } from '../excel-poi'
import { RequestService } from '../request.service'
import { config } from '../../../config/config'

export class ExcelPoiApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method processTemplate
     *********************************************************************************************/
    public static async processTemplate(file: Buffer, poiData: IPoiWorksheetData[]): Promise<Buffer> {

        const formData = new FormData()
        formData.append('file', new Blob([Buffer.from(file)]))
        formData.append('data', JSON.stringify(poiData))

        return RequestService.requestUri(
            `${config.excelService}/excel/processTemplate`,
            'post',
            formData,
            undefined, undefined, false, true
        )
    }
}
