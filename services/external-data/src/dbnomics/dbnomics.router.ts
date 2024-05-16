import { NextFunction, Request, Response, Router } from 'express'

import { FASTOP_HTTP_ERROR_STATUS, FastopError } from '../../../shared-lib/dist/prelib/error'
import { Level, LoggingService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { DbNomicsController } from './dbnomics.controller'
import { DbNomicsService } from './dbnomics.service'

export class DbNomicsRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService): Router {
        return new DbNomicsRouter(logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: DbNomicsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private _logs: LoggingService) {
        super()
        this.controller = new DbNomicsController(new DbNomicsService(_logs))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/providers', this.getProvidersDataHandler)
            .get('/providers/:provider', this.getProviderTreeHandler)
            .get('/dataset/:provider/:dataset', this.getDatasetHandler)
            .get('/series/:provider/:dataset', this.getSeriesHandler)
            .put('/data/series/:provider/:dataset', this.getDataBySeriesHandler)
            .put('/data/query/:provider/:dataset', this.getDataByQueryHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProvidersDataHandler
     *********************************************************************************************/
    private getProvidersDataHandler = (req: Request, res: Response, next: NextFunction) =>
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
            req.params.dataset as string,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeriesHandler
     *********************************************************************************************/
    private getSeriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeries(
            req.params.provider as string,
            req.params.dataset as string,
            Number(req.query.limit)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDataBySeriesHandler
     *********************************************************************************************/
    private getDataBySeriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataBySeries(
            req.params.provider as string,
            req.params.dataset as string,
            req.body.series,
            Number(req.query.limit),
            Number(req.query.offset),
        ).then(res.json.bind(res), err => this.handleError(err, res, next))

    /**********************************************************************************************
     * @method getDataByQueryHandler
     *********************************************************************************************/
    private getDataByQueryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataByQuery(
            req.params.provider as string,
            req.params.dataset as string,
            req.body.query,
            Number(req.query.limit),
            Number(req.query.offset),
        ).then(res.json.bind(res), err => this.handleError(err, res, next))

    /**********************************************************************************************
     * @method handleError
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private handleError(err: any, res: Response, next: NextFunction) {
        const details = this.errorDetails(err.response?.data)
        this._logs.log(`DbNomics search failed, err: ${err}, details: ${JSON.stringify(details)}`, Level.ERROR)

        if (err instanceof FastopError) {
            return res.status(FASTOP_HTTP_ERROR_STATUS).send(`DbNomics error: ${err.message}!`)
        } else if (err?.response?.status === 400 || err?.response?.status == 414 || err?.response?.status === 404) {
            if (err?.response?.status === 404 && details?.message.indexOf('not found') > -1) {
                // skip error, no data round
                return res.status(204).send()
            } else {
                return res.status(FASTOP_HTTP_ERROR_STATUS).send(
                    'DbNomics error: too many search criteria selected, url is too long (max 4096 characters)!'
                )
            }
        }
        next(err)
    }

    /**********************************************************************************************
     * @method errorDetails
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private errorDetails(data: any): any {
        if (!data) return ''

        const properties = Object.getOwnPropertyNames(data)
        return properties.reduce((acc, prop) => (acc[prop] = data[prop], acc), {})
    }
}
