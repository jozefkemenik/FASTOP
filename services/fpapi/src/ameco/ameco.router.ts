import * as swaggerJsdoc from 'swagger-jsdoc'
import { NextFunction, Request, Response, Router } from 'express'

import { AuthnRequiredError, AuthzLibService, LoggingService } from '../../../lib/dist'
import { AmecoController } from './ameco.controller'
import { EApps } from 'config'
import { FpapiRouter } from '../shared/fpapi.router'


export class AmecoRouter extends FpapiRouter {

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService): Router {
        return new AmecoRouter(logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: AmecoController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(logs: LoggingService) {
        super(logs)
        this.controller = new AmecoController(EApps.FPAPI, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configFpapiRoutes(router: Router): Router {

        return router
            .get('/data',
                this.checkDatasourceAccess('restricted', 'ADMIN', 'FORECAST'),
                this.getAmecoDataHandler
            )
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {

        return {
            definition: {
                openapi: this.getOpenapiVersion(),
                info: {
                    title: 'FpApi ameco sdmx data endpoint',
                    description: 'FpApi ameco sdmx',
                    version: this.getVersion(),
                },
                servers: [{ url: this.getApiUrl('/1.0'), }]
            },
            apis: [
                this.getSwaggerFilePath('/ameco.yaml')
            ],
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkDatasourceAccess
     *********************************************************************************************/
    private checkDatasourceAccess(datasource: string, ...authzGroups: string[]) {
        return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
            const ds = (req.query.ds as string).toLowerCase()
            return datasource.toLowerCase() === ds ? this.checkAuthentication(req).then((authorized) => {
                if (!authorized) AuthzLibService.checkAuthorisation(...authzGroups)(req, res, next)
                else next()
            }, next) : next()
        }
    }

    /**********************************************************************************************
     * @method checkAuthentication
     *********************************************************************************************/
    private async checkAuthentication(req: Request): Promise<boolean> {
        if (!AuthzLibService.isAuthenticated(req)) throw new AuthnRequiredError()

        return false
    }

    /**********************************************************************************************
     * @method getAmecoDataHandler
     *********************************************************************************************/
    private getAmecoDataHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getAmecoData(
            req.query.ds as string,
            req.query.key as string,
            req.query.startPeriod as string,
            req.query.endPeriod as string
        ).then(res.json.bind(res), next)
}
