import { Router } from 'express'

import { FDConfigRouter } from '../../../lib/dist/measure/fisc-drm/config/fd-config.router'

import { ConfigController } from './config.controller'
import { SharedService } from '../shared/shared.service'

export class ConfigRouter extends FDConfigRouter<SharedService, ConfigController> {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new ConfigRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super(sharedService, new ConfigController(sharedService))
    }
}
