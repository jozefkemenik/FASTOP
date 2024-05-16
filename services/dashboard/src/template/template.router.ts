import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist'
import { EApps } from 'config'
import { ETemplateTypes } from '../../../shared-lib/dist/prelib/files'
import { TemplateController } from './template.controller'
import { TemplateService } from './template.service'


export class TemplateRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new TemplateRouter(new TemplateController(new TemplateService())).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly controller: TemplateController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/active/:appId/:templateId', this.getActiveTemplateHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActiveTemplateHandler
     *********************************************************************************************/
    private getActiveTemplateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getActiveTemplate(
            req.params.appId as EApps,
            req.params.templateId as ETemplateTypes,
        ).then(res.json.bind(res), next)
}
