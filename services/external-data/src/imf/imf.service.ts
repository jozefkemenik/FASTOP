import { CacheMap } from '../../../lib/dist'
import { RequestService } from '../../../lib/dist/request.service'

import { IImfData, IImfDataSet, IImfDictionary, ImfDictionaryKey } from './shared-interfaces'
import { IImfRawCodeList, IImfRawData, IImfRawDictionary, IImfRawDimension, IImfRawSeries } from './index'

export class ImfService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _dictionary: CacheMap<string, IImfDictionary> = new CacheMap<string, IImfDictionary>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getImfData
     *********************************************************************************************/
    public async getImfData(
        dataset: string, queryKey: string, startPeriod: number, endPeriod: number,
    ): Promise<IImfData> {
        const ds = dataset.toUpperCase()
        const key = queryKey.toUpperCase().replace(/,/g, '+')
        const rangeUrl = (!isNaN(startPeriod) ? `startPeriod=${startPeriod}&` : '')
                       + (!isNaN(endPeriod) ? `endPeriod=${endPeriod}` : '')

        const [dictionary, dataSets] = await Promise.all([
            this._dictionary.has(ds) ? Promise.resolve(this._dictionary.get(ds)) :
                this.getRawData<IImfRawDictionary>(`DataStructure/${ds}`)
                    .then(raw => {
                        const dict = this.convertDictionary(raw)
                        this._dictionary.set(ds, dict)
                        return dict
                    }),
            this.getRawData<IImfRawData>(`CompactData/${ds}/${key}?${rangeUrl}`)
                .then(raw => this.convertData(raw))
        ])

        return {
            dictionary,
            dataSets
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRawData
     *********************************************************************************************/
    private async getRawData<T>(urlPart: string): Promise<T> {
        return RequestService.requestHost(
            'dataservices.imf.org', 80,
            `/REST/SDMX_JSON.svc/${urlPart}`,
            'get', undefined, undefined, undefined, true
        )
    }

    /**********************************************************************************************
     * @method convertDictionary
     *********************************************************************************************/
    private convertDictionary(raw: IImfRawDictionary): IImfDictionary {
        const dimensions: IImfRawDimension[] = raw.Structure.KeyFamilies.KeyFamily.Components.Dimension
        const dictionary: IImfDictionary = dimensions.reduce((acc, value, index) => {
            if (value['@conceptRef'] === 'REF_AREA') acc[ImfDictionaryKey.DIMENSION_COUNTRY] = index
            else if (value['@conceptRef'] === 'INDICATOR') acc[ImfDictionaryKey.DIMENSION_INDICATOR] = index
            return acc
        }, {})

        const codes: IImfRawCodeList[] = raw.Structure.CodeLists.CodeList
        return codes.reduce((dict, item) => {
            const id = item['@id']
            dict[id] = item.Code.reduce((codeDict, code) => {
                codeDict[code['@value']] = code.Description['#text']
                return codeDict
            }, {})
            return dict
        }, dictionary)
    }

    /**********************************************************************************************
     * @method convertData
     *********************************************************************************************/
    private convertData(raw: IImfRawData): IImfDataSet[] {
        const series: IImfRawSeries | IImfRawSeries[] = raw?.CompactData?.DataSet?.Series
        const seriesArray: IImfRawSeries[] = Array.isArray(series) ? series : [series]

        return !series ? undefined :
            seriesArray.map(serie => ({
                countryId: serie['@REF_AREA'],
                freqId: serie['@FREQ'],
                indicatorId: serie['@INDICATOR'],
                scaleId: serie['@UNIT_MULT'],
                startYear: Number(serie.Obs[0]['@TIME_PERIOD'].substr(0, 4)),
                endYear:  Number(serie.Obs[serie.Obs.length - 1]['@TIME_PERIOD'].substr(0, 4)),
                series: serie.Obs.reduce((acc, value) => {
                    const freq = serie['@FREQ']
                    const rawPeriod = value['@TIME_PERIOD']
                    const period = freq === 'Q' ? rawPeriod.replace('-', '')
                        : (freq === 'M' ? rawPeriod.split('-').map(Number).join('M') : rawPeriod)
                    acc[period] = Number(value['@OBS_VALUE'])
                    return acc
                }, {})
            }))
    }
}
