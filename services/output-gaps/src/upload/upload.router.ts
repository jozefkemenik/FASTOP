import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { UploadController } from './upload.controller'
import { UploadService } from './upload.service'


export class UploadRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(): Router {
        return new UploadRouter().buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: UploadController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor() {
        super()
        this.controller = new UploadController(new UploadService())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/baseline/def', this.baselineDefinitionHandler)
            .get('/baseline/data/:roundSid', this.baselineDataHandler)
            .post('/baseline/:roundSid', this.baselineUploadHandler)
            .get('/countryParams/def', this.countryParamsDefinitionHandler)
            .get('/countryParams/data/:roundSid', this.countryParamsDataHandler)
            .post('/countryParams/:roundSid', this.countryParamsUploadHandler)
            .get('/generalParams/:roundSid', this.generalParamsHandler)
            .post('/generalParams/:roundSid', this.generalParamsUploadHandler)
            .get('/changeY/:roundSid', this.getChangeYHandler)
            .put('/changeY/:roundSid', this.getChangeYUpdateHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

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
     * @method getChangeYHandler
     *********************************************************************************************/
    private getChangeYHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getChangeY(Number(req.params.roundSid)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getChangeYUpdateHandler
     *********************************************************************************************/
    private getChangeYUpdateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.updateChangeY(Number(req.params.roundSid), req.body.changeY).then(res.json.bind(res), next)
}
