import {
    ISpiData,
    ISpiMatrixData,
    ISpiMatrixParams,
    ISpiParams
} from '../../../external-data/src/spi/shared-interfaces'
import { IWQMatrixParams, IWQMatrixSpi, IWQSpi, IWQSpiParams, PrecisionType, QueryType } from './index'
import { BaseFpapiRouter } from '../../../lib/dist'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { SharedService } from '../shared/shared.service'

export class SpiController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly sharedService: SharedService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSpiData
     *********************************************************************************************/
    public async getSpiData(queryType: QueryType, params: IWQSpiParams): Promise<string> {

        const noNomenclatureCode = 'true' === params.no_nomenclature_code?.toLowerCase()
        const wqSpi: IWQSpi = {
            years: [], data: [], domain: params.domain, type_prod: '', update_date: '', dictionary: { countries: {} },
            noNomenclatureCode,
            partner: queryType === QueryType.GEO && ['EXTERNALGEO', 'TRADEGEO'].includes(params.domain.toUpperCase())
        }
        try {
            const spiParams: ISpiParams = this.getSpiParams(params, noNomenclatureCode)
            Object.assign(wqSpi,
                await ExternalDataApi.getSpiData(spiParams)
            )
            this.addMissingData(wqSpi.data, params.country)

            const weights = this.getWeights(spiParams)
            wqSpi.data.sort((a, b) =>
                weights[this.getKey(a.indicator_id, a.country_id)] - weights[this.getKey(b.indicator_id, b.country_id)]
            )
        } catch (ex) {
            // ignore
        }

        const renderFn = this.sharedService.getCompiledTemplate(`../templates/spi.pug`)
        return renderFn(
            { spi: wqSpi, pageTitle: this.getPageTitle(queryType, wqSpi.domain, wqSpi.type_prod),
                downloadDate: new Date().toLocaleString(), precision: this.getPrecision(params.decimal) }
        )
    }

    /**********************************************************************************************
     * @method getSpiMatrixData
     *********************************************************************************************/
    public async getSpiMatrixData(params: IWQMatrixParams): Promise<string> {
        const wqSpi: IWQMatrixSpi = {
            industries: [], data: [], update_date: '', dictionary: { industries: {},products: {} },
        }

        try {
            const spiParams: ISpiMatrixParams = this.getSpiMatrixParams(params)
            Object.assign(wqSpi,
                await ExternalDataApi.getSpiMatrixData(spiParams)
            )
            wqSpi.data = this.addMissingMatrixData(wqSpi.data, spiParams)

            const weights = this.getMatrixWeights(spiParams)
            wqSpi.data.sort((a, b) => {
                const diff = weights[a.country_id] - weights[b.country_id]
                return diff === 0 ? a.year - b.year : diff
            })
        } catch (ex) {
            // ignore
            return ex.toString()
        }

        const renderFn = this.sharedService.getCompiledTemplate(`../templates/spi_matrix.pug`)
        return renderFn(
            { spi: wqSpi, pageTitle: 'Cost structure of industries',
                downloadDate: new Date().toLocaleString(), precision: this.getPrecision(params.decimal) }
        )
    }

    /**********************************************************************************************
     * @method getSpiIqy
     *********************************************************************************************/
    public async getSpiIqy(queryType: QueryType, params: IWQSpiParams | IWQMatrixParams): Promise<string> {
        return queryType === QueryType.MATRIX ? this.getSpiMatrixIqyContent(params as IWQMatrixParams) :
                                                this.getSpiIqyContent(queryType, params as IWQSpiParams)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSpiIqyContent
     *********************************************************************************************/
    private getSpiIqyContent(queryType: QueryType, params: IWQSpiParams): string {
        const p1 = `domain=${params.domain}&indicator=${params.indicator}&country=${params.country}`
        const p2  = this.getYearsUrlPart(params.year, params.start_year, params.end_year)
        const p3 = `&nomenclature=${params.nomenclature}&nomenclature_code=${params.nomenclature_code}`
        const p4 = params.no_nomenclature_code?.trim() ? `&no_nomenclature_code=${params.no_nomenclature_code}` : ''
        const p5 = params.destor?.trim() ? `&destor=${params.destor}` : ''
        const p6 = `&decimal=${params.decimal}`

        return this.sharedService.buildIqyContent(
            `${BaseFpapiRouter.HOST}/wq/spi/${queryType}`,
            `${p1}${p2}${p3}${p4}${p5}${p6}`
        )
    }

    /**********************************************************************************************
     * @method getSpiMatrixIqyContent
     *********************************************************************************************/
    private getSpiMatrixIqyContent(params: IWQMatrixParams): string {
        const p1 = `indicator=${params.indicator}&country=${params.country}`
        const p2  = this.getYearsUrlPart(params.year, params.start_year, params.end_year)
        const p3 = `&industry=${params.industry}&product=${params.product}`
        const p4 = `&decimal=${params.decimal}`

        return this.sharedService.buildIqyContent(
            `${BaseFpapiRouter.HOST}/wq/spi/${QueryType.MATRIX}`,
            `${p1}${p2}${p3}${p4}`
        )
    }

    /**********************************************************************************************
     * @method getSpiParams
     *********************************************************************************************/
    private getSpiParams(params: IWQSpiParams, noNomenclatureCode: boolean): ISpiParams {
        return {
            domain: params.domain,
            indicators: params.indicator?.split(',') || [],
            countries: params.country?.split(',') || [],
            years: params.year?.split(',') || [],
            startYear: params.start_year,
            endYear: params.end_year,
            nomenclature: params.nomenclature,
            nomenclatureCodes: noNomenclatureCode ? [] : params.nomenclature_code?.split(',') || [],
            destor: params.destor?.split(',') || [],
        }
    }

    /**********************************************************************************************
     * @method getSpiMatrixParams
     *********************************************************************************************/
    private getSpiMatrixParams(params: IWQMatrixParams): ISpiMatrixParams {
        return {
            countries: params.country?.split(',') || [],
            indicator: params.indicator,
            industries: params.industry?.split(',') || [],
            products: params.product?.split(',') || [],
            years: params.year?.split(',') || [],
            startYear: params.start_year,
            endYear: params.end_year,
        }
    }

    /**********************************************************************************************
     * @method getYearsUrlPart
     *********************************************************************************************/
    private getYearsUrlPart(year: string, startYear: number, endYear: number): string {
        let urlPart = ''
        if (year) urlPart = `&year=${year}`
        else {
            if (startYear) urlPart = `&start_year=${startYear}`
            if (endYear) urlPart += `&end_year=${endYear}`
        }
        return urlPart
    }

    /**********************************************************************************************
     * @method getWeights
     *********************************************************************************************/
    private getWeights(params: ISpiParams): {[key: string]: number} {
        return params.indicators.reduce((acc, ind, indIndex) => {
            const baseWeight = 10000 * (indIndex + 1)
            params.countries.forEach((country, countryIndex ) =>
                acc[`${ this.getKey(ind, country)}`] = baseWeight + countryIndex + 1
            )
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getMatrixWeights
     *********************************************************************************************/
    private getMatrixWeights(params: ISpiMatrixParams): {[key: string]: number} {
        return params.countries.reduce((acc, country, index) => {
            acc[country] = index
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getKey
     *********************************************************************************************/
    private getKey(indicator: string, country: string): string {
        return `${indicator}_${country}`
    }

    /**********************************************************************************************
     * @method addMissingData
     *********************************************************************************************/
    private addMissingData(data: ISpiData[], countryParam: string) {
        const countries: string[] = countryParam.split(',')

        const grouped: {[indicatorId: string]: ISpiGrouped} = data.reduce((acc, value) => {
            if (!acc[value.indicator_id]) {
                acc[value.indicator_id] = {
                    referenceData: Object.assign({}, value, { data: {} }),
                    countries: new Set<string>()
                }
            }
            acc[value.indicator_id].countries.add(value.country_id)
            return acc
        }, {})

        Object.keys(grouped).forEach(indicatorId => {
            const group: ISpiGrouped = grouped[indicatorId]
            const missingCountries = [...countries].filter(c => !group.countries.has(c))
            for (const countryId of missingCountries) {
                data.push(Object.assign({}, group.referenceData, { country_id: countryId }))
            }
        })

        return data
    }

    /**********************************************************************************************
     * @method addMissingMatrixData
     *********************************************************************************************/
    private addMissingMatrixData(data: ISpiMatrixData[], params: ISpiMatrixParams): ISpiMatrixData[] {
        const keyFunc = (country, year, product) => `${country}_${year}_${product}`
        const dataMap = data.reduce((acc, value) => {
            acc[keyFunc(value.country_id, value.year, value.product)] = value
            return acc
        }, {})

        const result: ISpiMatrixData[] = []
        params.countries.forEach(country =>
            params.years.forEach(year =>
                params.products.forEach(product =>
                    result.push( Object.assign(
                        { country_id: country, year: Number(year), product, values: {} },
                        dataMap[keyFunc(country, year, product)]
                        )
                    )
                )
            )
        )
        return result
    }

    /**********************************************************************************************
     * @method getPageTitle
     *********************************************************************************************/
    private getPageTitle(queryType: QueryType, domain: string, nomenclature: string): string {
        switch(queryType) {
            case QueryType.GEO:
                return `Services by origin and destination - ${nomenclature?.toUpperCase()}`
            default:
                return `${domain} - ${nomenclature?.toUpperCase()}`
        }
    }

    /**********************************************************************************************
     * @method getPrecision
     *********************************************************************************************/
    private getPrecision(precision: PrecisionType): number {
        const digits = Number(precision)
        return precision === 'All' ? -1 : (
            precision === 'None' ? 0 : isNaN(precision) || digits < 0 ? -1 : digits
        )
    }
}

interface ISpiGrouped {
    referenceData: ISpiData
    countries: Set<string>
}
