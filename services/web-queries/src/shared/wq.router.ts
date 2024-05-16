import { NextFunction, Request, Response } from 'express'
import { Query } from 'express-serve-static-core'

import { AuthnRequiredError, AuthzLibService, BaseFpapiRouter } from '../../../lib/dist'
import { ITTConvertParams, ITTDoubleParams, IWQInputParams, TransformationType } from './shared-interfaces'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { EApps } from 'config'
import { IWQRoundInfo } from '.'
import { ParamsService } from './params.service'
import { WqService } from './wq.service'
import { version } from '../../version'

export abstract class WqRouter extends BaseFpapiRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(protected readonly appId?: EApps) {
        super(appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getInputParams
     *********************************************************************************************/
    protected getInputParams(query: Query): IWQInputParams {
        this.normalizeParams(query)

        let countries: string[] = ParamsService.arrayParamUpper(query.cty)
        let periodicity: string = ParamsService.stringParamUpper(query.freq, 'A')
        const series: string[] = ParamsService.arrayParamUpper(query.series)
        const serie: string = ParamsService.stringParamUpper(query.serie)
        let indicators: string[] = series
        const startYear: number = this.getYear(ParamsService.stringParam(query.from))
        const endYear: number = this.getYear(ParamsService.stringParam(query.to))

        if (serie) {
            indicators = [serie]
            const serieParts: string[] = serie.split('.')
            if (serieParts.length > 5) {
                countries = [serieParts[0]]
                periodicity = serieParts[serieParts.length - 1]
                indicators = [serieParts.slice(1, serieParts.length - 1).join('.')]
            }
        }

        const params: IWQInputParams = {
            query,
            countries,
            periodicity,
            indicators,
            yearRange: [startYear, endYear],
            countryGroup: ParamsService.stringParamUpper(query.cty_grp),
            nullValue: ParamsService.stringParam(query.null, ''),
            showRound: query.show_round !== undefined,
            showUpdated: query.show_update !== undefined,
            json: query.json !== undefined,
            roundSid: ParamsService.numericParam(query.roundsid),
            storageSid: ParamsService.numericParam(query.storagesid),
            sortYearsDesc: ParamsService.boolParamMatchValue(query.sort_years, 'DESC'),
            showFullCode: ParamsService.boolParam(query.full_code),
            showScale: ParamsService.boolParam(query.scale, true),
            legendPosition: ParamsService.numericParam(query.legend, 1),
            transpose: ParamsService.boolParam(query.transpose, false),
        }
        return this.getTransformation(query.series as string, this.customizeParams(params))
    }

    /**********************************************************************************************
     * @method customizeParams
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected customizeParams(params: IWQInputParams): IWQInputParams {
        return params
    }

    /**********************************************************************************************
     * @method checkSecurity
     *********************************************************************************************/
    protected checkSecurity(...authzGroups: string[]) {
        return (req: Request, res: Response, next: NextFunction): Promise<void> => {
            return this.checkAuthentication(req, res).then((authorized) => {
                if (!authorized) AuthzLibService.checkAuthorisation(...authzGroups)(req, res, next)
                else next()
            }, next)
        }
    }                    

    /**********************************************************************************************
     * @method checkAuthentication
     *********************************************************************************************/
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    protected async checkAuthentication(req: Request, res: Response): Promise<boolean> {
        if (!AuthzLibService.isAuthenticated(req)) throw new AuthnRequiredError()
        return false
    }

    /**********************************************************************************************
     * @method addRoundInfo
     *********************************************************************************************/
    protected addRoundInfo = (req: Request, res: Response, next: NextFunction): Promise<void> =>
        this.getRoundInfo(
            Number(req.query.year),
            req.query.period as string,
            Number(req.query.version as string),
            req.query.storage as string
        ).then(
            (roundInfo) => {
                if (roundInfo) {
                    req.query.roundSid = String(roundInfo.archiveRound.roundSid)
                    req.query.storageSid = String(roundInfo.archiveRound.storageSid)
                    res.locals.currentRoundSid = roundInfo.currentRound.roundSid
                }
                next()
            },
            next
        )

    /**********************************************************************************************
     * @method addAppStatus
     *********************************************************************************************/
    protected addAppStatus = (req: Request, res: Response, next: NextFunction): Promise<void> =>
        DashboardApi.getApplicationStatus(this.appId).then(appStatus => {
            res.locals.appStatus = appStatus
            next()
        })

    /**********************************************************************************************
     * @method getVersion
     *********************************************************************************************/
    protected getVersion(): string {
        return version
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTransformation
     *********************************************************************************************/
    private getTransformation(input: string, params: IWQInputParams): IWQInputParams {
        let result = params
        const match = /^\s*(\w+)\s*\((.*)\)/g.exec(input)

        if (match && match.length > 2) {
            const transformation: string = match[1].toLowerCase()
            const args: string[] = match[2].split(',')
            switch(transformation) {
                case TransformationType.CONVERT:
                    result = this.getConvertParams(args, params)
                    break
                case TransformationType.ADD:
                    result = this.getDoubleParams(args, params, TransformationType.ADD)
                    break
                case TransformationType.MINUS:
                    result = this.getDoubleParams(args, params, TransformationType.MINUS)
                    break
                case TransformationType.PCT:
                    result = this.getSingleParams(args, params, TransformationType.PCT)
                    break;
            }
        }
        return result
    }

    /**********************************************************************************************
     * @method getYear
     *********************************************************************************************/
    private getYear(yearString: string, defaultYear?: number): number {
        const year = Number(yearString)
        return !isNaN(year) && year >= WqService.MIN_YEAR ? year : defaultYear
    }

    /**********************************************************************************************
     * @method getConvertParams
     *********************************************************************************************/
    private getConvertParams(
        [indicatorId, inputPeriodicity, outputPeriodicity]: string[], params: IWQInputParams
    ): IWQInputParams {
        const convertParams: ITTConvertParams = { inputPeriodicity, outputPeriodicity }
        params.transformation =  { type: TransformationType.CONVERT, params: convertParams }
        params.periodicity = convertParams.inputPeriodicity
        params.indicators = [indicatorId]

        return params
    }

    /**********************************************************************************************
     * @method getDoubleParams
     *********************************************************************************************/
    private getDoubleParams(
        [serieA, serieB]: string[], params: IWQInputParams, type: TransformationType
    ): IWQInputParams {
        const addParams: ITTDoubleParams = { serieA, serieB }
        params.transformation =  { type, params: addParams }
        params.indicators = [serieA, serieB]
        return params
    }

    /**********************************************************************************************
     * @method getSingleParams
     *********************************************************************************************/
    private getSingleParams(
        [indicatorId]: string[], params: IWQInputParams, type: TransformationType
    ): IWQInputParams {
        params.transformation =  { type, params: indicatorId }
        params.indicators = [indicatorId]
        return params
    }

    /**********************************************************************************************
     * @method getRoundInfo
     *********************************************************************************************/
    private async getRoundInfo(year: number, period: string, version: number, storage: string): Promise<IWQRoundInfo> {
        let iwqRoundInfo: IWQRoundInfo
        if (!isNaN(year) && period && storage) {
            const [archiveRound, currentRound] = await Promise.all([
                DashboardApi.getArchivedRoundInfo(this.appId, year, period, storage, version),
                DashboardApi.getCurrentRoundInfo(this.appId),
            ])
            iwqRoundInfo = {
                archiveRound,
                currentRound,
            }
        }

        return iwqRoundInfo
    }
}
