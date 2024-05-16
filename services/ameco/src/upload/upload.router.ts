import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { UnemploymentRouter } from './unemployment/unemployment.router'
import { UploadController } from './upload.controller'
import { UploadService } from './upload.service'


export class UploadRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new UploadRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: UploadController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this.controller = new UploadController(appId, new UploadService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        const multerUpload = this.getMulter('xls', 'xlsx', 'xlsm', 'csv', 'txt')
        return router
            .use('/unemployment', UnemploymentRouter.createRouter(this.appId))
            .get('/scales',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getScalesHandler)
            .get('/indicators',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getIndicatorsHandler)
            .get('/indicatorsMappings',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getIndicatorsMappingsHandler)
            .post('/indicatorData/:roundSid/:storageSid/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.uploadIndicatorDataHandler)
            .get('/outputGap/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getOutputGapUploadHandler)
            .post('/file/:providerId/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN'),
                multerUpload.single('file'),
                this.fileUploadHandler)
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getScalesHandler
     *********************************************************************************************/
    private getScalesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getScales().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsHandler
     *********************************************************************************************/
    private getIndicatorsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicators(req.query.providerId as string).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorsMappingsHandler
     *********************************************************************************************/
    private getIndicatorsMappingsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorsMappings(req.query.providerId as string).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method uploadIndicatorDataHandler
     *********************************************************************************************/
    private uploadIndicatorDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadIndicatorData(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            req.params.providerId,
            req.body,
            this.getUserId(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getOutputGapUploadHandler
     *********************************************************************************************/
    private getOutputGapUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getOutputGapUpload(
            req.params.providerId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            req.query.sendData === 'true',
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method fileUploadHandler
     *********************************************************************************************/
    private fileUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadFile(
            req.file,
            req.query.countryId as string,
            req.params.providerId,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
            this.getUserId(req),
        ).then(res.json.bind(res), next)
}
