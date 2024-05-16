import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'

import { SectionsController } from './sections.controller'
import { SharedService } from './../shared/shared.service'

export class SectionsRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new SectionsRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: SectionsController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super()
        this.controller = new SectionsController(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/:qstnnrVersionSid/:sectionVersionSid/hdrAttributes', this.getSectionHdrAttributes.bind(this))
            .get('/:qstnnrSectionSid/questions/:ruleSid', this.getSectionQuestions.bind(this))
            .get('/:qstnnrSectionSid/subsections', this.getSectionSubsections.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSectionHdrAttributes
     *********************************************************************************************/
    private getSectionHdrAttributes(req: Request, res: Response, next: NextFunction) {
        this.controller.getSectionHdrAttributes(
            Number(req.params.qstnnrVersionSid),
            Number(req.params.sectionVersionSid)
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getSectionQuestions
     *********************************************************************************************/
    private getSectionQuestions(req: Request, res: Response, next: NextFunction) {
        this.controller.getSectionQuestions(
            Number(req.params.qstnnrSectionSid),
            Number(req.params.ruleSid),
            Number(req.query.roundSid),
            Number(req.query.periodSid)
        ).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getSectionSubsections
     *********************************************************************************************/
    private getSectionSubsections(req: Request, res: Response, next: NextFunction) {
        this.controller.getSectionSubsections(
            Number(req.params.qstnnrSectionSid)
        ).then(res.json.bind(res), next)
    }

}
