import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter } from '../../../lib/dist/base-router'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { SpiController } from './spi.controller'
import { SpiService } from './spi.service'


export class SpiRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(dbService: DbService<DbProviderService>): Router {
        return new SpiRouter(dbService).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: SpiController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(dbService: DbService<DbProviderService>) {
        super()
        this.controller = new SpiController(new SpiService(dbService))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .post('/matrix', this.getSpiMatrixDataHandler.bind(this))
            .post('/', this.getSpiDataHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSpiMatrixDataHandler
     *********************************************************************************************/
    private getSpiMatrixDataHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getMatrixData(req.body).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getSpiDataHandler
     *********************************************************************************************/
    private getSpiDataHandler(req: Request, res: Response, next: NextFunction) {
        this.controller.getIndicatorData(req.body).then(res.json.bind(res), next)
    }
}
