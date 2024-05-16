import { NextFunction, Request, Response, Router } from 'express'

import { MeasureConfigRouter } from '../../../lib/dist/measure'

import { ConfigController } from './config.controller'
import { SharedService } from '../shared/shared.service'

export class ConfigRouter extends MeasureConfigRouter<SharedService, ConfigController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new ConfigRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super(
            sharedService,
            new ConfigController(sharedService),
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configLocalRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/custStorageTexts/:roundSid',
                (req: Request, res: Response, next: NextFunction) =>
                    this.controller.getCustStorageTexts(Number(req.params.roundSid)).then( res.json.bind(res), next)
            )
            .get('/oneOffPrinciples', (req: Request, res: Response, next: NextFunction) =>
                this.controller.getOneOffPrinciples().then( res.json.bind(res), next))
            .get('/overviews/:isFilter?', (req: Request, res: Response, next: NextFunction) =>
                this.controller.getOverviews(req.params.isFilter === "1").then( res.json.bind(res), next))
            .get('/revExp', (req: Request, res: Response, next: NextFunction) =>
                this.controller.getRevExp().then( res.json.bind(res), next))
            .get('/statuses', (req: Request, res: Response, next: NextFunction) =>
                this.controller.getStatuses().then( res.json.bind(res), next))
            .get('/ESAPeriod/:roundSid', (req: Request, res: Response, next: NextFunction) =>
                this.controller.getESAPeriod(Number(req.params.roundSid)).then(  res.json.bind(res), next))

        return super.configRoutes(router)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
