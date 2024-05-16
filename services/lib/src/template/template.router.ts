import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService, BaseRouter } from '..'
import { ETemplateTypes } from '../../../shared-lib/dist/prelib/files'
import { TemplateController } from './template.controller'

export class TemplateRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new TemplateRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: TemplateController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super(appId)
        this.controller = new TemplateController(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/active/:templateId',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON'),
                this.getActiveTemplateHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActiveTemplateHandler
     *********************************************************************************************/
    private getActiveTemplateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getActiveTemplate(
            req.params.templateId as ETemplateTypes,
        ).then(templateFile => this.sendFile(templateFile, res), next)

}
