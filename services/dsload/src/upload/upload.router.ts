import * as proxy from 'express-http-proxy'
import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../lib/dist'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { UploadController } from './upload.controller'
import { config } from '../../../config/config'

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

    private readonly controller: UploadController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new UploadController()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .put(
                '/prepare/:uploadSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.prepareUploadHandler,
            )
            .put('/validate/:uploadSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.validateFilesHandler,
            )
            .put('/publish/:uploadSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.publishFilesHandler,
            )
            .delete('/deleteFile/:uploadSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.deleteFileHandler,
            )
            .post(
                '/:uploadSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                proxy(
                    `${config.apps[EApps.FPLM].host}:${config.apps[EApps.FPLM].port}`,
                    { 
                        proxyReqPathResolver: (req: Request) => `/upload/${req.params.uploadSid}`,
                        parseReqBody: false,
                    }
                ),
            )
            .delete('/:uploadSid',AuthzLibService.checkAuthorisation('ADMIN'),
            this.deleteFileHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method prepareUploadHandler
     *********************************************************************************************/
    private prepareUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.prepareUpload(
            Number(req.params.uploadSid)
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method publishFilesHandler
     *********************************************************************************************/
    private publishFilesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.publishFiles(
            Number(req.params.uploadSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method validateFilesHandler
     *********************************************************************************************/
    private validateFilesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.validateFiles(
            Number(req.params.uploadSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method deleteFileHandler
     *********************************************************************************************/
    private deleteFileHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.deleteFile(
            Number(req.params.uploadSid),
            req.body.file
        ).then(res.json.bind(res), next)


}
