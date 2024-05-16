import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService } from '../../../../lib/dist'
import { MeasureSharedService } from '../../../../lib/dist/measure/shared/measure-shared.service'

import { AuthzService } from '../../shared/authz.service'
import { MeasureController } from './measure.controller'
import { WqRouter } from '../../shared/wq.router'

export abstract class MeasureRouter<C extends MeasureController> extends WqRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(protected readonly controller: C) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {
        return router.get(
            '/measures',
            AuthzService.checkWqAuthentication(this.controller.notAuthenticatedMessage),
            AuthzService.checkWqAuthorisation('ADMIN', 'CTY_DESK', 'C1'),
            this.checkCountryAuthorisation((req: Request) => req.query.countryId as string, 'C1'),
            this.addRoundInfo,
            this.getMeasuresHandler,
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkCountryAuthorisation
     *********************************************************************************************/
    private checkCountryAuthorisation(countryGetter?: (req: Request) => string, ...ignoreGroups: string[]) {
        return (req: Request, res: Response, next: NextFunction) => {
            const userGroups = AuthzLibService.getUserGroups(req)
            if (userGroups.length + ignoreGroups.length > new Set([...userGroups, ...ignoreGroups]).size) {
                next()
            } else {
                return AuthzService.checkWqCountryAuthorisation(countryGetter)(req, res, next)
            }
        }
    }

    /**********************************************************************************************
     * @method getMeasuresHandler
     *********************************************************************************************/
    private getMeasuresHandler = (req: Request, res: Response, next: NextFunction) => {
        return this.controller
            .getMeasures(
                req.query.countryId as string,
                req.query.gdp === 'true',
                MeasureSharedService.getReqArchiveParams(req.query),
            )
            .then(res.send.bind(res), next)
    }
}
