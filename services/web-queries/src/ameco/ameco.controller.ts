import { LocalsObject } from 'pug'
import { Query } from 'express-serve-static-core'

import { BaseFpapiRouter, Level, LoggingService } from '../../../lib/dist'
import {
    IAmecoData,
    IAmecoInternalLastUpdate,
    IAmecoLastUpdate,
} from '../../../external-data/src/ameco/shared-interfaces'
import { IAmecoInternalLegacyInputParams, IAmecoLegacyInputParams } from '.'
import {
    IWQAmecoDictionary,
    IWQAmecoInternalMetadata,
    IWQAmecoRequestParams
} from './shared-interfaces'
import { AmecoService } from './ameco.service'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { EApps } from 'config'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { IWQInputParams } from '../shared/shared-interfaces'
import { IWQRenderData } from '../shared'
import { ParamsService } from '../shared/params.service'
import { SharedService } from '../shared/shared.service'
import { WqController } from '../shared/wq.controller'
import { config } from '../../../config/config'


export class AmecoController extends WqController<IWQAmecoRequestParams, IWQAmecoDictionary> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private amecoService: AmecoService,
        sharedService: SharedService,
        logs: LoggingService,
    ) {
        super(EApps.AMECO, amecoService, sharedService, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoData
     *********************************************************************************************/
    public async getAmecoData(
        amecoType: AmecoType, params: IWQInputParams
    ): Promise<string> {
        const lastUpdate = await (amecoType !== AmecoType.ONLINE ? ExternalDataApi.getAmecoLastUpdate(amecoType)
                                                          : Promise.resolve(undefined))
        const legends = [{ name: 'Ameco', value: `${amecoType.toUpperCase()}` }]
        if (lastUpdate) {
            legends.push(
                { name: 'Last update', value: this.formatDate(this.toDate(this.getLastUpdate(amecoType, lastUpdate)))}
            )
        }

        return this.getWqData(this.getAmecoRequestParams(amecoType, params), ...legends)
    }

    /**********************************************************************************************
     * @method getAmecoRawData
     *********************************************************************************************/
    public getAmecoRawData(
        amecoType: AmecoType, params: IWQInputParams
    ): Promise<IWQRenderData<IWQAmecoRequestParams>> {
        return this.getWqIndicators(this.getAmecoRequestParams(amecoType, params), false)
    }

    /**********************************************************************************************
     * @method getAmecoLegacyData
     *********************************************************************************************/
   public async getAmecoLegacyData(amecoType: AmecoType, params: IAmecoLegacyInputParams): Promise<string> {
        try {
            if (!params.indicators?.length) throw Error('Invalid parameters - no variables specified!')

            const countries = params.defaultCountries ? [] : params.countries
            const indicators = this.convertLegacyIndicators(params.indicators)

            const [data, lastUpdate] = await Promise.all([
                ExternalDataApi.getAmecoFullData(
                    amecoType, countries, indicators, params.defaultCountries
                ),
                amecoType !== AmecoType.ONLINE ?
                    ExternalDataApi.getAmecoLastUpdate(amecoType) : Promise.resolve(undefined)
            ])

            const years = this.getYears(data, params)
            const columns = this.getTemplateColumns(amecoType, params).concat(
                years.map(year => ({ label: `${year}`, field: `${year}`, formula: true }))
            )

            const renderFn = this.sharedService.getCompiledTemplate(`../templates/${this.getTemplateName(amecoType)}`)
            return renderFn(
                amecoType === AmecoType.ONLINE ?
                      this.getAmecoOnlineTemplateData(columns, years, data)
                    : this.getAmecoInternalTemplateData(amecoType, columns, years, data, lastUpdate, params.internal)
            )
        } catch(ex) {
            const error = ex.toString()
            this.logs.log(error, Level.ERROR)
            return error
        }
    }

    /**********************************************************************************************
     * @method getAmecoIqyFile
     *********************************************************************************************/
    public async getAmecoIqyFile(amecoType: AmecoType, query: Query): Promise<string> {
        const url = this.getAmecoUrl(amecoType)
        const params = Object.keys(query).map(key => {
            const value = query[key]
            return value !== undefined && value !== '' ? `${key}=${value}` : `${key}`
        }).join('&')

        return this.sharedService.buildIqyContent(`${url}?${params}`, '')
    }

    /**********************************************************************************************
     * @method isAmecoInternalForecastPeriod
     *********************************************************************************************/
    public async isAmecoInternalForecastPeriod(): Promise<boolean> {
        return ExternalDataApi.isAmecoInternalForecastPeriod()
    }

    /**********************************************************************************************
     * @method getAmecoInternalMetadata
     *********************************************************************************************/
    public async getAmecoInternalMetadata(): Promise<IWQAmecoInternalMetadata> {
        const [countries, trn, agg, unit, series, treeData] = await Promise.all([
            ExternalDataApi.getAmecoInternalMetadataCountries(),
            ExternalDataApi.getAmecoInternalMetadataTransformations(),
            ExternalDataApi.getAmecoInternalMetadataAggregations(),
            ExternalDataApi.getAmecoInternalMetadataUnits(),
            ExternalDataApi.getAmecoInternalMetadataSeries(),
            ExternalDataApi.getAmecoInternalMetadataTree(),
        ])

        return {
            countries,
            trn,
            agg,
            unit,
            tree: this.amecoService.buildAmecoMetadataTree(series, treeData)
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    protected async getCountryGroupCountries(ctyGroup: string): Promise<string[]> {
        return AmecoService.DEFAULT_COUNTRIES === ctyGroup ? undefined : super.getCountryGroupCountries(ctyGroup, true)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTemplateName
     *********************************************************************************************/
    private getTemplateName(amecoType: AmecoType): string {
        return `ameco_${amecoType === AmecoType.ONLINE ? 'online' : 'internal'}_legacy.pug`
    }

    /**********************************************************************************************
     * @method getTemplateColumns
     *********************************************************************************************/
    private getTemplateColumns(amecoType: AmecoType, params: IAmecoLegacyInputParams): IColumn[] {

        if (amecoType === AmecoType.ONLINE) {
            return [
                { label: 'Country', field: 'country' },
                { label: 'Label', field: 'label' },
                { label: 'Unit', field: 'unit' },
            ]
        }

        const columns = []
        if (params.internal.transpose) {
            if (params.internal.showVariable) columns.push({ label: 'Variable', field: 'variable' })
            columns.push({ label: 'Country', field: 'country' })
        } else {
            columns.push({ label: 'Country', field: 'country' })
            if (params.internal.showVariable) columns.push({ label: 'Variable', field: 'variable' })
        }

        if (params.internal.showFullVariable) columns.push({ label: 'Full Variable', field: 'fullVariable' })
        if (params.internal.showFullCode) columns.push({ label: 'Full Code', field: 'fullCode' })
        if (params.internal.showLabel) columns.push({ label: 'Label', field: 'label' })
        columns.push({ label: 'Unit', field: 'unit' })

        return columns
    }

    /**********************************************************************************************
     * @method getAmecoInternalIqyUrlParams
     *********************************************************************************************/
    private getAmecoInternalIqyUrlParams(params: IAmecoInternalLegacyInputParams): string {

        const p1 = `&yearOnXAxis=${Number(!params.transpose)}`
        const p2 = `&countryIso=${params.useIso3 ? 3 : 2}`
        const p3 = `&showVariable=${Number(params.showVariable)}`
        const p4 = `&showFullVariable=${Number(params.showFullVariable)}`
        const p5 = `&showFullCode=${Number(params.showFullCode)}`
        const p6 = `&showLabel=${Number(params.showLabel)}`

        return `${p1}${p2}${p3}${p4}${p5}${p6}`
    }

    /**********************************************************************************************
     * @method getAmecoRequestParams
     *********************************************************************************************/
    private getAmecoRequestParams(amecoType: AmecoType, params: IWQInputParams): IWQAmecoRequestParams {
        const showName = ParamsService.boolParam(params.query.name, true)
        const showCountryName = ParamsService.boolParam(params.query.country_name, true)

        return Object.assign(
            {
                amecoType,
                useIso2: ParamsService.boolParam(params.query.useiso2),
                showName,
                showCountryName,
                customColumns: [].concat(showName ? [{ label: 'Name', field: 'name' }] : [])
                                 .concat(showCountryName ? [{ label: 'Country name', field: 'countryDesc'}] : [])
            }, params
        )
    }

    /**********************************************************************************************
     * @method getYears
     *********************************************************************************************/
    private getYears(data: IAmecoData[], params: IAmecoLegacyInputParams): number[] {
        const [minYear, maxYear] = data.reduce(([min, max], val) =>
                [Math.min(min, val.startYear), Math.max(max, val.startYear + val.vector.length)]
            , [3000, 0])

        const years = params.years?.length ?
            (!params.lastYear ? params.years : this.getLastYears(params.years, maxYear))
            : this.getYearsRange(minYear, maxYear)

        years.sort()
        if (params.orderDesc) years.reverse()

        return years
    }

    /**********************************************************************************************
     * @method getObservations
     *********************************************************************************************/
    private getObservations(years: number[], vectorStartYear: number, vector: number[]): IObservations {
        const vectorMap: Map<number, string> = vector.reduce((acc, curr, index) => {
            acc.set(vectorStartYear + index, curr !== null ? `${curr}` : '')
            return acc
        }, new Map<number, string>())

        return years.reduce((acc, curr) => {
            acc[curr] = vectorMap.get(curr)
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getYearsRange
     *********************************************************************************************/
    private getYearsRange(startYear: number, endYear: number): number[] {
        return Array.from( { length: 1 + endYear - startYear }, (_, index) => startYear + index)
    }

    /**********************************************************************************************
     * @method getLastYears
     *********************************************************************************************/
    private getLastYears(years: number[], lastYear: number): number[] {
        const max = Math.max(...years)
        return years.concat(this.getYearsRange(max + 1, lastYear))
    }

    /**********************************************************************************************
     * @method convertLegacyIndicators change ameco notation, 1.0.0.0.UBLG => UBLG.1.0.0.0
     *********************************************************************************************/
    private convertLegacyIndicators(indicators: string[]): string[] {
        return indicators ? indicators.map(ind => {
            const tmp = ind.split('.')
            return !isNaN(Number(tmp[0])) ? [tmp[tmp.length-1]].concat(tmp.slice(0, tmp.length-1)).join('.') : ind
        }) : undefined
    }

    /**********************************************************************************************
     * @method getAmecoUrl
     *********************************************************************************************/
    private getAmecoUrl(amecoType: AmecoType): string {
        let amecoUrlPart = undefined
        switch (amecoType) {
            case AmecoType.ONLINE: amecoUrlPart = 'online'; break
            case AmecoType.PUBLIC: amecoUrlPart = 'public'; break
            case AmecoType.CURRENT: amecoUrlPart = 'current'; break
            case AmecoType.RESTRICTED: amecoUrlPart = 'restricted'; break
        }

        return config.amecoPublicHost || `${BaseFpapiRouter.HOST}/wq/ameco/${amecoUrlPart}`
    }

    /**********************************************************************************************
     * @method getAmecoOnlineTemplateData
     *********************************************************************************************/
    private getAmecoOnlineTemplateData(columns: IColumn[], years: number[], data: IAmecoData[]): LocalsObject {
        return {
            columns,
            amecoType: 'online',
            data: data.map(d =>
                Object.assign({
                    country: d.countryDesc,
                    label: d.name,
                    unit: d.scale,
                }, this.getObservations(years, d.startYear, d.vector))
            )
        }
    }

    /**********************************************************************************************
     * @method toDate
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private toDate(data: any): Date {
        return !data ? undefined : new Date(data)
    }

    /**********************************************************************************************
     * @method getAmecoInternalTemplateData
     *********************************************************************************************/
    private getAmecoInternalTemplateData(
        amecoType: AmecoType, columns: IColumn[], years: number[], data: IAmecoData[],
        lastUpdate: IAmecoLastUpdate, internalParams: IAmecoInternalLegacyInputParams,
    ): LocalsObject {

        return {
            columns,
            transpose: internalParams.transpose,
            version: this.getAmecoVersionLabel(amecoType),
            lastUpdate: this.formatDate(this.toDate(this.getLastUpdate(amecoType, lastUpdate))),
            data: data.map(d => {
                const country = internalParams.useIso3 ? d.countryIdIso3 : d.countryIdIso2
                const amecoIndicator = this.convertToAmecoNotation(d.indicatorId)
                return Object.assign({
                    country,
                    variable: d.indicatorId.split('.')[0],
                    fullVariable: amecoIndicator,
                    fullCode: `${country}.${amecoIndicator}`,
                    label: d.name,
                    unit: d.scale,
                }, this.getObservations(years, d.startYear, d.vector))
            })
        }
    }

    /**********************************************************************************************
     * @method convertToAmecoNotation
     * @param indicatorId indicator code in format ABCD.1.2.3.4
     * @return indicator in ameco notation: 1.2.3.4.ABCD
     *********************************************************************************************/
    private convertToAmecoNotation(indicatorId: string): string {
        const tmp = indicatorId.split('.')
        return tmp.slice(1).concat(tmp[0]).join('.')
    }

    /**********************************************************************************************
     * @method getAmecoVersionLabel
     *********************************************************************************************/
    private getAmecoVersionLabel(amecoType: AmecoType): string {
        switch (amecoType) {
            case AmecoType.PUBLIC: return 'Annex'
            case AmecoType.CURRENT: return 'Current'
            case AmecoType.RESTRICTED: return 'Restricted'
            default: return `${amecoType}`
        }
    }

    /**********************************************************************************************
     * @method getLastUpdate
     *********************************************************************************************/
    private getLastUpdate(amecoType: AmecoType, lastUpdate: IAmecoLastUpdate): Date {
        switch (amecoType) {
            case AmecoType.RESTRICTED: return (lastUpdate as IAmecoInternalLastUpdate).restricted
            case AmecoType.CURRENT: return  (lastUpdate as IAmecoInternalLastUpdate).current
            case AmecoType.PUBLIC: return  (lastUpdate as IAmecoInternalLastUpdate).annex
            case AmecoType.ONLINE: return lastUpdate as Date
            default: return undefined
        }
    }
}

interface IObservations {
    [key: number]: string
}

interface IColumn {
    label: string
    field: string
    formula?: boolean
}
