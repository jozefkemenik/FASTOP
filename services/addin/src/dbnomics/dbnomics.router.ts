import { NextFunction, Request, Response, Router } from 'express'

import { Level, LoggingService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { NomicsController } from './dbnomics.controller'
import { NomicsService } from './dbnomics.service'


export class NomicsRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService): Router {
        return new NomicsRouter(appId, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: NomicsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, private _logs: LoggingService) {
        super(appId)
        this.controller = new NomicsController(new NomicsService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/providers/:provider',
                this.getProviderTreeHandler)
            .get('/providers',
                this.getProvidersHandler)
            .get('/dataset/:provider/:dataset',
                this.getDatasetHandler)
            .put('/data/series/:provider/:dataset',
                this.getDataBySeriesHandler)
            .put('/data/query/:provider/:dataset',
                this.getDataByQueryHandler)
        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProvidersHandler
     *********************************************************************************************/
    private getProvidersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviders().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderTreeHandler
     *********************************************************************************************/
    private getProviderTreeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderTree(req.params.provider as string).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDatasetHandler
     *********************************************************************************************/
    private getDatasetHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataset(
            req.params.provider as string,
            req.params.dataset
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDataByQueryHandler
     *********************************************************************************************/
    private getDataByQueryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataByQuery(
            req.params.provider as string,
            req.params.dataset as string,
            req.body.query,
        ).then(res.json.bind(res), err => this.handleError(err, res, next))

    /**********************************************************************************************
     * @method getDataBySeriesHandler
     *********************************************************************************************/
    private getDataBySeriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataBySeries(
            req.params.provider as string,
            req.params.dataset as string,
            req.body.series,
        ).then(res.json.bind(res), err => this.handleError(err, res, next))

    /**********************************************************************************************
     * @method handleError
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private handleError(err: any, res: Response, next: NextFunction) {
        this._logs.log(`External data DbNomics call failed, err: ${err}`, Level.ERROR)
        if (err.response?.status) {
            return res.status(err.response.status).send(err.response.data)
        }
        next(err)
    }

}
