import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'

import { DataController } from './data.controller'
import { FpapiRouter } from '../shared/fpapi.router'
import { HttpError } from '../shared/errors'
import { IFpapiParams } from '../shared/shared-interfaces'
import { LoggingService } from '../../../lib/dist'
import { ParamsService } from '../shared/params.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class DataRouter extends FpapiRouter {

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService): Router {
        return new DataRouter(logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: DataController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(logs: LoggingService) {
        super(logs)
        this.controller = new DataController(logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router
            .get('/:provider/:dataset/:query', this.getDataHandler)
            .post('/:provider/:dataset', this.getDataPostHandler)
    }

    /**********************************************************************************************
     * @method getDataHandler
     *********************************************************************************************/
    protected getDataHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getData(
            ParamsService.parseProvider(req.params.provider),
            this.parseParameters(req, req.params.dataset, req.params.query),
        ).then(
            data => typeof data === 'string' ? res.send(data) : res.json(data),
            this.getErrorHandler(res, next)
        )
    }

    /**********************************************************************************************
     * @method getDataPostHandler
     *********************************************************************************************/
    protected getDataPostHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getData(
            ParamsService.parseProvider(req.params.provider),
            this.parseParameters(req, req.params.dataset, req.body.query),
        ).then(
            data => typeof data === 'string' ? res.send(data) : res.json(data),
            this.getErrorHandler(res, next)
        )
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'FpApi sdmx data endpoints',
                    description: 'FpApi sdmx',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/1.0'), }]
            },
            apis: [
                this.getSwaggerFilePath('/data.yaml')
            ],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getErrorHandler
     *********************************************************************************************/
    private getErrorHandler(res: Response, next: NextFunction) {
        return (err: Error) => {
            this.logs.log(`Fpapi.data route failed: ${err.message} | ${err.stack}!`)
            if (err instanceof HttpError) {
                res.status(err.httpStatus)
                return res.send(err.message)
            } else {
                return next(err)
            }
        }
    }

    /**********************************************************************************************
     * @method parseParameters
     *********************************************************************************************/
    private parseParameters(
        req: Request,
        dataset: string = undefined, query: string = undefined
    ): IFpapiParams {
        this.normalizeParams(req.query)
        return {
            dataset: dataset || req.query.ds as string,
            query: query || req.query.key as string,
            startPeriod: ParamsService.parseDate(req.query.startperiod as string),
            endPeriod: ParamsService.parseDate(req.query.endperiod as string),
            obsFlags: ParamsService.parseBoolean(req.query.obsflags),
            format: ParamsService.parseFormat(req.query.format as string)
        }
    }
}
