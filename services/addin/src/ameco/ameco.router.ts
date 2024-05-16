import { Router } from 'express'

import { EApps } from 'config'
import { LibAmecoController } from '../../../lib/dist/ameco/lib-ameco.controller'
import { LibAmecoRouter } from '../../../lib/dist/ameco/lib-ameco.router'
import { LibAmecoService } from '../../../lib/dist/ameco/lib-ameco.service'

export class AmecoRouter extends LibAmecoRouter<LibAmecoController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new AmecoRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new LibAmecoController(new LibAmecoService())
    }
}
