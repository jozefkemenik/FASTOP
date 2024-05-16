import { EApps } from 'config'
import { Router } from 'express'

import { FiscGridRouter } from '../../../lib/dist/fisc'

import { GridController } from './grid.controller'
import { GridService } from './grid.service'

export class GridRouter extends FiscGridRouter<GridService, GridController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of GridRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new GridRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId, new GridController(appId))
    }
}
