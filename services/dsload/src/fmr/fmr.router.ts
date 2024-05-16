import { AuthzLibService, LoggingService } from '../../../lib/dist'
import { NextFunction, Request, Response, Router } from 'express'
import { BaseRouter } from '../../../lib/dist/base-router'
import { EApps } from 'config'
import { FMRController } from './fmr.controller'
import { FmrService } from './fmr.service'

export class FMRRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, logs: LoggingService): Router {
        return new FMRRouter(appId, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: FMRController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(appId: EApps, logs: LoggingService) {
        super(appId)
        this.controller = new FMRController(new FmrService(), logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/dataflows', AuthzLibService.checkAuthorisation('ADMIN'), this.getDataflowsHandler)
            .get(
                '/template/:dataflowId',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.xlsxTemplateHandler.bind(this),
            )
            .get(
                '/datastructure/:dataflowId',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getDatastructureHandler,
            )
            .post('/logupload', AuthzLibService.checkAuthorisation('ADMIN'), this.setLogUploadHandler)
            .get('/logupload/:uploadSid?', AuthzLibService.checkAuthorisation('ADMIN'), this.getLogUploadHandler)
            .put('/logupload/:uploadSid', AuthzLibService.checkAuthorisation('ADMIN'), this.updateLogUploadHandler)
            .put('/logupload/cancel/:uploadSid', AuthzLibService.checkAuthorisation('ADMIN'), this.cancelHandler)
            .put('/logupload/finish/:uploadSid', AuthzLibService.checkAuthorisation('ADMIN'), this.finishHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDataflowsHandler
     *********************************************************************************************/
    private getDataflowsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDataflows().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDatastructureHandler
     *********************************************************************************************/
    private getDatastructureHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDatastructure(req.params.dataflowId).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method xlsxTemplateHandler
     *********************************************************************************************/
    private xlsxTemplateHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .generateXslTemplate(req.params.dataflowId)
            .then(templateFile => {
                res.setHeader('Content-Disposition', `attachment;filename="${templateFile.name}.xlsx"`)
                res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                res.send(this.controller.makeExcel(templateFile.sheets))
                res.end()
            }, next)
            .catch(e => {
                res.status(400)
                res.send(e)
                res.end()
            })
    }

    /**********************************************************************************************
     * @method setLogUploadHandler
     *********************************************************************************************/
    private setLogUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.setLogUpload(req.body, this.getUserId(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLogUploadHandler
     *********************************************************************************************/
    private getLogUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller
            .getLogUpload(this.getUserId(req), req.params.uploadSid ? Number(req.params.uploadSid) : undefined)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method updateLogUploadHandler
     *********************************************************************************************/
    private updateLogUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.updateLogUpload(Number(req.params.uploadSid), req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method cancelHandler
     *********************************************************************************************/
    private cancelHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.cancelHandler(Number(req.params.uploadSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method finishHandler
     *********************************************************************************************/
    private finishHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.finishHandler(Number(req.params.uploadSid)).then(res.json.bind(res), next)
}
