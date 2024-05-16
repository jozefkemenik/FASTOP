import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'

import { SdmxController } from './sdmx.controller'
import { SharedService } from '../shared/shared.service'
import { WqRouter } from '../shared/wq.router'

export class SdmxRouter extends WqRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new SdmxRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: SdmxController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super()
        this.controller = new SdmxController(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router
            .get('/estat/data', this.getEstatDataHandler)
            .get('/ecb/data', this.getEcbDataHandler)
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'Sdmx API',
                    description: 'Sdmx web-query endpoints',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/sdmx'), }]
            },
            apis: [
                this.getSwaggerFilePath('/shared/fpapi.components.yaml'),
                this.getSwaggerFilePath('/sdmx.yaml')
            ],
        }
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getEstatDataHandler
     *********************************************************************************************/
    private getEstatDataHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getEurostatData(
            req.query.ds as string,
            req.query.key as string,
            Boolean(req.query.labels),
            req.query.startPeriod as string,
            req.query.endPeriod as string,
            req.query.json !== undefined,
        ).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getEcbDataHandler
     *********************************************************************************************/
    private getEcbDataHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getEcbData(
            req.query.ds as string,
            req.query.key as string,
            Boolean(req.query.labels),
            req.query.startPeriod as string,
            req.query.endPeriod as string,
            req.query.json !== undefined,
        ).then(res.send.bind(res), next)
    }
}
