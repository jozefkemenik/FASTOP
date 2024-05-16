import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { EerController } from './eer.controller'
import { EerService } from './eer.service'

export class EerRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new EerRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: EerController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this.controller = new EerController(appId, new EerService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/calculated/:providerId', this.getCalculatedHandler)
            .get('/uploads/:providerId', this.getProviderUploadHandler)
            .get('/uploads', this.getUploadsHandler)
            .get('/geo/groups', this.getGeoGroupsHandler)
            .get(
                '/indicator/data/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getIndicatorDataHandler,
            )
            .post(
                '/indicator/data/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getIndicatorDataUploadHandler,
            )
            .get('/countries', this.getCountriesHandler)
            .get('/matrix/years/:providerId', this.getMatrixProviderYearsHandler)
            .get(
                '/matrix/data/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getMatrixDataHandler,
            )
            .post(
                '/matrix/data/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getMatrixDataUploadHandler,
            )
            .get('/exportToZip/:type',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getExporterHandler
            )
            .get('/baseYear',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.getBaseYearHandler
            )
            .post('/baseYear',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'PUBLIC', 'FORECAST'),
                this.setBaseYearHandler
        )
        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCalculatedHandler
     *********************************************************************************************/
    private getCalculatedHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.isCalculated(req.params.providerId as string).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getUploadsHandler
     *********************************************************************************************/
    private getUploadsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getUploads().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getProviderUploadHandler
     *********************************************************************************************/
    private getProviderUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getProviderUpload(req.params.providerId as string).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorDataHandler
     *********************************************************************************************/
    private getIndicatorDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getIndicatorData(req.params.providerId, req.query.group as string, req.query.periodicity as string)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorDataUploadHandler
     *********************************************************************************************/
    private getIndicatorDataUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .uploadIndicatorData(req.params.providerId, req.body, this.getUserId(req))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMatrixDataUploadHandler
     *********************************************************************************************/
    private getMatrixDataUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .uploadMatrixData(req.params.providerId, req.body, this.getUserId(req))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMatrixDataHandler
     *********************************************************************************************/
    private getMatrixDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getMatrixData(
                req.params.providerId,
                req.query.group as string,
                this.getArrayQueryParam(req.query.years).map(Number),
            )
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGeoGroupsHandler
     *********************************************************************************************/
    private getGeoGroupsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGeoGroups(req.query.activeOnly === 'true').then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMatrixProviderYearsHandler
     *********************************************************************************************/
    private getMatrixProviderYearsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getMatrixYears(req.params.providerId).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getExporterHandler
     *********************************************************************************************/
    private getExporterHandler = (req: Request, res: Response, next: NextFunction) => {
        this.controller.getExporter(req.params.type).then(buffer => {
            res.send(buffer)
        }, next)
    }

    /**********************************************************************************************
     * @method getBaseYearHandler
     *********************************************************************************************/
    private getBaseYearHandler = (req: Request, res: Response, next: NextFunction) => {
        this.controller.getBaseYear().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method setBaseYearHandler
     *********************************************************************************************/
    private setBaseYearHandler = (req: Request, res: Response, next: NextFunction) => {
        this.controller.setBaseYear(req.body.year).then(res.json.bind(res), next)
    }
}
