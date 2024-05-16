import { EApps } from 'config'

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
} from '../addin/shared-interfaces'
import { RequestService } from '../request.service'

export class BcsApi {

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
