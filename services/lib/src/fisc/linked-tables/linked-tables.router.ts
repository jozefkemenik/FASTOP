import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'
import { FiscHttpHeader } from '../../../../shared-lib/dist/prelib/files'

import { LibLinkedTablesController } from './linked-tables.controller'

export class LibLinkedTablesRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter<T extends LibLinkedTablesController>(controller: T): Router {
        return new LibLinkedTablesRouter(controller).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(private readonly controller: LibLinkedTablesController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configLocalRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/validate/:countryId/:roundSid/',
                  AuthzLibService.checkCountryAuthorisation(),
                  this.validationHandler)
            .get('/excel/data/:countryId/:roundSid/',
                  AuthzLibService.checkCountryAuthorisation(),
                  this.excelDataHandler)
            .get('/excel/template/check',
                this.excelTemplateCheckHandler)
            .get('/excel/template/',
                  this.excelTemplateHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method validationHandler
     *********************************************************************************************/
    private validationHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.validate(
            req.params.countryId, Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method excelDataHandler
     *********************************************************************************************/
    private excelDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.downloadExcelData(
            req.params.countryId, Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method excelTemplateHandler
     *********************************************************************************************/
    private excelTemplateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.downloadExcelTemplate().then(templateFile => {
            if (templateFile) {
                res.setHeader('Content-Disposition', `attachment;filename="${templateFile.fileName}"`)
                res.setHeader('Content-Type', templateFile.contentType)
                res.setHeader(FiscHttpHeader.FILE_NAME, templateFile.fileName)
                res.send(Buffer.from(templateFile.content))
            } else {
                res.sendStatus(204)
            }
            res.end()
        }, next)

    /**********************************************************************************************
     * @method excelTemplateCheckHandler
     *********************************************************************************************/
    private excelTemplateCheckHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.checkExcelTemplate().then(res.json.bind(res), next)
}
