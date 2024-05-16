import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { BaseRouter } from '../../../lib/dist/base-router'

import { StatusController } from './status.controller'
import { StatusService } from './status.service'

export class StatusRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new StatusRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: StatusController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new StatusController(new StatusService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/applications/:appId',
                (req: Request, res: Response, next: NextFunction) =>
                    this.controller.getApplicationStatus(req.params.appId?.toUpperCase() as EApps)
                        .then(res.json.bind(res), next))
            .get('/applications/:appId/countries',
                (req: Request, res: Response, next: NextFunction) =>
                    this.controller.getMultiCountryStatuses(
                        req.params.appId?.toUpperCase() as EApps,
                        (req.query.countries as string)?.split(','),
                    ).then( res.json.bind(res), next ))
            .get('/applications/:appId/countries/:countryId',
                (req: Request, res: Response, next: NextFunction) =>
                    this.controller.getCountryStatus(
                        req.params.appId?.toUpperCase() as EApps,
                        req.params.countryId,
                        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                        req.query as any
                    ).then( res.json.bind(res), next ))
            .get('/applications/:appId/countries/:countryId/comments',
                (req: Request, res: Response, next: NextFunction) =>
                    this.controller.getCountryComments(
                        req.params.appId?.toUpperCase() as EApps, req.params.countryId, Number(req.query.roundSid)
                    ).then( res.json.bind(res), next ))
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
