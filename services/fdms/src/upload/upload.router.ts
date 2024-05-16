import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { FiscHttpHeader } from '../../../shared-lib/dist/prelib/files'

import { SharedService } from '../shared/shared.service'
import { UploadController } from './upload.controller'
import { UploadService } from './upload.service'

export class UploadRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new UploadRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: UploadController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, sharedService: SharedService) {
        super()
        this.controller = new UploadController(appId, new UploadService(appId), sharedService)
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
            .get('/indicators',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON', 'AMECO'),
                this.getIndicatorsHandler)
            .get('/indicatorsMappings',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON', 'AMECO'),
                this.getIndicatorsMappingsHandler)
            .get('/scales',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON', 'AMECO'),
                this.getScalesHandler)
            .get('/ctyIndicatorScales/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON', 'AMECO'),
                this.getCtyIndicatorScalesHandler)
            .get('/indicatorData/uploads/:roundSid/:storageSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON', 'AMECO'),
                this.getIndicatorDataUploadsHandler)
            .post('/indicatorData/:roundSid/:storageSid/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.uploadIndicatorDataHandler)
            .post('/indicatorData/:roundSid/:storageSid/:providerId/:countryIds',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.params.countryIds),
                this.uploadIndicatorDataHandler)
            .get('/desk/:countryId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                AuthzLibService.checkCountryAuthorisation(),
                this.getDeskUploadHandler)
            .post('/tceData/:roundSid/:storageSid/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN',),
                this.uploadTceDataHandler)
            .get('/outputGap/result/:roundSid/:storageSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getOutputGapResultHandler)
            .get('/outputGap/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getOutputGapUploadHandler)
            .get('/commodities/:providerId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getCommoditiesUploadHandler)
            .get('/commodities/result/:roundSid/:storageSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getCommoditiesResultHandler)
            .put('/FDMSStorageCopy',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.body.countryIds),
                this.fdmsStorageCopyHandler)
            .get('/eer',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.body.countryIds),
                this.getEerDataHandler)
            .post('/file/:providerId/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                multerUpload.single('file'),
                this.fileUploadHandler)
            .get('/files/:roundSid/:storageSid/:custTextSid?',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getFilesHandler)
            .get('/file/:fileSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.fileDownloadHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method fdmsStorageCopyHandler
     *********************************************************************************************/
    private fdmsStorageCopyHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.copyFromFDMSStorage(req.body, this.getUserId(req)).then(res.json.bind(res), next)


    /**********************************************************************************************
     * @method getEerDataHandler
     *********************************************************************************************/
    private getEerDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getEerData().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDeskUploadHandler
     *********************************************************************************************/
    private getDeskUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDeskUpload(
            req.params.countryId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            req.query.sendData === 'true',
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
     * @method getOutputGapResultHandler
     *********************************************************************************************/
    private getOutputGapResultHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getOutputGapResult(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getIndicatorDataUploadsHandler
     *********************************************************************************************/
    private getIndicatorDataUploadsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getIndicatorDataUploads(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
        ).then(res.json.bind(res), next)

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
     * @method getScalesHandler
     *********************************************************************************************/
    private getScalesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getScales().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method uploadIndicatorDataHandler
     *********************************************************************************************/
    private uploadIndicatorDataHandler = (req: Request, res: Response, next: NextFunction) =>
            this.controller.uploadIndicatorData(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            req.params.providerId,
            req.params.countryIds?.split(','),
            req.body,
            this.getUserId(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method uploadTceDataHandler
     *********************************************************************************************/
    private uploadTceDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadTceDataHandler(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            req.params.providerId,
            req.body,
            this.getUserId(req),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCommoditiesUploadHandler
     *********************************************************************************************/
    private getCommoditiesUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCommoditiesUpload(
            req.params.providerId,
            Number(req.query.roundSid),
            Number(req.query.storageSid),
            req.query.sendData === 'true',
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCommoditiesResultHandler
     *********************************************************************************************/
    private getCommoditiesResultHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCommoditiesResult(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method fileUploadHandler
     *********************************************************************************************/
    private fileUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadFile(
            req.query.countryId as string,
            req.params.providerId,
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
            req.file,
            req.get('authLogin'),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getFilesHandler
     *********************************************************************************************/
    private getFilesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getFiles(
            Number(req.params.roundSid),
            Number(req.params.storageSid),
            Number(req.params.custTextSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method fileDownloadHandler
     *********************************************************************************************/
    private fileDownloadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.downloadFile(Number(req.params.fileSid)).then(file => {
            res.setHeader('Content-Disposition', `attachment;filename="${file.fileName}"`)
            res.setHeader('Content-Type', file.contentType)
            res.setHeader(FiscHttpHeader.FILE_NAME, file.fileName)
            res.send(Buffer.from(file.content))
            res.end()
        }, next)

    /**********************************************************************************************
     * @method getCtyIndicatorScalesHandler
     *********************************************************************************************/
    private getCtyIndicatorScalesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCtyIndicatorScales(
            req.params.providerId,
        ).then(res.json.bind(res), next)
}
