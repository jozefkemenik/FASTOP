import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import { AuthzLibService } from '../../../lib/dist'
import { LibMeasureRouter } from '../../../lib/dist/measure'

import { IMeasureDetails } from '.'
import { MeasureController } from './measure.controller'
import { MeasureService } from './measure.service'
import { SharedService } from '../shared/shared.service'
import { UploadService } from './upload.service'

export class MeasureRouter extends LibMeasureRouter<IMeasureDetails, UploadService, MeasureService, MeasureController> {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of MeasureRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService): Router {
        return new MeasureRouter(appId, sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps, private readonly sharedService: SharedService) {
        super(appId, new MeasureController(appId, sharedService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method areMeasuresEditable
     *********************************************************************************************/
    protected areMeasuresEditable = (ctyStatusId: EStatusRepo, appStatusId: EStatusRepo, req?: Request) =>
        this.sharedService.isEditable(ctyStatusId, appStatusId, req)

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     * @overrides
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router.put(
            '/recalculateAggregated/:countryId',
            AuthzLibService.checkCountryAuthorisation(),
            this.getRecalculateMeasuresHandler.bind(this),
        )

        return super.configRoutes(router)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRecalculateMeasuresHandler
     *********************************************************************************************/
    private getRecalculateMeasuresHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.recalculateAggregatedMeasures(req.params.countryId).then(res.json.bind(res), next)
    }
}
