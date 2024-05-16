import { EApps } from 'config'

import { IDownloadCSVParams } from '../fisc/grid'
import { RequestService } from '../request.service'
import { buildQuery } from './util'

export class GridsApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getGridsCSV
     *********************************************************************************************/
    public static getGridsCSV(app: EApps, params: IDownloadCSVParams): Promise<Array<Array<string|number>>> {
        return RequestService.request(app, `/grids/downloadCSV${buildQuery(params)}`)
    }

    /**********************************************************************************************
     * @method getIndicatorsForCSV
     *********************************************************************************************/
     public static getIndicatorsForCSV(app: EApps, params: IDownloadCSVParams): Promise<Array<Array<string|number>>> {
        return RequestService.request(app, `/grids/indicatorsForCSV${buildQuery(params)}`)
    }
}
