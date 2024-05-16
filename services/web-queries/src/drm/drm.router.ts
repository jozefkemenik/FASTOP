import * as swaggerJsdoc from 'swagger-jsdoc'
import { Router } from 'express'

import { EApps } from 'config'
import { MeasureController } from '../common/measure/measure.controller'
import { MeasureRouter } from '../common/measure/measure.router'
import { SharedService } from '../shared/shared.service'


export class DrmRouter extends MeasureRouter<MeasureController> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(sharedService: SharedService): Router {
        return new DrmRouter(sharedService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super(new MeasureController(sharedService, EApps.DRM))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'DRM API',
                    description: 'DRM',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/drm'), }]
            },
            apis: [
                this.getSwaggerFilePath('/shared/measures.parameters.yaml'),
                this.getSwaggerFilePath('/shared/archive.parameters.yaml'),
                this.getSwaggerFilePath('/shared/security.schemas.yaml'),
                this.getSwaggerFilePath('/drm.yaml')
            ],
        }
    }

}
