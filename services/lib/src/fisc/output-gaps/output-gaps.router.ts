import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

import { LibOutputGapsController } from './output-gaps.controller'

export class LibOutputGapsRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter<T extends LibOutputGapsController>(controller: T): Router {
        return new LibOutputGapsRouter(controller).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(private readonly controller: LibOutputGapsController) {
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
            .put('/structuralBalance/:countryId/:roundSid',
                  AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                  AuthzLibService.checkCountryAuthorisation(),
                  this.calculateStructuralBalanceHandler)
            .put('/calculate/:countryId/:roundSid',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                AuthzLibService.checkCountryAuthorisation(),
                this.calculateOutputGapHandler)
            .get('/validate/:countryId/:roundSid',
                  AuthzLibService.checkCountryAuthorisation(),
                  this.validationHandler)
            .get('/ltValid/:countryId/:roundSid',
                  this.isValidForLinkedTablesHandler)
            .get('/msGridLines/:countryId/:roundSid',
                  AuthzLibService.checkCountryAuthorisation(),
                  this.memberStateGridLinesHandler)
            .get('/yearsRange',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.getYearsRangeHandler)
            .put('/yearsRange',
                AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
                this.updateYearsRangeHandler)
            .get('/eucamLightVersion',
                this.getEucamLightVersionHandler)
            // .get('/baseline/def',
            //       AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //       this.baselineDefinitionHandler)
            // .get('/baseline/data/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.baselineDataHandler)
            // .post('/baseline/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.baselineUploadHandler)
            // .get('/countryParams/def',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.countryParamsDefinitionHandler)
            // .get('/countryParams/data/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.countryParamsDataHandler)
            // .post('/countryParams/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.countryParamsUploadHandler)
            // .get('/generalParams/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.generalParamsHandler)
            // .post('/generalParams/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.generalParamsUploadHandler)
            // .get('/changeY/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.getChangeYHandler)
            // .put('/changeY/:roundSid',
            //     AuthzLibService.checkAuthorisation('ADMIN', 'CTY_DESK'),
            //     this.getChangeYUpdateHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateStructuralBalanceHandler
     *********************************************************************************************/
    private calculateStructuralBalanceHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateStructuralBalance(
            req.params.countryId,
            Number(req.params.roundSid),
            req.get('authLogin'),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method calculateOutputGapHandler
     *********************************************************************************************/
    private calculateOutputGapHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.calculateOutputGap(
            req.params.countryId,
            Number(req.params.roundSid),
            req.get('authLogin'),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method baselineDefinitionHandler
     *********************************************************************************************/
    private baselineDefinitionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getBaselineDefinition().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method baselineDataHandler
     *********************************************************************************************/
    private baselineDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getBaselineData(Number(req.params.roundSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method baselineUploadHandler
     *********************************************************************************************/
    private baselineUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadBaselineData(Number(req.params.roundSid), req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method countryParamsDefinitionHandler
     *********************************************************************************************/
    private countryParamsDefinitionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryParamsDefinition().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method countryParamsDataHandler
     *********************************************************************************************/
    private countryParamsDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryParamsData(Number(req.params.roundSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method countryParamsUploadHandler
     *********************************************************************************************/
    private countryParamsUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadCountryParameters(Number(req.params.roundSid), req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method generalParamsHandler
     *********************************************************************************************/
    private generalParamsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getGeneralParams(Number(req.params.roundSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method generalParamsUploadHandler
     *********************************************************************************************/
    private generalParamsUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.uploadGeneralParameters(Number(req.params.roundSid), req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method validationHandler
     *********************************************************************************************/
    private validationHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.validate(
            req.params.countryId,
            Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method isValidForLinkedTablesHandler
     *********************************************************************************************/
    private isValidForLinkedTablesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.validateForLinkedTables(
            req.params.countryId,
            Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method memberStateGridLinesHandler
     *********************************************************************************************/
    private memberStateGridLinesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getMemberStateGridLines(
            req.params.countryId,
            Number(req.params.roundSid),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getYearsRangeHandler
     *********************************************************************************************/
    private getYearsRangeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getYearsRange().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method updateYearsRangeHandler
     *********************************************************************************************/
    private updateYearsRangeHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.updateYearsRange(req.body.yearsRange).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getChangeYHandler
     *********************************************************************************************/
    private getChangeYHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getChangeY(Number(req.params.roundSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getChangeYUpdateHandler
     *********************************************************************************************/
    private getChangeYUpdateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.updateChangeY(Number(req.params.roundSid), req.body.changeY).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getEucamLightVersionHandler
     *********************************************************************************************/
    private getEucamLightVersionHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getEucamLightVersion().then(res.json.bind(res), next)

}
