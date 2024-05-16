import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { LoggingService } from '../../../lib/dist'
import { SdmxController } from './sdmx.controller'
import { SdmxProvider } from '../../../lib/dist/sdmx/shared-interfaces'
import { SdmxService } from './sdmx.service'

export class SdmxRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, provider: SdmxProvider, logs: LoggingService): Router {
        return new SdmxRouter(appId, provider, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: SdmxController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, provider: SdmxProvider, logs: LoggingService) {
        super(appId)
        this.controller = new SdmxController(new SdmxService(provider), logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/datasets', this.getDatasetsHandler)
            .get('/dataset/:dataset', this.getDatasetStructureHandler)
            .get('/data/:dataset/:queryKey', this.getDataHandler)
            .post('/data/:dataset', this.getDataByKeysHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDatasetsHandler
     *********************************************************************************************/
    private getDatasetsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDatasets().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDatasetStructureHandler
     *********************************************************************************************/
    private getDatasetStructureHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDatasetStructure(req.params.dataset).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDataHandler
     *********************************************************************************************/
    private getDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getData(
            req.params.dataset, req.params.queryKey, req.query.startPeriod as string
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDataByKeysHandler
     *********************************************************************************************/
    private getDataByKeysHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataByKeys(
            req.params.dataset, req.body, req.query.startPeriod as string
        ).then(res.json.bind(res), next)
}
