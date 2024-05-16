import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { AuthzLibService } from '../../authzLib.service'
import { BaseRouter } from '../../base-router'

import { SemiElasticityController } from './semi-elasticity.controller'
import { SemiElasticityService } from './semi-elasticity.service'

export class SemiElasticityRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new SemiElasticityRouter(
            new SemiElasticityController(new SemiElasticityService(appId))
        ).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(private readonly controller: SemiElasticityController) {
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
            .get('/countries',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getCountriesHandler)
            .post('/:roundSid/',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.elasticityUploadHandler)
            .get('/data',
                AuthzLibService.checkAuthorisation('ADMIN'),
                this.getElasticityDataHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method elasticityUploadHandler
     *********************************************************************************************/
    private elasticityUploadHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.storeElasticity(
            Number(req.params.roundSid),
            req.body
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getElasticityDataHandler
     *********************************************************************************************/
    private getElasticityDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getElasticityData().then(res.json.bind(res), next)
}
