import { NextFunction, Request, Response, Router } from 'express'

import { EApps } from 'config'

import { AuthzService } from '../../shared/authz.service'
import { BaseRouter } from '../.././../../lib/dist'
import { GridsController } from './grids.controller'
import { SharedService } from '../../shared/shared.service'

export class GridsRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps, sharedService: SharedService) {
        return new GridsRouter(new GridsController(appId, sharedService)).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly controller: GridsController) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    public configRoutes(router: Router): Router {
        return router.get('/iqy', this.getIqyGridsFileHandler).post(
            '/',
            AuthzService.checkWqAuthentication(this.controller.notAuthenticatedMessage),
            AuthzService.checkWqAuthorisation('ADMIN', 'CTY_DESK', 'READ_ONLY', 'C1'),
            AuthzService.checkWqCountryAuthorisation((req: Request) => req.body.countryIds as string),
            this.getGridsHandler,
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getGridsHandler
     *********************************************************************************************/
    private getGridsHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller.getGrids(req.body).then(res.send.bind(res), next)
    }

    /**********************************************************************************************
     * @method getIqyGridsFileHandler
     *********************************************************************************************/
    private getIqyGridsFileHandler = (req: Request, res: Response) => {
        const queryIdx = req.originalUrl.indexOf('?')
        const query = queryIdx > 0 ? req.originalUrl.substring(queryIdx + 1) : ''

        res.send({ content: this.controller.getIqyGridsContent(query) })
    }
}
