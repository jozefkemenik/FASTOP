import { Router } from 'express'

import { EApps } from 'config'
import { FdmsRouter } from './shared/fdms.router'
import { ForecastRouter } from './forecast/forecast.router'
import { TceRouter } from './tce/tce.router'


export class FdmsMainRouter {
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        const router = Router({ mergeParams: true })

        router.use('/ameco_h', ForecastRouter.createRouter(appId, ['AMECO_H']))
        router.use('/forecast', ForecastRouter.createRouter(appId, ['PRE_PROD']))
        router.use('/output_gap', FdmsRouter.createFdmsRouter(appId, ['OG_TT', 'OG_US', 'OG_EU13', 'OG_EU15']))
        router.use('/output_gap_t10', FdmsRouter.createFdmsRouter(appId, ['EUCAM10']))
        router.use('/tce', TceRouter.createRouter(appId))

        return router
    }
}
