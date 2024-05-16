import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'

import { ImfController } from './imf.controller'
import { SharedService } from '../shared/shared.service'
import { WqRouter } from '../shared/wq.router'

export class ImfRouter extends WqRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new ImfRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: ImfController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super()
        this.controller = new ImfController(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router
            .get('/', this.getImfDataHandler)
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'IMF API',
                    description: 'International Monetary Fund - web queries',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/imf'), }]
            },
            apis: [this.getSwaggerFilePath('/imf.yaml')],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getImfDataHandler
     *********************************************************************************************/
    private getImfDataHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getImfData(
            req.query.ds as string,
            req.query.key as string,
            Number(req.query.startPeriod),
            Number(req.query.endPeriod),
        ).then(res.send.bind(res), next)
    }
}
