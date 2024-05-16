import { EApps } from 'config'
import { Router } from 'express'

import { GridsRouter } from '../common/grids/grids.router'
import { MeasureController } from '../common/measure/measure.controller'
import { MeasureRouter } from '../common/measure/measure.router'
import { SharedService } from '../shared/shared.service'

export class DbpRouter extends MeasureRouter<MeasureController> {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new DbpRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly sharedService: SharedService) {
        super(new MeasureController(sharedService, EApps.DBP))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected override configFpapiRoutes(router: Router): Router {
        return super.configFpapiRoutes(router).use('/grids', GridsRouter.createRouter(EApps.DBP, this.sharedService))
    }
}
