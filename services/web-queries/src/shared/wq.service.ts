import {
    ITTConvertParams,
    ITTDoubleParams,
    IVector,
    IWQCountryIndicator,
    IWQCountryIndicators,
    IWQInputParams,
    IWQRequestParams,
    TransformationType,
} from './shared-interfaces'
import { FdmsStarApi } from '../../../lib/dist/api/fdms-star.api'
import { TransformationFunction } from '.'

export abstract class WqService<T extends IWQRequestParams, D> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public static readonly MIN_YEAR = 1960

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public abstract getIndicatorData(params: T, dictionary: D): Promise<IWQCountryIndicators>

    /**********************************************************************************************
     * @method transformData
     *********************************************************************************************/
    public async transformData(params: IWQInputParams, data: IWQCountryIndicators): Promise<IWQCountryIndicators> {
        switch (params.transformation.type) {
            case TransformationType.CONVERT:
                return await this.convertFrequency(params, data)
            case TransformationType.ADD:
            case TransformationType.MINUS:
                return await this.addOrSubstractIndicators(params, data)
            case TransformationType.PCT:
                return await this.calculatePercentageChange(params, data)
            default:
                return data
        }
    }

    /**********************************************************************************************
     * @method getDictionary
     *********************************************************************************************/
    public async getDictionary(): Promise<D> {
        return undefined
    }

    /**********************************************************************************************
     * @method normalizeCountry
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    public normalizeCountry(countryId: string, dictionary: D, params: IWQInputParams): string {
        return countryId
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertFrequency
     *********************************************************************************************/
    private async convertFrequency(
        params: IWQInputParams, data: IWQCountryIndicators
    ): Promise<IWQCountryIndicators> {
        const tf: TransformationFunction = async (vectors: IVector[], startYear: number, p: IWQInputParams) => {
            const convertParams: ITTConvertParams = p.transformation.params as ITTConvertParams
            params.periodicity = convertParams.outputPeriodicity
            return await FdmsStarApi.convertFrequency(
                vectors, startYear, convertParams.inputPeriodicity, convertParams.outputPeriodicity
            )
        }
        return await this.runTransformation(params, data, tf)
    }

    /**********************************************************************************************
     * @method addOrSubstractIndicators
     *********************************************************************************************/
    private async addOrSubstractIndicators(
        params: IWQInputParams, data: IWQCountryIndicators
    ): Promise<IWQCountryIndicators> {
        const tf: TransformationFunction = async (vectors: IVector[], startYear: number, p: IWQInputParams) => {
            const doubleParams: ITTDoubleParams = p.transformation.params as ITTDoubleParams
            const sign = params.transformation.type === TransformationType.ADD ? '+' : '-'
            const codes = `${this.getCode(doubleParams.serieA)}${sign}${this.getCode(doubleParams.serieB)}`
            const newIndicatorId = `${codes}.0.0.0.0`
            p.indicators = [newIndicatorId]
            const scaleSet: Set<string> = new Set<string>()
            const ctyMap: {[key: string]: IWQCountryIndicator} = data.indicators.reduce((acc, ind)=> {
                acc[ind.countryId] = acc[ind.countryId] || ind
                acc[ind.countryId].indicatorId = newIndicatorId
                scaleSet.add(ind.scale)
                return acc
            }, {})
            if (scaleSet.size > 1) throw new Error('Cannot add or subtract indicators with different scale!')
            data.indicators = Object.keys(ctyMap).map(countryId => ctyMap[countryId])
            if (params.transformation.type === TransformationType.MINUS) {
                // negate second parameter and calculate sum
                vectors.filter(v => v.indicatorId === doubleParams.serieB)
                    .forEach(v => v.data = v.data.map(d => d !== '' ? (-1 * Number(d)).toString() : d))
            }
            const result = await FdmsStarApi.calculateSum(vectors, startYear, params.periodicity)
            result.forEach(v => v.indicatorId = newIndicatorId)
            return result
        }
        return await this.runTransformation(params, data, tf)
    }

    /**********************************************************************************************
     * @method getCode
     *********************************************************************************************/
    private getCode(indicatorId: string): string {
        return indicatorId.split('.')[0]
    }

    /**********************************************************************************************
     * @method calculatePercentageChange
     *********************************************************************************************/
    private async calculatePercentageChange(
        params: IWQInputParams, data: IWQCountryIndicators
    ): Promise<IWQCountryIndicators> {
        const tf: TransformationFunction = async (vectors: IVector[], startYear: number, p: IWQInputParams) => {
            const newIndicatorId = `PCT_${p.transformation.params}`
            p.indicators = [newIndicatorId]
            data.indicators.forEach((i) => i.indicatorId  = newIndicatorId)
            const result = await FdmsStarApi.calculatePCT(vectors, startYear, params.periodicity)
            result.forEach(v => v.indicatorId = newIndicatorId)
            return result
        }
        return await this.runTransformation(params, data, tf)
    }

    /**********************************************************************************************
     * @method runTransformation
     *********************************************************************************************/
    private async runTransformation(
        params: IWQInputParams, data: IWQCountryIndicators, transformationFunction: TransformationFunction,
    ): Promise<IWQCountryIndicators> {
        const vectors: IVector[] = data.indicators.map(indicator => ({
            indicatorId: indicator.indicatorId,
            countryId: indicator.countryId,
            data: indicator.vector.map(v => v === null ? '' : v.toString()),
        }))
        const converted: IVector[] = await transformationFunction(vectors, data.startYear, params)
        const keyFunc = (indicatorId: string, countryId: string) => `${indicatorId}_${countryId}`
        const indicatorMap: { [key: string]: IWQCountryIndicator} = data.indicators.reduce((acc, indicator) => {
            acc[keyFunc(indicator.indicatorId, indicator.countryId)] = indicator
            return acc
        }, { } )

        return {
            startYear: data.startYear,
            vectorLength: converted.length > 0 ? converted[0].data.length : 0,
            indicators: converted.map(c => {
                const indicator = indicatorMap[keyFunc(c.indicatorId, c.countryId)]
                return Object.assign(indicator, { vector: c.data })
            })
        }
    }
}
