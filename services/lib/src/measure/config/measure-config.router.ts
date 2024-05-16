import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../base-router'
import { MeasureSharedService } from '..'

import { MeasureConfigController } from './measure-config.controller'

export abstract class MeasureConfigRouter<
    S extends MeasureSharedService,
    C extends MeasureConfigController<S>
> extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        protected sharedService: S,
        protected controller: C,
    ) {
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
            .get('/esaCodes/:roundSid', this.getESACodesHandler)
            .get('/oneOff', this.getOneOffHandler)
            .get('/months', this.getMonthsHandler)
            .get('/oneOffTypes/:roundSid', this.getOneOffTypesHandler)
            .get('/countryCurrencyInfo/:countryId/:roundSid?', this.getCountryCurrencyInfoHandler)
            .get('/gdpPonderation', this.getGDPPonderationHandler)
            .get('/countryMultipliers', this.getCountryMultipliersHandler)
            .get('/labels', this.getLabelsHandler)
            .get('/adoptionYears', this.getAdoptionYearsHandler)
            .get('/euFunds', this.getEuFundsHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryCurrencyInfoHandler
     *********************************************************************************************/
    private getCountryCurrencyInfoHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getCountryCurrencyInfo(
            req.params.countryId,
            Number(req.params.roundSid),
            Number(req.query.version),
            Boolean(req.query.force),
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getCountryMultipliersHandler
     *********************************************************************************************/
    private getCountryMultipliersHandler = (req: Request, res: Response, next: NextFunction) =>
        this.sharedService.getCountryMultipliers().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getESACodesHandler
     *********************************************************************************************/
    private getESACodesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getESACodes(Number(req.params.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getEuFundsHandler
     *********************************************************************************************/
    private getEuFundsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getEuFunds().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getGDPPonderationHandler
     *********************************************************************************************/
    private getGDPPonderationHandler = (req: Request, res: Response, next: NextFunction) =>
        this.sharedService.getGDPPonderation(req.query.countryId as string)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getOneOffHandler
     *********************************************************************************************/
    private getOneOffHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getOneOff().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getOneOffTypesHandler
     *********************************************************************************************/
    private getOneOffTypesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getOneOffTypes(Number(req.params.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getMonthsHandler
     *********************************************************************************************/
    private getMonthsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getMonths().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getLabelsHandler
     *********************************************************************************************/
    private getLabelsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getLabels().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getAdoptionYearsHandler
     *********************************************************************************************/
    private getAdoptionYearsHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAdoptionYears().then(res.json.bind(res), next)

}
