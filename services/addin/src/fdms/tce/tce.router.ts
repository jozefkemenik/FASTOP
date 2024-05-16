import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'
import { FdmsRouter } from '../shared/fdms.router'
import { TceController } from './tce.controller'

export class TceRouter extends FdmsRouter<TceController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new TceRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(appId: EApps ) {
        super(appId, new TceController(), ['TCE_RSLTS'], )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/countries', this.getTceCountriesHandler)
            .get('/tradeItems', this.getTradeItemsHandler)
            .get('/indicators', this.getFdmsIndicatorsHandler)
            .get('/partners', this.getPartnersHandler)
            .post(
                '/data/tradeItems',
                this.checkRoundAccess('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getTceDataByTradeItemsHandler,
            )
            .post(
                '/data',
                this.checkRoundAccess('ADMIN', 'CTY_DESK', 'FORECAST'),
                this.getTceDataHandler,
            )

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTceCountriesHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getTceCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTceCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTradeItemsHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getTradeItemsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTradeItems().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getPartnersHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getPartnersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getPartners().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTceDataByTradeItemsHandler
     *********************************************************************************************/
    private getTceDataByTradeItemsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTceDataByTradeItems(
            req.body.countryIds,
            req.body.tradeItemIds,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.textSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTceDataHandler
     *********************************************************************************************/
    private getTceDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTceData(
            req.body.countryIds,
            req.body.indicatorIds,
            req.body.partnerIds,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            Number(req.query.textSid),
        ).then(res.json.bind(res), next)
}
