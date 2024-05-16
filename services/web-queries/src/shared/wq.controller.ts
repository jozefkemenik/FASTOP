import { IIndicatorFields, IWQRenderData } from '.'
import { ITplData, IWQCountryIndicators, IWQInputParams, IWQRequestParams, IWQTplLegend } from './shared-interfaces'
import { Level, LoggingService } from '../../../lib/dist'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { EApps } from 'config'
import { IArchivedRoundInfo } from '../../../dashboard/src/config/shared-interfaces'
import { SharedService } from './shared.service'
import { WqService } from './wq.service'

export abstract class WqController<T extends IWQRequestParams, D> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        protected readonly appId: EApps,
        protected readonly wqService: WqService<T, D>,
        protected readonly sharedService: SharedService,
        protected readonly logs: LoggingService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// Public Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getWqData
     *********************************************************************************************/
    protected async getWqData(
        params: T, ...legends: IWQTplLegend[]
    ): Promise<string> {
        return this.getWqIndicators(params).then(renderData => this.render(renderData, ...legends))
    }

    /**********************************************************************************************
     * @method render
     *********************************************************************************************/
    protected render(renderData: IWQRenderData<T>, ...legends: IWQTplLegend[]): string {
        return renderData.params.json ? JSON.stringify(renderData.indicators) :
            this.renderWqIndicatorTemplate(
                renderData.indicators, legends, renderData.params.nullValue,
                renderData.error, renderData.params.legendPosition, renderData.params.transpose
            )
    }

    /**********************************************************************************************
     * @method getWqIndicators
     *********************************************************************************************/
    protected async getWqIndicators(params: T, fillMissingData = true): Promise<IWQRenderData<T>> {
        const renderData: IWQRenderData<T> = {
            indicators: {
                columns: (params.showUpdated ? [{ label: 'Update date', field: 'updated' }] : [])
                    .concat(params.showFullCode ? [{ label: 'Full code', field: 'fullCode' }] : [])
                    .concat([
                        { label: 'Country', field: 'country' }, { label: 'Code', field: 'code' },
                        { label: 'TRN', field: 'trn' }, { label: 'AGG', field: 'agg' },
                        { label: 'UNIT', field: 'unit' }, { label: 'REF', field: 'ref' },
                        { label: 'Frequency', field: 'freq' },
                    ])
                    .concat(params.showScale ? [{ label: 'Scale', field: 'scale' }] : [])
                    .concat(params.customColumns ? params.customColumns : []),
                data: []
            },
            countries: [],
            archivedRound: undefined,
            params
        }
        try {
            this.validateInputParams(params)

            renderData.countries = !params.countryGroup ? params.countries :
                                    await this.getCountryGroupCountries(params.countryGroup)
            const [roundInfo, dictionary] = await Promise.all([
                DashboardApi.getCurrentRoundInfo(this.appId),
                this.wqService.getDictionary()
            ])

            const data = await this.wqService.getIndicatorData(
                Object.assign({ ctyGroupCountries: renderData.countries, roundInfo }, params),
                dictionary
            ).then(
                indData => params.transformation ? this.wqService.transformData(params, indData) : indData
            )

            const [yearColumns, mod] = this.sharedService.buildYearsColumns(
                data, params.periodicity, WqService.MIN_YEAR
            )

            if (params.sortYearsDesc) yearColumns.reverse()
            renderData.indicators.columns = renderData.indicators.columns.concat(
                params.showRound ? [{ label: 'Round', field: 'round' }, { label: 'Storage', field: 'storage' }] : []
            ).concat(yearColumns)

            renderData.archivedRound = await DashboardApi.getRoundInfo(
                this.appId, params.roundSid, params.storageSid
            )

            const tplData: ITplData[] = this.convertToTplData(
                data, params, renderData.archivedRound, mod
            )
            renderData.indicators.data = fillMissingData ? this.fillDataByParameters(
                tplData, params, renderData.archivedRound, renderData.countries, dictionary
            ) : tplData
        } catch(ex) {
            renderData.error = this.handleError(ex)
        }

        return renderData
    }

    /**********************************************************************************************
     * @method validateInputParams
     *********************************************************************************************/
    protected validateInputParams(params: IWQInputParams) {
        if (!params.indicators?.length) throw Error('Invalid parameters - no indicator specified!')
    }

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    protected async getCountryGroupCountries(ctyGroup: string, useIso3 = false): Promise<string[]> {
        return DashboardApi.getCountryGroupCountries(ctyGroup).then(
            groupCountries => groupCountries.map(country => useIso3 ? country.CODEISO3 : country.COUNTRY_ID)
        )
    }

    /**********************************************************************************************
     * @method handleError
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected handleError(ex: any): string {
        const error = ex.toString()
        this.logs.log(error, Level.ERROR)
        return error
    }

    /**********************************************************************************************
     * @method fillDataByParameters
     *********************************************************************************************/
    protected fillDataByParameters(
        tplData: ITplData[],
        params: IWQInputParams,
        roundInfo: IArchivedRoundInfo,
        countriesParam: string[],
        dictionary: D,
    ): ITplData[] {
        const getKey = (indicator: string, geoArea: string) => `${indicator}_${geoArea}`

        const ctySet: Set<string> = new Set<string>()
        const dataMap: Map<string, ITplData[]> = new Map<string, ITplData[]>()
        tplData.forEach(val => {
            ctySet.add(val.country)
            const key = getKey(val.indicatorId, val.country)
            if (!dataMap.has(key)) dataMap.set(key, [])
            dataMap.get(key).push(val)
        })
        // if no countries specified in the input parameters then take all available data
        const countries = countriesParam?.length ? countriesParam : Array.from (ctySet.values())

        return params.indicators.reduce((results, indicatorId) =>
                results.concat(countries.reduce((curr, country) => {
                    const normalizedCountry = this.wqService.normalizeCountry(country, dictionary, params)
                    const key = getKey(indicatorId, normalizedCountry)
                    const tplDatas = dataMap.get(key)
                    if (tplDatas) {
                        curr.push(...tplDatas)
                    } else {
                        // if not data in db found then add empty record
                        curr.push(Object.assign({
                                round: params.showRound ? this.getRoundDescription(roundInfo) : undefined,
                                storage: params.showRound ? roundInfo.storageId : undefined,
                                indicatorId: indicatorId,
                                country: normalizedCountry ? normalizedCountry : `${country} [Error: unknown country code!]`,
                                freq: params.periodicity,
                            }, this.getIndicatorFields(indicatorId)
                        ))
                    }
                    return curr
                }, []))
            , [])
    }

    /**********************************************************************************************
     * @method formatDate
     *********************************************************************************************/
    protected formatDate(date: Date): string {
        const fmtNum = (n: number) => `${n < 10 ? '0' : ''}${n}`

        return !date ? '' :
            `${fmtNum(date.getDate())}/${fmtNum(1 + date.getMonth())}/${date.getFullYear()} - ` +
            `${fmtNum(date.getHours())}:${fmtNum(date.getMinutes())}`
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method renderWqIndicatorTemplate
     *********************************************************************************************/
    private renderWqIndicatorTemplate(
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        indicators: any, legends: IWQTplLegend[], nullValue: string, error: string,
        legendPosition: number, transpose = false
    ): string {
        const renderFn = this.sharedService.getCompiledTemplate(`../templates/wq_indicators.pug`)

        return renderFn(
            Object.assign(
                { transpose, legends, nullValue, error, legendPosition, lastRefresh: this.formatDate(new Date()) },
                { indicators })
        )
    }

    /**********************************************************************************************
     * @method convertToTplData
     *********************************************************************************************/
    private convertToTplData(
        data: IWQCountryIndicators,
        params: IWQInputParams,
        roundInfo: IArchivedRoundInfo,
        mod: number,
    ): ITplData[] {
        return data.indicators.map(val => {
            const tplData = Object.assign({
                    round: params.showRound ? this.getRoundDescription(roundInfo) : undefined,
                    storage: params.showRound ? roundInfo.storageId : undefined,
                    indicatorId: val.indicatorId,
                    fullCode: `${val.countryId}.${val.indicatorId}`,
                    country: val.countryId,
                    countryDesc: val.countryDesc,
                    freq: params.periodicity,
                    scale: val.scale,
                    updated: val.updateDate ? new Date(val.updateDate).toISOString(): '',
                    dataType: val.dataType,
                    name: val.name
                }, this.getIndicatorFields(val.indicatorId)
            )
            val.vector.forEach((vectorValue, vectorIndex) => {
                const [year, period] = this.sharedService.getYearAndPeriod(vectorIndex, mod, params.periodicity)
                const yearField = this.sharedService.getYearField(data.startYear + year, period)
                tplData[yearField] = this.getValue(vectorValue)
            })
            return tplData
        })
    }

    /**********************************************************************************************
     * @method getRoundDescription
     *********************************************************************************************/
    private getRoundDescription(roundInfo: IArchivedRoundInfo): string {
        return `${roundInfo.year} ${roundInfo.periodDescr}` +
               `${roundInfo.version > 1 ? ' (' + roundInfo.roundDescr + ')' : ''} `
    }

    /**********************************************************************************************
     * @method getValue
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private getValue(value: any): string {
        return value === null || value === undefined || value.toString() === '' || isNaN(Number(value)) ?
            undefined : value
    }

    /**********************************************************************************************
     * @method getIndicatorFields
     *********************************************************************************************/
    private getIndicatorFields(indicatorId: string): IIndicatorFields {
        const parts = indicatorId.split('.')
        return {
            code: parts[0],
            trn: parts[1],
            agg: parts[2],
            unit: parts[3],
            ref: parts[4]
        }
    }
}
