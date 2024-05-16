import { ISdmxData, ISdmxLabels, SdmxProvider } from '../../../lib/dist/sdmx/shared-interfaces'
import { ITplData, ITplIndicators } from '../shared/shared-interfaces'
import { SdmxApi } from '../../../lib/dist/api/sdmx.api'
import { SdmxFunction } from '.'
import { SharedService } from '../shared/shared.service'

export class SdmxController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private sharedService: SharedService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getEurostatData
     *********************************************************************************************/
    public async getEurostatData(
        dataset: string, seriesCode: string, fetchLabels: boolean,
        startPeriod: string, endPeriod: string, jsonFormat: boolean
    ): Promise<string> {
        return this.getSdmxData(SdmxProvider.ESTAT, 'Eurostat data', dataset, seriesCode,
            fetchLabels, startPeriod, endPeriod, SdmxApi.getData, ['GEO', 'FREQ'], jsonFormat)
    }

    /**********************************************************************************************
     * @method getEcbData
     *********************************************************************************************/
    public async getEcbData(
        dataset: string, seriesCode: string, fetchLabels: boolean,
        startPeriod: string, endPeriod: string, jsonFormat: boolean
    ): Promise<string> {
        return this.getSdmxData(SdmxProvider.ECB, 'ECB data', dataset, seriesCode,
            fetchLabels, startPeriod, endPeriod, SdmxApi.getData, [], jsonFormat)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Private Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getSdmxData
     *********************************************************************************************/
    public async getSdmxData(
        provider: SdmxProvider, title: string, dataset: string, seriesCode: string, fetchLabels: boolean,
        startPeriod: string, endPeriod: string, sdmxFunction: SdmxFunction, skippedNames: string[], jsonFormat: boolean
    ): Promise<string> {
        let tplData: ITplIndicators  = {
            columns: [],
            data: []
        }

        try {
            const sdmxData: ISdmxData = await sdmxFunction(
                provider, dataset, seriesCode.replace(/,/g, '+'), fetchLabels, startPeriod, endPeriod
            )

            const descriptions: string[] = !fetchLabels ? [] : sdmxData.names.filter(
                n => !skippedNames.includes(n.toUpperCase())).map(d => `${d.toUpperCase()}_LABEL`
            )
            const years = this.extendRange(Object.keys(sdmxData.data[0].item).sort(), startPeriod, endPeriod)
            const columns = sdmxData.names.concat(descriptions)
                                          .map(name => ({ label: name.toUpperCase(), field: name }))
                                          .concat(
                                              years.map(year => ({
                                                  label: year,
                                                  field: year,
                                                  observation: !jsonFormat ? true : undefined
                                              }))
                                          )
            const data = sdmxData.data.map(d => d.index
                .concat(!fetchLabels ? [] : this.getDescriptions(
                    d.index, sdmxData.names, skippedNames, sdmxData.labels)
                ).concat(years.map(year => this.getValue(d.item[year]?.toString())))
            )
            tplData = {
                columns,
                data: data.map(row =>
                    columns.reduce((curr, val, index) => (
                        curr[val.field] = row[index], curr
                    ), {} as ITplData)
                )
            }
        } catch (ex) {
            // ignore any exception, Excel expects valid html response
        }

        if (jsonFormat) return JSON.stringify(tplData)
        else {
            const renderFn = this.sharedService.getCompiledTemplate(`../templates/sdmx.pug`)
            return renderFn({ title, sdmx: tplData, lastRefresh: new Date().toLocaleString() })
        }
    }

    /**********************************************************************************************
     * @method getValue
     *********************************************************************************************/
    private getValue(value: string): string {
        return value !== undefined && value !== null && !isNaN(Number(value)) ? value : ''
    }

    /**********************************************************************************************
     * @method extendRange
     *********************************************************************************************/
    private extendRange(range: string[], startPeriod: string, endPeriod: string): string[] {
        const periodicity = this.getPeriodicity(range[0])
        const [rangeStart, rangeEnd] = [this.getYearFromPeriod(range[0]),
                                        this.getYearFromPeriod(range[range.length - 1])]
        const mod = periodicity === 'M' ? 12 : (periodicity === 'Q' ? 4 : 1)

        const startYear = startPeriod ? Math.min(this.getYearFromPeriod(startPeriod), rangeStart) : rangeStart
        const endYear = endPeriod ? Math.max(this.getYearFromPeriod(endPeriod), rangeEnd) : rangeEnd
        return Array.from(
            { length: (1 + endYear - startYear) * mod},
            (_, index) => this.getPeriodName(startYear, index, periodicity)
        )
    }

    /**********************************************************************************************
     * @method getPeriodName
     *********************************************************************************************/
    private getPeriodName(startYear: number, index: number, periodicity: string): string {
        if (periodicity === 'Q') return `${startYear + Math.floor(index / 4)}-Q${(index % 4) + 1}`
        if (periodicity === 'M') {
            const month: number = (index % 12) + 1
            return `${startYear + Math.floor(index / 12)}-${month < 10 ? '0' : ''}${month}`
        }
        return `${startYear + index}`
    }

    /**********************************************************************************************
     * @method getPeriodicity
     *********************************************************************************************/
    private getPeriodicity(period: string): 'A' | 'Q' | 'M' {
        if (period.match(/^\d\d\d\d-Q\d$/)) return 'Q'
        if (period.match(/^\d\d\d\d-\d{1,2}$/)) return 'M'

        return 'A'
    }

    /**********************************************************************************************
     * @method getYearFromPeriod
     *********************************************************************************************/
    private getYearFromPeriod(period: string): number {
        const matched = period.match(/^\d\d\d\d/)
        return Number(matched[0])
    }

    /**********************************************************************************************
     * @method getDescriptions
     *********************************************************************************************/
    private getDescriptions(
        indexValues: string[], names: string[], skippedNames: string[], labels: ISdmxLabels
    ): string[] {
        return indexValues.reduce((acc, iv, index) => {
            if (!skippedNames.includes(names[index].toUpperCase())) acc.push(labels[names[index]][iv])
            return acc
        }, [])
    }
}
