import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, BaseRouter } from '../../../lib/dist'
import { EApps } from 'config'
import { ISearchCriteria } from './shared-interfaces'
import { IndicatorsController } from './indicators.controller'
import { IndicatorsService } from './indicators.service'

export class IndicatorsRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of StatsRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new IndicatorsRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: IndicatorsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(appId: EApps) {
        super(appId)
        this.controller = new IndicatorsController(new IndicatorsService(), appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for TasksRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/codes/data', AuthzLibService.checkAuthorisation('ADMIN'), this.getCodesDataHandler)
            .post('/codes/data', AuthzLibService.checkAuthorisation('ADMIN'), this.setCodesDataHandler.bind(this))
            .get('/dictionary', AuthzLibService.checkAuthorisation('ADMIN'), this.getDictionaryHandler)
            .get('/data', AuthzLibService.checkAuthorisation('ADMIN'), this.getDataHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorCodesDataHandler
     *********************************************************************************************/
    private getCodesDataHandler = (req: Request, res: Response, next: NextFunction) => {
        const param: ISearchCriteria = {
            indicators: JSON.parse((req.query.indicators ?? '[]') as string),
            forecast: JSON.parse(req.query.forecast  as string) as boolean,
            providers: [],
            periodicities: [],
        }

        return this.controller.getIndicatorCodesData(param).then(res.json.bind(res), next)
    }
    /**********************************************************************************************
     * @method getDictionaryHandler
     *********************************************************************************************/
    private getDictionaryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDictionary().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCodesDataHandler
     *********************************************************************************************/
    private getDataHandler = (req: Request, res: Response, next: NextFunction) => {
        const param: ISearchCriteria = {
            indicators: JSON.parse((req.query.indicators ?? '[]') as string),
            forecast: null,
            providers: JSON.parse((req.query.providers ?? '[]') as string),
            periodicities: JSON.parse((req.query.periodicities ?? '[]') as string),
        }

        return this.controller.getIndicatorData(param).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method setCodesDataHandler
     *********************************************************************************************/
    private setCodesDataHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.setIndicatorCodeData(req.body).then(res.json.bind(res), next)
    }
}
