import { EApps,  } from 'config'
import { config } from '../../../config/config'


import axios, { AxiosRequestConfig, Method, ResponseType } from 'axios'

import {
    IAnswer,
    IBcsSearchCriteria,
    ICountry,
    IObservationRange,
    IObservationSeries,
    IQuestion,
    ISeasonalAdjustment,
    ISector,
    ISurvey
} from '../../../lib/dist/addin/shared-interfaces'
/* eslint-disable @typescript-eslint/no-explicit-any */
export class BcsTestApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getObservations
     *********************************************************************************************/
    public static getObservations(url: string, data: IBcsSearchCriteria): Promise<IObservationSeries> {
        return RequestService.request(EApps.BCS, url, 'post', data)
    }

    /**********************************************************************************************
     * @method getSurveys
     *********************************************************************************************/
    public static getSurveys(): Promise<ISurvey[]> {
        return RequestService.request(EApps.BCS, '/surveys')
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public static getCountries(): Promise<ICountry[]> {
        return RequestService.request(EApps.BCS, '/surveys/countries')
    }

    /**********************************************************************************************
     * @method getSectors
     *********************************************************************************************/
    public static getSectors(): Promise<ISector[]> {
        return RequestService.request(EApps.BCS, '/surveys/sectors')
    }

    /**********************************************************************************************
     * @method getQuestions
     *********************************************************************************************/
    public static getQuestions(): Promise<IQuestion[]> {
        return RequestService.request(EApps.BCS, '/surveys/questions')
    }

    /**********************************************************************************************
     * @method getAnswers
     *********************************************************************************************/
    public static getAnswers(): Promise<IAnswer[]> {
        return RequestService.request(EApps.BCS, '/surveys/answers')
    }

    /**********************************************************************************************
     * @method getSeasonalAdjs
     *********************************************************************************************/
    public static getSeasonalAdjs(): Promise<ISeasonalAdjustment[]> {
        return RequestService.request(EApps.BCS, '/surveys/seasonalAjds')
    }

    /**********************************************************************************************
     * @method getObservationsRange
     *********************************************************************************************/
    public static getObservationsRange(): Promise<IObservationRange> {
        return RequestService.request(EApps.BCS, '/surveys/observationsRange')
    }
}

export class RequestService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method request
     *********************************************************************************************/
    public static request<T>(
        node: EApps,
        route: string,
        method = 'get',
        data?: unknown,
        extraHeaders?: Record<string, string>,
        extraOptions?: Record<string, unknown>,
        binary?: boolean,
    ): Promise<T> {
        // const url = `http://${config.apps[node]?.host}:${config.apps[node]?.port}${route}`
        const url = `http://aparce.cc.cec.eu.int:3290${route}`
        return RequestService.requestUri<T>(
            url,
            method,
            data,
            Object.assign({ apiKey: config.apiKey, internal: true }, extraHeaders),
            extraOptions,
            undefined,
            binary,
        )
    }

    /**********************************************************************************************
     * @method requestUri
     *********************************************************************************************/
    public static async requestUri<T>(
        uri: string,
        method= 'get',
        data?: unknown,
        headers?: Record<string, string>,
        extraOptions?: Record<string, unknown>,
        proxy?: boolean,
        binary?: boolean,
    ): Promise<T> {
        const options: AxiosRequestConfig = Object.assign({
            method: method as Method,
            maxBodyLength: 150 * 1024 * 1024, // 150mb in bytes,
            data,
            /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
            proxy: false as any,
            headers,
            httpAgent: undefined,
            httpsAgent: undefined,
            responseType: binary ? 'arraybuffer' as ResponseType : undefined,
        }, extraOptions)

        return axios(uri, options).then((res) => res.data)
    }
}
