import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzLibService, BaseRouter } from '../../..'
import { EErrors } from '../../../../../shared-lib/dist/prelib/error'
import { FDSharedService } from '../shared/fd-shared.service'
import { GuaranteeController } from './guarantee.controller'
import { GuaranteeService } from './guarantee.service'
import { IGuarantee } from '.'
import { MeasureSharedService } from '../..'

export class GuaranteeRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of GridRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: FDSharedService): Router {
        return new GuaranteeRouter(
            appId,
            new GuaranteeController(new GuaranteeService(appId, sharedService)),
            sharedService,
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps,
        private readonly controller: GuaranteeController,
        private readonly sharedService: FDSharedService,
    ) {
        super(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     * @overrides
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get(
                '/',
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getGuaranteesHandler.bind(this),
            )
            .get('/columns', this.getGuaranteeColumnsHandler.bind(this))
            .get(
                '/template/:countryId/:roundSid',
                AuthzLibService.checkCountryAuthorisation(),
                this.getUploadTemplateHandler.bind(this),
            )
            .get(
                '/wizard/:countryId/:roundSid',
                AuthzLibService.checkCountryAuthorisation(),
                this.getWizardDefinitionHandler.bind(this),
            )
            .post('/upload/:countryId', ...this.allowUpdateMiddleware(), this.uploadHandler.bind(this))
            .post(
                '/',
                ...this.allowUpdateMiddleware((req: Request) => req.body.COUNTRY_ID),
                this.newGuaranteeHandler.bind(this),
            )

        router
            .route('/:guaranteeSid')
            .get(
                AuthzLibService.checkCountryAuthorisation((req: Request) => req.query.countryId as string),
                this.getGuaranteeHandler.bind(this),
            )
            .put(
                ...this.allowUpdateMiddleware((req: Request) => req.body.COUNTRY_ID),
                this.updateGuaranteeHandler.bind(this),
            )
            .delete(
                ...this.allowUpdateMiddleware((req: Request) => req.query.countryId as string),
                this.deleteGuaranteeHandler.bind(this),
            )

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method allowUpdateMiddleware
     *********************************************************************************************/
    private allowUpdateMiddleware(countryGetter?: (req: Request) => string) {
        return [
            AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK', 'MS'),
            AuthzLibService.checkCountryAuthorisation(countryGetter),
            this.checkEditable(this.sharedService.isEditable, countryGetter),
        ]
    }

    /**********************************************************************************************
     * @method deleteGuaranteeHandler
     *********************************************************************************************/
    private deleteGuaranteeHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .deleteGuarantee(req.query.countryId as string, Number(req.params.guaranteeSid))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getGuaranteeColumnsHandler
     *********************************************************************************************/
    private getGuaranteeColumnsHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getGuaranteeColumns().then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getGuaranteeHandler
     *********************************************************************************************/
    protected getGuaranteeHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .getGuarantee(Number(req.params.guaranteeSid), req.query.countryId as string)
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getGuaranteesHandler
     *********************************************************************************************/
    private getGuaranteesHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .getGuarantees(req.query.countryId as string, MeasureSharedService.getReqArchiveParams(req.query))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getUploadTemplateHandler
     *********************************************************************************************/
    private getUploadTemplateHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .getWizardTemplate(
                req.params.countryId,
                Number(req.params.roundSid),
                req.query.withData === 'true',
                Number(req.query.dataHistoryOffset) || 0,
            )
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getWizardDefinitionHandler
     *********************************************************************************************/
    private getWizardDefinitionHandler(req: Request, res: Response, next: NextFunction) {
        this.controller
            .getWizardDefinition(req.params.countryId, Number(req.params.roundSid))
            .then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method newGuaranteeHandler
     *********************************************************************************************/
    private newGuaranteeHandler(req: Request, res: Response, next: NextFunction) {
        const guarantee: IGuarantee = req.body
        guarantee.GUARANTEE_SID = -1
        this.controller.saveGuarantee(guarantee).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method updateGuaranteeHandler
     *********************************************************************************************/
    private updateGuaranteeHandler(req: Request, res: Response, next: NextFunction) {
        const guarantee: IGuarantee = req.body
        if (guarantee.GUARANTEE_SID > 0) {
            this.controller.saveGuarantee(guarantee).then(res.json.bind(res), next)
        } else {
            res.json(EErrors.ID_NOT_PROVIDED)
        }
    }

    /**********************************************************************************************
     * @method uploadHandler
     *********************************************************************************************/
    private uploadHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.uploadGuarantees(req.params.countryId, req.body).then(res.json.bind(res), next)
    }
}
