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
import { IBcsSeries, IBcsTimeSeries } from './shared-interfaces'
// import { BcsApi } from '../../../lib/dist/api/bcs.api'
import { BcsTestApi as BcsApi } from './bcs-test.api'
import { catchAll } from '../../../lib/dist/catch-decorator'

@catchAll(__filename)
export class BcsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getObservations
     *********************************************************************************************/
    public async getObservations(url: string, data: IBcsSearchCriteria): Promise<IBcsTimeSeries> {
        const obs: IObservationSeries = await BcsApi.getObservations(url, data)
        return obs.data?.length
            ? this.convertObservationsToSeries(obs)
            : {
                  start: this.getPeriod(
                      new Date(Math.floor(data.startYearMonth / 100), data.startYearMonth % 100),
                      data.frequencyId,
                  ),
                  freq: data.frequencyId,
                  series: {},
              }
    }

    /**********************************************************************************************
     * @method getSurveys
     *********************************************************************************************/
    public async getSurveys(): Promise<ISurvey[]> {
        return BcsApi.getSurveys().then(
            surveys => surveys.map(survey => ({
                SURVEY_ID: survey.SURVEY_ID,
                DESCR: survey.DESCR
            }))
        )
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(): Promise<ICountry[]> {
        return BcsApi.getCountries()
    }

    /**********************************************************************************************
     * @method getSectors
     *********************************************************************************************/
    public async getSectors(): Promise<ISector[]> {
        return BcsApi.getSectors()
    }

    /**********************************************************************************************
     * @method getQuestions
     *********************************************************************************************/
    public async getQuestions(): Promise<IQuestion[]> {
        return BcsApi.getQuestions()
    }

    /**********************************************************************************************
     * @method getAnswers
     *********************************************************************************************/
    public async getAnswers(): Promise<IAnswer[]> {
        return BcsApi.getAnswers()
    }

    /**********************************************************************************************
     * @method getSeasonalAdjs
     *********************************************************************************************/
    public async getSeasonalAdjs(): Promise<ISeasonalAdjustment[]> {
        return BcsApi.getSeasonalAdjs()
    }

    /**********************************************************************************************
     * @method getObservationsRange
     *********************************************************************************************/
    public async getObservationsRange(): Promise<IObservationRange> {
        return BcsApi.getObservationsRange()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////// Private Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertObservationsToSeries
     *********************************************************************************************/
    private convertObservationsToSeries(obs: IObservationSeries): IBcsTimeSeries {
        const series: IBcsSeries = {}

        let freq: string, start: Date
        obs.data.forEach((o) => {
            const [startPeriod, seriesCode, vector] = o
            series[seriesCode] = vector
            freq = seriesCode.split('.')?.at(-1)
            start = startPeriod
        })
        return { freq , start: this.getPeriod(new Date(start), freq), series }
    }

    /**********************************************************************************************
     * @method getPeriod
     *********************************************************************************************/
    private getPeriod(date: Date, freq: string): string {
        const m = date.getMonth() + 1
        const y = date.getFullYear()
        const period = `${y}`
        const suffix = freq === 'M' ? `M${m < 10 ? '0': ''}${m}` :
            freq === 'Q' ? `Q${1 + Math.floor(m / 4)}` : ''
        return `${period}${suffix}`
    }
}
