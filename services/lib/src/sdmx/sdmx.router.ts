import { NextFunction, Request, Response, Router } from 'express'
import { EApps } from 'config'

import { BaseRouter } from '../base-router'
import { ISdmxBag } from './shared-interfaces'
import { LibSdmxController } from './sdmx.controller'

export class LibSdmxRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new LibSdmxRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: LibSdmxController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(appId: EApps) {
        super()
        this.controller = new LibSdmxController(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for LibSdmxRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        router
            .post('/convert/:dataset/:freq?',
                this.getConvertHandler.bind(this))

        return router
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getConvertHandler
     *********************************************************************************************/
    private getConvertHandler = (req: Request, res: Response, next: NextFunction) => {
        const dataset = req.params.dataset
        const freq = req.params.freq || 'A'
        return this.controller.convert(
            dataset,
            freq,
            req.body as ISdmxBag
        ).then(content => this.sendZippedContent(res, dataset, freq, content), next)
    }

    /**********************************************************************************************
     * @method sendZippedContent
     *********************************************************************************************/
    private sendZippedContent(res: Response, dataset: string, freq: string, content: Buffer) {
        const fileName = `${dataset}_${freq}_sdmx.zip`
        res.setHeader('Content-Disposition', `attachment;filename="${fileName}"`)
        res.setHeader('Content-Type', 'application/zip, application/octet-stream')
        res.send(content)
    }
}
