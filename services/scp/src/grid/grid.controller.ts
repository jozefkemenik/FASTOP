import { EApps } from 'config'

import { FiscGridController } from '../../../lib/dist/fisc'

import { GridService } from './grid.service'

export class GridController extends FiscGridController<GridService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId, new GridService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

}
