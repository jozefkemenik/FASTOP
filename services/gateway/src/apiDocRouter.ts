import * as proxy from 'express-http-proxy'
import { Request, Router } from 'express'

import { BaseApiRouter } from './baseApiRouter'
import { EApps } from 'config'
import { LoggingService } from '../../lib/dist/logging.service'
import { config } from '../../config/config'


export class ApiDocRouter extends BaseApiRouter {

    private static readonly API_DOC_ENDPOINTS = [
        'ameco', 'fdms', 'imf', 'sdmx', 'spi', 'dfm', 'drm', 'scp', 'dbp'
    ]

    private static readonly FPAPI_DOC_ENDPOINTS = [
        'data', 'json/ameco'
    ]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this router
     *********************************************************************************************/
    public static createRouter(logs: LoggingService): Router {
        return new ApiDocRouter(logs).config()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private constructor(logs: LoggingService) {
        super(logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configAppServices
     *********************************************************************************************/
    protected configAppServices(router: Router) {

        // web-query api-doc routes
        this.configureApiDocEndpoints(
            router, ApiDocRouter.API_DOC_ENDPOINTS, EApps.WQ
        )

        // fpapi/1.0 api-doc routes
        this.configureApiDocEndpoints(
            router, ApiDocRouter.FPAPI_DOC_ENDPOINTS, EApps.FPAPI, 'fpapi/1.0/'
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configureApiDocEndpoints
     *********************************************************************************************/
    private configureApiDocEndpoints(
        router: Router, endpoints: string[], targetApp: EApps, urlPrefix = ''
    ) {
        endpoints.forEach(app => {
            router.use(`/${urlPrefix}${app}`,
                (req, res, next) => {
                    if (req.originalUrl == `/api-docs/${urlPrefix}${app}`) return res.redirect(`/api-docs/${urlPrefix}${app}/`)
                    next()
                },
                proxy(`${config.apps[targetApp].host}:${config.apps[targetApp].port}`, {
                    proxyReqOptDecorator: this.addAuthHeaders(app.toUpperCase()),
                    proxyReqPathResolver: (req: Request) => `/${app}/api-docs${req.url}`
                })
            )
        })
    }
}
