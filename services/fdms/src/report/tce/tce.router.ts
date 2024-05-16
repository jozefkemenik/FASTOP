import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../../lib/dist'
import { BaseRouter } from '../../../../lib/dist/base-router'
import { EApps } from 'config'
import { SharedService } from '../../shared/shared.service'
import { TceController } from './tce.controller'
import { TceService } from './tce.service'


export class TceRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new TceRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: TceController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService) {
        super(appId)
        this.controller = new TceController(new TceService(appId, sharedService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {

        return router
            .get('/countries/:roundSid?/:storageSid?', this.getCountriesHandler)
            .get('/partners', this.getPartnersHandler)
            .get('/tradeItems', this.getTradeItemsHandler)
            .get('/matrix/:providerId/:roundSid?/:storageSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getMatrixDataHandler)
            .post('/data/tradeItems/:roundSid/:storageSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getTceTradeItemsDataHandler)
            .post('/data/:roundSid/:storageSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'AMECO'),
                this.getDataHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries(
            Number(req.params.roundSid),
            Number(req.params.storageSid)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getPartnersHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getPartnersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getPartners().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTradeItemsHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getTradeItemsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTradeItems().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMatrixDataHandler
     *********************************************************************************************/
    private getMatrixDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getMatrixData(
            req.params.providerId,
            Number(req.params.roundSid),
            Number(req.params.storageSid)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDataHandler
     *********************************************************************************************/
    private getDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTceData(
            req.body.countryIds,
            req.body.indicatorIds,
            req.body.partnerIds,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            req.query.compress === 'true'
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTceTradeItemsDataHandler
     *********************************************************************************************/
    private getTceTradeItemsDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTceTradeItemsData(
            req.body.countryIds,
            req.body.tradeItemIds,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            req.query.compress === 'true'
        ).then(res.json.bind(res), next)

}
