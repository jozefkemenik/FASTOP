import axios, { AxiosRequestConfig, Method, ResponseType } from 'axios'
import { HttpProxyAgent } from 'http-proxy-agent'
import { HttpsProxyAgent } from 'https-proxy-agent'

import { EApps } from 'config'
import { config } from '../../config/config'

/* eslint-disable @typescript-eslint/no-explicit-any */
export class RequestService {

    private static readonly HTTP_PROXY_AGENT = config.proxy.http ? new HttpProxyAgent(config.proxy.http) : undefined
    private static readonly HTTPS_PROXY_AGENT = config.proxy.https ? new HttpsProxyAgent(config.proxy.https) : undefined

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method request
     *********************************************************************************************/
    public static request(
        node: EApps,
        route: string,
        method = 'get',
        data?: any,
        extraHeaders?: Record<string, string>,
        extraOptions?: Record<string, any>,
        binary?: boolean,
    ): Promise<any> {
        return RequestService.requestUri(
            `http://${config.apps[node]?.host}:${config.apps[node]?.port}${route}`,
            method,
            data,
            Object.assign({ apiKey: config.apiKey, internal: true }, extraHeaders),
            extraOptions,
            undefined,
            binary,
        )
    }

    /**********************************************************************************************
     * @method requestHost
     *********************************************************************************************/
    public static requestHost(
        host: string,
        port: number,
        route: string,
        method = 'get',
        data?: any,
        headers?: Record<string, string>,
        extraOptions?: Record<string, any>,
        proxy?: boolean,
    ): Promise<any> {
        return RequestService.requestUri(
            `http://${host}:${port}${route}`, method, data, headers, extraOptions, proxy
        )
    }

    /**********************************************************************************************
     * @method requestUri
     *********************************************************************************************/
    public static requestUri(
        uri: string,
        method= 'get',
        data?: any,
        headers?: Record<string, string>,
        extraOptions?: Record<string, any>,
        proxy?: boolean,
        binary?: boolean,
    ): Promise<any> {
        const options: AxiosRequestConfig = Object.assign({
            method: method as Method,
            maxBodyLength: config.maxBodyLength,
            data,
            proxy: false as any,
            httpAgent: proxy ? RequestService.HTTP_PROXY_AGENT : undefined,
            httpsAgent: proxy ? RequestService.HTTPS_PROXY_AGENT : undefined,
            headers,
            responseType: binary ? 'arraybuffer' as ResponseType : undefined,
        }, extraOptions)
        return axios(uri, options).then((res) => res.data)
    }
}
/* eslint-enable @typescript-eslint/no-explicit-any */
