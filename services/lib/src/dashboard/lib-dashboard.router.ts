import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../authzLib.service'
import { EDashboardActions } from '../../../shared-lib/dist/prelib/dashboard'

import { AuthzError } from '../error.service'
import { BaseRouter } from '../base-router'
import { LibDashboardController } from './lib-dashboard.controller'

export abstract class LibDashboardRouter<C extends LibDashboardController> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(protected readonly controller: C) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/', this.getDashboardHandler)
            .get('/presubmit/:countryId/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'MS'),
                AuthzLibService.checkCountryAuthorisation(),
                this.presubmitHandler)
            .post('/action/:action/:countryId',
                this.checkActionAuthorisation.bind(this),
                AuthzLibService.checkCountryAuthorisation(),
                this.performActionHandler.bind(this))
            .get('/actions', this.getActionsHandler.bind(this))
    }

    /**********************************************************************************************
     * @method checkActionAuthorisation
     *********************************************************************************************/
    protected checkActionAuthorisation(req: Request, res: Response, next: NextFunction): void {

        let checkFunction: (req: Request, res: Response, next: NextFunction) => void

        switch (req.params.action) {
            case EDashboardActions.SUBMIT:
            case EDashboardActions.TR_SUBMIT:
                checkFunction = AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'GBL_ECON', 'MS')
                break
            case EDashboardActions.UNSUBMIT:
            case EDashboardActions.TR_UNSUBMIT:
            case EDashboardActions.VALIDATE:
                checkFunction = AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK')
                break
            case EDashboardActions.UNVALIDATE:
            case EDashboardActions.ACCEPT:
            case EDashboardActions.UNACCEPT:
            case EDashboardActions.REJECT:
            case EDashboardActions.ARCHIVE:
                checkFunction = AuthzLibService.checkAuthorisation('ADMIN')
                break
            default:
                next(new AuthzError())
                return
        }
        checkFunction(req, res, next)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActionsHandler
     *********************************************************************************************/
    private getActionsHandler(req: Request, res: Response, next: NextFunction): void {
        this.controller.getActions().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getDashboardHandler
     *********************************************************************************************/
    private getDashboardHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDashboard(AuthzLibService.isAdmin(req), AuthzLibService.getUserCountries(req))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getPresubmitHandler
     *********************************************************************************************/
    private presubmitHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.presubmitCheck(req.params.countryId, Number(req.params.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method performActionHandler
     *********************************************************************************************/
    private performActionHandler(req: Request, res: Response, next: NextFunction): void {
        this.controller.performAction(
            req.params.action as EDashboardActions,
            req.params.countryId,
            req.body.currentStatusId,
            req.body.roundKeys,
            req.body.comment,
            this.getUserId(req),
            Boolean(req.body.confirmed)
        ).then(res.json.bind(res), next)
    }
}
