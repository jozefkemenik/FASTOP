import {
    HicpDataset,
    HicpIndicatorDataType, IBaseEffectCalcParams, IDBDataType,
    IHicpAggCalcExtendedResult,
    IHicpAnomaliesRange,
    IHicpBaseCalcParams,
    IHicpCalcParams,
    IHicpCalcResult,
    IHicpCategory,
    IHicpCategoryIndicators,
    IHicpCountry,
    IHicpExcelData,
    IHicpExcelRange,
    IHicpIndexRange,
    IHicpIndicator,
    IHicpIndicatorCode,
    IHicpIndicatorData,
    IHicpIndicatorVectors, IHicpRaw,
    IHicpVector,
} from '.'
import { EApps } from 'config'
import { HicpApi } from '../../../lib/dist/api/hicp.api'
import { HicpMongoService } from './hicp.mongo.service'
import { HicpService } from './hicp.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class HicpController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly hicpService: HicpService,
        private readonly hicpMongoService: HicpMongoService
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorCodes
     *********************************************************************************************/
    public async getIndicatorCodes(): Promise<IHicpIndicatorCode[]> {
        return this.hicpService.getIndicatorCodes().then(
            dbIndicators => dbIndicators.map(db => ({
                    indicatorCodeSid: db.INDICATOR_CODE_SID,
                    indicatorId: db.INDICATOR_ID,
                    descr: db.DESCR,
                    parentCodeSids: db.PARENTS?.split(',').filter(sid => sid !== '').map(Number) || [],
                })
            )
        )
    }

    /**********************************************************************************************
     * @method getExcelData
     *********************************************************************************************/
    public async getExcelData(
        countryId: string, dataset: HicpDataset, rangeFrom: string, rangeTo: string, indicatorIds: string[]
    ): Promise<IHicpExcelData> {
        return this.hicpMongoService.getExcelData(dataset, countryId, indicatorIds)
            .then(dbIndicators => {
                const range: IHicpExcelRange = this.getExcelRange(rangeFrom, rangeTo)
                const indicators: IHicpIndicator[] = Object.values(
                    dbIndicators.reduce((acc, dbInd) => {
                        const hicpInd: IHicpIndicator = acc[dbInd.indicatorCodeSid] || dbInd
                        const vector: number[] = this.getNormalizedVector(
                            dbInd.startYear, dbInd.dataType, dbInd.timeserieData, range
                        )

                        if (dbInd.dataType === HicpIndicatorDataType.WEIGHT) hicpInd.weight = vector
                        else hicpInd.index = vector

                        acc[dbInd.indicatorCodeSid] = hicpInd
                        return acc
                    }, {})
                )
                return {
                    indicators,
                    range
                }
            })
    }

    /**********************************************************************************************
     * @method getIndicatorsData
     *********************************************************************************************/
    public async getIndicatorsData(countryId: string, dataset: HicpDataset): Promise<IHicpIndicatorData> {

        return this.hicpMongoService.getIndicatorData(dataset, countryId)
            .then( dbIndicators => {

                // totalMonths is the number of months from year 0
                const [startYear, totalMonths] = dbIndicators.reduce(
                    ([year, months], val) => [
                        Math.min(year, val.START_YEAR),
                        Math.max(months, val.START_YEAR * 12 + val.TIMESERIE_DATA.split(',').length)
                    ], [Number.MAX_VALUE, 0]
                )

                const range: IHicpIndexRange = { startYear, months: totalMonths - (startYear * 12) }
                const vectors = dbIndicators.reduce((curr, val) => {
                    const vectors: IHicpIndicatorVectors = curr[val.INDICATOR_CODE_SID] || { index: [], weight: [] }
                    const hv: IHicpVector = {
                        startYear: val.START_YEAR,
                        vector: val.TIMESERIE_DATA?.split(',').map(v => v !== '' ? Number(v) : null) || []
                    }
                    this.normalizeVectorStart(hv, range.startYear,
                                 HicpIndicatorDataType.WEIGHT === val.DATA_TYPE ? 1 : 12)
                    if (HicpIndicatorDataType.WEIGHT === val.DATA_TYPE) vectors.weight = hv.vector
                    else vectors.index = hv.vector

                    curr[val.INDICATOR_CODE_SID] = vectors
                    return curr
                }, {})

                return { vectors, range }
        })
    }

    /**********************************************************************************************
     * @method getRawIndicatorsData
     *********************************************************************************************/
    public async getRawIndicatorsData(
        countryId: string, dataType: IDBDataType, indicatorIds: string[]
    ): Promise<IHicpRaw[]> {
        return this.hicpMongoService.getRawIndicatorsData(countryId, dataType, indicatorIds)
    }

    /**********************************************************************************************
     * @method getUserCategories
     *********************************************************************************************/
    public async getUserCategories(user: string): Promise<IHicpCategory[]> {
        return this.hicpService.getUserCategories(user).then(
            dbCategories => dbCategories.map(db => ({
                    categorySid: db.CATEGORY_SID,
                    categoryId: db.CATEGORY_ID,
                    label: db.DESCR,
                    rootIndicatorId: db.ROOT_INDICATOR_ID,
                    baseIndicatorId: db.BASE_INDICATOR_ID,
                    childSids: db.CHILD_SIDS ? db.CHILD_SIDS.split(',').map(Number) : undefined,
                    isDefault: Boolean(db.IS_DEFAULT),
                    indicators: db.INDICATOR_IDS?.split(',') || [],
                    orderBy: db.ORDER_BY,
                })
            )
        )
    }

    /**********************************************************************************************
     * @method createCategory
     *********************************************************************************************/
    public async createCategory(category: IHicpCategoryIndicators, user: string): Promise<number> {
        return this.hicpService.createCategory(
            category.categoryId, category.label, category.rootIndicatorId, category.baseIndicatorId,
            category.indicatorIds, user
        )
    }

    /**********************************************************************************************
     * @method updateCategory
     *********************************************************************************************/
    public async updateCategory(
        categorySid: number, category: IHicpCategoryIndicators, user: string
    ): Promise<number> {
        return this.hicpService.updateCategory(
            categorySid, category.categoryId, category.label, category.rootIndicatorId, category.baseIndicatorId,
            category.indicatorIds, user
        )
    }

    /**********************************************************************************************
     * @method deleteCategory
     *********************************************************************************************/
    public async deleteCategory(
        categorySid: number, user: string
    ): Promise<number> {
        return this.hicpService.deleteCategory(categorySid, user)
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(): Promise<IHicpCountry[]> {
        return this.hicpMongoService.getCountries()
    }

    /**********************************************************************************************
     * @method calculateBase
     *********************************************************************************************/
    public async calculateBase(params: IHicpCalcParams): Promise<IHicpCalcResult> {
        return HicpApi.calculateHicp(params)
    }

    /**********************************************************************************************
     * @method calculateBaseStats
     *********************************************************************************************/
    public async calculateBaseStats(params: IHicpCalcParams): Promise<IHicpCalcResult> {
        return HicpApi.calculateBaseStats(params)
    }

    /**********************************************************************************************
     * @method calculateTramoSeats
     *********************************************************************************************/
    public async calculateTramoSeats(params: IHicpCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return HicpApi.calculateTramoSeats(params)
    }

    /**********************************************************************************************
     * @method calculateBaseEffect
     *********************************************************************************************/
    public async calculateBaseEffect(params: IBaseEffectCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return HicpApi.calculateBaseEffect(params)
    }

    /**********************************************************************************************
     * @method calculateContributions
     *********************************************************************************************/
    public async calculateContributions(params: IHicpBaseCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return HicpApi.calculateContributions(params)
    }

    /**********************************************************************************************
     * @method calculateAnomalies
     *********************************************************************************************/
    public async calculateAnomalies(params: IHicpBaseCalcParams): Promise<IHicpAggCalcExtendedResult> {
        return HicpApi.calculateAnomalies(params)
    }

    /**********************************************************************************************
     * @method getAnomaliesRange
     *********************************************************************************************/
    public async getAnomaliesRange(): Promise<IHicpAnomaliesRange> {
        const [startYear, endYear] = await Promise.all([
            this.hicpService.getAnomaliesStartYear(), this.hicpService.getAnomaliesEndYear()]
        )
        return { startYear, endYear }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method normalizeVectorStart
     *********************************************************************************************/
    private normalizeVectorStart(hicpVector: IHicpVector, startYear: number, periodicityIndex: number) {
        if (startYear > 0 && hicpVector.startYear > startYear) {
            hicpVector.vector = Array.from(
                { length: (hicpVector.startYear - startYear) * periodicityIndex }, () => null
            ).concat(hicpVector.vector)
            hicpVector.startYear = startYear
        }
    }

    /**********************************************************************************************
     * @method getNormalizedVector
     *********************************************************************************************/
    private getNormalizedVector(
        startYear: number, dataType: string, timeserie: string, range: IHicpExcelRange
    ): number[] {
        let vector = []
        if (timeserie) {
            const [diff, length] = HicpIndicatorDataType.WEIGHT === dataType ?
                [range.startYear - startYear, range.annualLength] :
                [12 * (range.startYear - startYear) + range.startMonth - 1, range.monthlyLength]

            vector = Array.from({ length: diff < 0 ? -diff : 0 }, () => null)
                .concat(timeserie.split(',').map(v => v !== '' ? Number(v) : null).slice(diff <= 0 ? 0 : diff))
                .slice(0, length)

            const lengthDiff = length - vector.length
            if (lengthDiff > 0) vector = vector.concat(Array.from({ length: lengthDiff }, () => null))
        }

        return vector
    }

    /**********************************************************************************************
     * @method getExcelRange
     *********************************************************************************************/
    private getExcelRange(rangeFrom: string, rangeTo: string): IHicpExcelRange {
        const [startYear, startMonth] = rangeFrom.split('M').map(Number)
        const [endYear, endMonth] = rangeTo.split('M').map(Number)
        return {
            startYear,
            startMonth,
            monthlyLength: 12 * (endYear - startYear) + endMonth - startMonth + 1,
            annualLength: endYear - startYear + 1
        }
    }
}
