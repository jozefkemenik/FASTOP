import * as path from 'path'
import * as swaggerJsdoc from 'swagger-jsdoc'
import * as swaggerUi from 'swagger-ui-express'
import { Request, Response, Router } from 'express'
import { Query } from 'express-serve-static-core'

import { BaseRouter } from './base-router'
import { config } from '../../config/config'

export abstract class BaseFpapiRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public static readonly HOST = config.host + (config.useHostPort ? `:${config.intragatePort}` : '')

    /**********************************************************************************************
     * @method normalizeUrl remove double slashes except the one at the beginning (after protocol)
     *********************************************************************************************/
    public static normalizeUrl(url: string): string {
        return url.replace(/([^:]\/)\/+/g, '$1')
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        const swaggerOptions = this.getSwaggerOptions()
        if (swaggerOptions) {
            const swaggerDoc = swaggerJsdoc(swaggerOptions)
            router.use(
                '/api-docs',
                swaggerUi.serveFiles(swaggerDoc),
                swaggerUi.setup(swaggerDoc)
            )
        }
        router.options('*', this.getOptionsHandler)
        return this.configFpapiRoutes(router)
    }

    /**********************************************************************************************
     * @method configFpapiRoutes routes configuration for this Router
     *********************************************************************************************/
    protected abstract configFpapiRoutes(router: Router): Router

    /**********************************************************************************************
     * @method getVersion
     *********************************************************************************************/
    protected abstract getVersion(): string

    /**********************************************************************************************
     * @method getSwaggerFilePath
     *********************************************************************************************/
    protected getSwaggerFilePath(filePath: string): string {
        return path.resolve(path.join('../swagger/', filePath))
    }

    /**********************************************************************************************
     * @method getSwaggerOptions
     *********************************************************************************************/
    protected getSwaggerOptions(): swaggerJsdoc.Options {
        return undefined
    }

    /**********************************************************************************************
     * @method getOpenapiVersion
     *********************************************************************************************/
    protected getOpenapiVersion(): string {
        return '3.0.0'
    }

    /**********************************************************************************************
     * @method getApiUrl
     *********************************************************************************************/
    protected getApiUrl(route: string): string {
        return BaseFpapiRouter.normalizeUrl(`${BaseFpapiRouter.HOST}/fpapi/${route}`)
    }

    /**********************************************************************************************
     * @method normalizeParams
     * Convert all param names to lower case
     *********************************************************************************************/
    protected normalizeParams(query: Query) {
        Object.keys(query).forEach(key => {
            query[key.toLowerCase()] = query[key]
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getOptionsHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getOptionsHandler = (req: Request, res: Response) => {
        res.setHeader('Allow', 'GET, POST')
        res.sendStatus(200)
    }

}
