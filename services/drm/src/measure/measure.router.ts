import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzError, AuthzLibService } from '../../../lib/dist'
import { LibMeasureRouter, UPD_GROUPS } from '../../../lib/dist/measure'
import { SharedService } from '../shared/shared.service'

import { IMeasureDetails } from '.'
import { MeasureController } from './measure.controller'
import { MeasureService } from './measure.service'
import { UploadService } from './upload.service'

export class MeasureRouter extends LibMeasureRouter<
    IMeasureDetails, UploadService, MeasureService, MeasureController
> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of MeasureRouter
     *********************************************************************************************/
    public static createRouter(
        appId: EApps,
        sharedService: SharedService,
    ): Router {
        return new MeasureRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps,
        sharedService: SharedService,
    ) {
        super(appId, new MeasureController(appId, sharedService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this router
     * @overrides
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/tr/excel/:countryId',
                this.checkSubmittedUserCountries,
                this.getTransparencyReportHandler)
            .get('/other/submittedCountries', this.getSubmittedCountriesHandler)
            .get('/other/:measureSid',
                this.checkSubmittedUserCountries,
                this.checkSubmittedCountry,
                this.getMeasureDetailsHandler)
            .get('/other',
                this.checkSubmittedUserCountries,
                this.checkSubmittedCountry,
                this.getEnterMeasuresHandler)
            .post('/other/excel',
                this.checkSubmittedUserCountries,
                this.checkSubmittedCountry,
                this.getEnterMeasuresExcelHandler)
            .put('/copyFromPreviousRound/:roundSid/:countryId',
                AuthzLibService.checkAuthorisation(...UPD_GROUPS),
                AuthzLibService.checkCountryAuthorisation(),
                this.copyPreviousRoundMeasuresHandler)

        return super.configRoutes(router)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkSubmittedCountry
     *********************************************************************************************/
    private checkSubmittedCountry = (req: Request, res: Response, next: NextFunction) =>
        this.controller.isAnyCountrySubmitted([req.query.countryId as string])
            .then(isSubmitted => next(isSubmitted ? undefined : new AuthzError()), next)

    /**********************************************************************************************
     * @method checkSubmittedUserCountries
     *********************************************************************************************/
    private checkSubmittedUserCountries = (req: Request, res: Response, next: NextFunction) => {
        const countries = AuthzLibService.getUserCountries(req)
        if (AuthzLibService.isAdmin(req)) next()
        else if (!countries.length) next(new AuthzError())
        else {
            this.controller.isAnyCountrySubmitted(countries, Number(req.query.roundSid))
                .then(isSubmitted => next(isSubmitted ? undefined : new AuthzError()), next)
        }
    }

    /**********************************************************************************************
     * @method copyPreviousRoundMeasuresHandler
     *********************************************************************************************/
    private copyPreviousRoundMeasuresHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.copyPreviousRoundMeasures(Number(req.params.roundSid), req.params.countryId)
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getTransparencyReportHandler
     *********************************************************************************************/
    private getTransparencyReportHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getTransparencyReport(req.params.countryId, req.body, Number(req.query.roundSid))
            .then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getSubmittedCountriesHandler
     *********************************************************************************************/
    private getSubmittedCountriesHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getSubmittedCountries().then(res.json.bind(res), next)
}
