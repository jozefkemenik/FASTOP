import { NextFunction, Request, Response, Router } from 'express'

import { FDSharedService } from '../shared/fd-shared.service'
import { MeasureConfigController } from '../../config/measure-config.controller'
import { MeasureConfigRouter } from '../../config/measure-config.router'

export abstract class FDConfigRouter<
    S extends FDSharedService,
    C extends MeasureConfigController<S>,
> extends MeasureConfigRouter<S, C> {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(sharedService: S, controller: C) {
        super(sharedService, controller)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     * @overrides
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/accountingPrinciples', this.getDbpAccountingPrinciplesHandler.bind(this))
            .get('/adoptionStatuses', this.getDbpAdoptionStatusesHandler.bind(this))
            .get('/reasons', this.getReasonsHandler.bind(this))

        return super.configRoutes(router)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDbpAccountingPrinciplesHandler
     *********************************************************************************************/
    private getDbpAccountingPrinciplesHandler(req: Request, res: Response, next: NextFunction) {
        this.sharedService.getDbpAccountingPrinciples().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getDbpAdoptionStatusesHandler
     *********************************************************************************************/
    private getDbpAdoptionStatusesHandler(req: Request, res: Response, next: NextFunction) {
        this.sharedService.getDbpAdoptionStatuses().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getReasonsHandler
     *********************************************************************************************/
    private getReasonsHandler(req: Request, res: Response, next: NextFunction) {
        this.sharedService.getGuaranteeReasons(req.query.array === 'true').then(res.json.bind(res), next)
    }
}
