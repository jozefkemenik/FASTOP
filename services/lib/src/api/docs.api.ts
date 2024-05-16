import * as proxy from 'express-http-proxy'
import { Request } from 'express'

import { EApps } from 'config'
import { config } from '../../../config/config'


export class DocsApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Static Methods //////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getFdmsStarDoc
     *********************************************************************************************/
    public static getFdmsStarDoc(proxyPrefix: string) {
        return DocsApi.proxyToApp(EApps.FDMSSTAR, proxyPrefix)
    }

    /**********************************************************************************************
     * @method getNeerDoc
     *********************************************************************************************/
    public static getNeerDoc(proxyPrefix: string) {
        return DocsApi.proxyToApp(EApps.NEER, proxyPrefix)
    }

    /**********************************************************************************************
     * @method getHicpDoc
     *********************************************************************************************/
    public static getHicpDoc(proxyPrefix: string) {
        return DocsApi.proxyToApp(EApps.HICP, proxyPrefix)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Static Methods /////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method proxyToApp
     *********************************************************************************************/
    private static proxyToApp(app: EApps, proxyPrefix: string) {
        return proxy(`${ config.apps[app].host }:${ config.apps[app].port }`, {
            proxyReqOptDecorator: (proxyReqOpts) => {
                proxyReqOpts.headers.apiKey = config.apiKey
                proxyReqOpts.headers.internal = true
                return proxyReqOpts
            },
            proxyReqPathResolver: (req: Request) =>`${proxyPrefix}${ req.url }`,
        })
    }
}
