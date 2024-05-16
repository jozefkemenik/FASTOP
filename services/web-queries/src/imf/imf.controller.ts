import { IImfData, IImfDataSet, ImfDictionaryKey } from '../../../external-data/src/imf/shared-interfaces'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'

import { IWQImf } from './index'
import { SharedService } from '../shared/shared.service'

export class ImfController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private sharedService: SharedService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getImfData
     *********************************************************************************************/
    public async getImfData(
        dataset: string, queryKey: string, startPeriod: number, endPeriod: number,
    ): Promise<string> {
        const imf: IWQImf = { periods: [], dataSets: [] }
        try {
            const imfData: IImfData = await ExternalDataApi.getImfData(
                dataset, queryKey, startPeriod, endPeriod
            )
            const weights = this.getWeights(queryKey, imfData)

            imf.periods = this.getPeriods(startPeriod, endPeriod, imfData.dataSets)
            imf.dataSets = imfData.dataSets.map(ds => ({
                country: imfData.dictionary[ImfDictionaryKey.COUNTRY][ds.countryId],
                freq: imfData.dictionary[ImfDictionaryKey.FREQ][ds.freqId],
                indicatorId: ds.indicatorId,
                indicator: imfData.dictionary[ImfDictionaryKey.INDICATOR][ds.indicatorId],
                scale: imfData.dictionary[ImfDictionaryKey.SCALE][ds.scaleId],
                series: ds.series
            })).sort((a, b) =>
                weights[`${ a.country }_${ a.indicatorId }`] - weights[`${ b.country }_${ b.indicatorId }`]
            )
        } catch (ex) {
            // ignore errors
        }

        const renderFn = this.sharedService.getCompiledTemplate(`../templates/imf.pug`)
        return renderFn(
            { imf, pageTitle: 'IMF', lastRefresh: new Date().toLocaleString() }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getWeights
     *********************************************************************************************/
    private getWeights(queryKey: string, imfData: IImfData): {[key: string]: number} {
        const dimensions = queryKey.split('.')
        const countries: string[] = dimensions[
                Number(imfData.dictionary[ImfDictionaryKey.DIMENSION_COUNTRY])
            ].split(',')
        const indicators: string[] = dimensions[
                Number(imfData.dictionary[ImfDictionaryKey.DIMENSION_INDICATOR])
            ].split(',')

        return countries.reduce((acc, country, countryIndex) => {
            const baseWeight = 10000 * (countryIndex + 1)
            indicators.forEach((ind, indIndex) => {
                acc[`${ imfData.dictionary[ImfDictionaryKey.COUNTRY][country] }_${ ind }`] = baseWeight + indIndex + 1
            })
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getPeriods
     *********************************************************************************************/
    private getPeriods(
        startPeriod: number, endPeriod: number, dataSets: IImfDataSet[]
    ): string[] {
        if (!dataSets || !dataSets.length) return []

        const freq = dataSets[0].freqId !== 'A' ? dataSets[0].freqId : ''
        const [minYear, maxYear] = dataSets.reduce(([min, max], ds) =>
            [Math.min(min, ds.startYear), Math.max(max, ds.endYear)]
        , [Number.MAX_VALUE, Number.MIN_VALUE])

        const startYear = !isNaN(startPeriod) ? startPeriod : minYear
        const endYear = !isNaN(endPeriod) ? endPeriod : maxYear
        const multiplier = freq === 'M' ? 12 : (freq === 'Q' ? 4 : 1)

        return Array.from(
            {length: (endYear - startYear + 1) * multiplier},
            (_, i) =>
                `${startYear + Math.floor(i / multiplier)}${freq}${i % multiplier + 1}`
        )
    }
}
