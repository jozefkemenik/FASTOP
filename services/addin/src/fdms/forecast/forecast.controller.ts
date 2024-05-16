import { FdmsApi } from '../../../../lib/dist/api/fdms.api'
import { FdmsController } from '../shared/fdms.controller'
import { IIndicatorTreeNode } from '../../../../fdms/src/report/shared-interfaces'
import { catchAll } from '../../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class ForecastController extends FdmsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorsTree
     *********************************************************************************************/
    public async getIndicatorsTree(): Promise<IIndicatorTreeNode[]> {
        return FdmsApi.getIndicatorsTree()
    }
}
