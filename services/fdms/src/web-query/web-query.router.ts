import { NextFunction, Request, Response, Router } from 'express'
import { ParsedQs } from 'qs'

import { EApps } from 'config'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { IWQParams } from '../../../web-queries/src/shared/shared-interfaces'

import { SharedService } from '../shared/shared.service'
import { WebQueryController } from './web-query.controller'

export class WebQueryRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new WebQueryRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: WebQueryController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService) {
        super(appId)
        this.controller = new WebQueryController(appId, sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .use(AuthzLibService.checkAuthorisation())

            .get('/indicators',
                this.getWebQueryIndicatorsDataHandler)
            .get('/horizontalIndicator/:indicatorId/:providerId',
                this.getHorizontalIndicatorHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getHorizontalIndicatorHandler
     *********************************************************************************************/
    private getHorizontalIndicatorHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderIndicators(
            Object.assign(this.parsedQsToWQParams(req.query),
                { providerId: req.params.providerId, indicatorIds: [req.params.indicatorId]})
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getWebQueryIndicatorsDataHandler
     *********************************************************************************************/
    private getWebQueryIndicatorsDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderIndicators(this.parsedQsToWQParams(req.query)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method parsedQsToWQParams
     *********************************************************************************************/
    private parsedQsToWQParams(query: ParsedQs): IWQParams {
        return {
            countryIds: typeof query.countryIds === 'string' ? query.countryIds?.split(',') : undefined,
            ctyGroup: typeof query.ctyGroup === 'string' ? query.ctyGroup : undefined,
            yearsRange: typeof query.yearsRange === 'string' ? query.yearsRange?.split(',').map(Number) : undefined,
            periodicity: typeof query.periodicity === 'string' ? query.periodicity : undefined,
            providerId: typeof query.providerId === 'string' ? query.providerId : undefined,
            indicatorIds: typeof query.indicatorIds === 'string' ? query.indicatorIds?.split(',') : undefined,
            roundSid: query.roundSid !== undefined ? Number(query.roundSid) : undefined,
            storageSid: query.storageSid !== undefined ? Number(query.storageSid) : undefined,
        }
    }
}
