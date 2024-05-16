import { IAmecoChapter, IAmecoDataDict, IAmecoIndexedData, IAmecoSerie, IAmecoSeriesData } from './shared-interfaces'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { ICountry } from '../addin/shared-interfaces'
import { LibAmecoService } from './lib-ameco.service'
import { catchAll } from '../catch-decorator'

@catchAll(__filename)
export class LibAmecoController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public constructor(
        protected readonly amecoService: LibAmecoService,
    ) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(amecoType: AmecoType): Promise<ICountry[]> {
        return this.amecoService.getCountries(amecoType)
    }

    /**********************************************************************************************
     * @method getSeries
     *********************************************************************************************/
    public async getSeries(amecoType: AmecoType): Promise<IAmecoSerie[]> {
        return this.amecoService.getSeries(amecoType)
    }

    /**********************************************************************************************
     * @method getChapters
     *********************************************************************************************/
    public async getChapters(amecoType: AmecoType): Promise<IAmecoChapter[]> {
        return this.amecoService.getChapters(amecoType)
    }

    /**********************************************************************************************
     * @method getSeriesData
     *********************************************************************************************/
    public async getSeriesData(
        amecoType: AmecoType, countries: string, series: string, expectedStartYear: number
    ): Promise<IAmecoIndexedData> {
        const seriesData: IAmecoSeriesData[] = await this.amecoService.getAmecoSeriesData(amecoType, countries, series)
        if (!seriesData || !seriesData.length) return undefined

        const [ctySet, unitSet, startYear, endYear] = seriesData.reduce(([currCountries, currUnits, start, end], serie) => {
            currCountries.add(serie.COUNTRY_ID)
            currUnits.add(serie.UNIT)

            return [currCountries, currUnits,
                Math.min(serie.START_YEAR, start),
                Math.max(serie.START_YEAR + serie.TIME_SERIE.split(',').length - 1, end)
            ]
        }, [new Set<string>(), new Set<string>(), Number.MAX_VALUE, 0])

        const idToIndexMap = (ids: string[]) => ids.reduce((curr, val, index) => curr.set(val, index), new Map<string, number>())

        const dict: IAmecoDataDict = { countries: Array.from(ctySet.values()), units: Array.from(unitSet.values()), }
        const ctyMap: Map<string, number> = idToIndexMap(dict.countries)
        const unitMap: Map<string, number> = idToIndexMap(dict.units)
        const newStartYear = expectedStartYear && !isNaN(expectedStartYear) ? expectedStartYear : startYear
        return {
            startYear: newStartYear,
            dict,
            data: seriesData.reduce((curr, serie) => {
                curr.push([
                    ctyMap.get(serie.COUNTRY_ID),
                    serie.SERIE_SID,
                    unitMap.get(serie.UNIT),
                    this.normalizeTimeSerie(serie.TIME_SERIE, serie.START_YEAR, newStartYear, endYear)
                ])
                return curr
            }, [])
        }
    }

    /**********************************************************************************************
     * @method normalizeTimeSerie
     *********************************************************************************************/
    private normalizeTimeSerie(
        timeSerie: string, serieStartYear: number, newStartYear: number, maxEndYear: number
    ): string {
        const emptyArray = (len: number) => Array.from({ length: len }, () => 'na')
        let vector: string[] = timeSerie.split(',')

        const yearDiff = newStartYear - serieStartYear
        if (yearDiff > 0)  vector = vector.slice(yearDiff)
        else if (yearDiff < 0) vector = emptyArray(-yearDiff).concat(vector)

        const maxLength = maxEndYear - newStartYear + 1
        if (vector.length < maxLength) vector = vector.concat(emptyArray(maxLength - vector.length))
        else if (vector.length > maxLength) vector = vector.slice(0, maxLength)

        return vector.join(',')
    }
}
