import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { HicpController } from './hicp.controller'
import { HicpDataset } from './shared-interfaces'
import { HicpMongoService } from './hicp.mongo.service'
import { HicpService } from './hicp.service'
import { IDBDataType } from './index'


export class HicpRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new HicpRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: HicpController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this.controller = new HicpController(appId, new HicpService(), new HicpMongoService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/countries',
                this.getCountriesHandler)
            .get('/indicators/code',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.getIndicatorCodesHandler)
            .get('/indicators/data/:countryId/:dataset',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.getIndicatorsDataHandler)
            .post('/indicators/raw/:countryId/:dataType',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.getRawIndicatorsHandler)
            .post('/indicators/excel/:countryId/:dataset',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.getIndicatorsExcelDataHandler)
            .get('/anomaliesRange',
                this.getAnomaliesRangeHandler)
            .get('/categories',
                this.getUserCategoriesHandler)
            .post('/category',
                this.createCategoryHandler)
            .put('/category/:categorySid',
                this.updateCategoryHandler)
            .delete('/category/:categorySid',
                this.deleteCategoryHandler)
            .put('/calculateBase',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.calculateBaseHandler)
            .put('/calculateBaseEffect',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.calculateBaseEffectHandler)
            .put('/calculateContributions',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.calculateContributionsHandler)
            .put('/calculateAnomalies',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.calculateAnomaliesHandler)
            .put('/calculateBaseStats',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.calculateBaseStatsHandler)
            .put('/calculateTramoSeats',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC'),
                this.calculateTramoSeatsHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorsExcelDataHandler
     *********************************************************************************************/
    private getIndicatorsExcelDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getExcelData(
            req.params.countryId, req.params.dataset as HicpDataset,
            req.query.from as string, req.query.to as string,
            req.body,
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsDataHandler
     *********************************************************************************************/
    private getIndicatorsDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorsData(
            req.params.countryId, req.params.dataset as HicpDataset
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getRawIndicatorsHandler
     *********************************************************************************************/
    private getRawIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getRawIndicatorsData(
            req.params.countryId,
            req.params.dataType as IDBDataType,
            req.body
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorCodesHandler
     *********************************************************************************************/
    private getIndicatorCodesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorCodes().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getUserCategoriesHandler
     *********************************************************************************************/
    private getUserCategoriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getUserCategories(this.getUserId(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method createCategoryHandler
     *********************************************************************************************/
    private createCategoryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.createCategory(req.body, this.getUserId(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method updateCategoryHandler
     *********************************************************************************************/
    private updateCategoryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.updateCategory(
            Number(req.params.categorySid), req.body, this.getUserId(req)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method deleteCategoryHandler
     *********************************************************************************************/
    private deleteCategoryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.deleteCategory(
            Number(req.params.categorySid), this.getUserId(req)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateBaseHandler
     *********************************************************************************************/
    private calculateBaseHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateBase(req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateBaseStatsHandler
     *********************************************************************************************/
    private calculateBaseStatsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateBaseStats(req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateTramoSeatsHandler
     *********************************************************************************************/
    private calculateTramoSeatsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateTramoSeats(req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateBaseEffectHandler
     *********************************************************************************************/
    private calculateBaseEffectHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateBaseEffect(req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateContributionsHandler
     *********************************************************************************************/
    private calculateContributionsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateContributions(req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateAnomaliesHandler
     *********************************************************************************************/
    private calculateAnomaliesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateAnomalies(req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAnomaliesRangeHandler
     *********************************************************************************************/
    private getAnomaliesRangeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAnomaliesRange().then(res.json.bind(res), next)
}
