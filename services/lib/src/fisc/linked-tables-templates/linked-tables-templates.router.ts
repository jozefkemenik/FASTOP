import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'
import { FiscHttpHeader } from '../../../../shared-lib/dist/prelib/files'

import { LibLinkedTablesTplController } from './linked-tables-templates.controller'
import { LibLinkedTablesTplService } from './linked-tables-templates.service'

export class LibLinkedTablesTplRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new LibLinkedTablesTplRouter(
            new LibLinkedTablesTplController(new LibLinkedTablesTplService(appId))
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(private readonly controller: LibLinkedTablesTplController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configLocalRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        const multerUpload = this.getMulter('xls', 'xlsx')
        return router
            .get('/',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.templatesListHandler)
            .get('/:templateSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.templateDownloadHandler)
            .delete('/:templateSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.templateDeleteHandler)
            .post('/upload',
                AuthzLibService.checkAuthorisation('ADMIN'),
                multerUpload.single('template'),
                this.templateUploadHandler)
            .put('/activate/:templateSid',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.templateActivationHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method templateUploadHandler
     *********************************************************************************************/
    private templateUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadTemplate(
            req.file,
            req.body.descr,
            req.get('authLogin'),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method templateDefinitionHandler
     *********************************************************************************************/
    private templatesListHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTemplateList().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method templateDownloadHandler
     *********************************************************************************************/
    private templateDownloadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTemplate(Number(req.params.templateSid)).then(templateFile => {
            res.setHeader('Content-Disposition', `attachment;filename="${templateFile.fileName}"`)
            res.setHeader('Content-Type', templateFile.contentType)
            res.setHeader(FiscHttpHeader.FILE_NAME, templateFile.fileName)
            res.send(Buffer.from(templateFile.content))
            res.end()
        }, next)

    /**********************************************************************************************
     * @method templateDeleteHandler
     *********************************************************************************************/
    private templateDeleteHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.deleteTemplate(Number(req.params.templateSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method templateActivationHandler
     *********************************************************************************************/
    private templateActivationHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.activateTemplate(Number(req.params.templateSid)).then(res.json.bind(res), next)
}
