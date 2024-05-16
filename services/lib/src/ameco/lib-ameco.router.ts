import { NextFunction, Request, Response, Router } from 'express'

import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { AuthzLibService } from '../authzLib.service'
import { BaseRouter } from '../base-router'
import { LibAmecoController } from './lib-ameco.controller'

export abstract class LibAmecoRouter<T extends LibAmecoController> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected controller: T

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .get('/restricted/seriesData',
                AuthzLibService.checkAuthorisation('ADMIN', 'FORECAST'),
                this.getSeriesRestrictedDataHandler
            )
            .get('/:amecoType/countries', this.getCountriesHandler)
            .get('/:amecoType/series', this.getSeriesHandler)
            .get('/:amecoType/chapters', this.getChaptersHandler)
            .get('/:amecoType/seriesData', this.getSeriesDataHandler)

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountriesHandler
     *********************************************************************************************/
    private getCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountries(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeriesHandler
     *********************************************************************************************/
    private getSeriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeries(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getChaptersHandler
     *********************************************************************************************/
    private getChaptersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getChapters(this.amecoType(req)).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeriesDataHandler
     *********************************************************************************************/
    private getSeriesDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeriesData(
            this.amecoType(req),
            req.query.countries as string,
            req.query.series as string,
            Number(req.query.startYear),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSeriesRestrictedDataHandler
     *********************************************************************************************/
    private getSeriesRestrictedDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSeriesData(
            AmecoType.RESTRICTED,
            req.query.countries as string,
            req.query.series as string,
            Number(req.query.startYear),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method amecoType
     *********************************************************************************************/
    private amecoType(req: Request) {
        return req.params.amecoType as AmecoType
    }
}
