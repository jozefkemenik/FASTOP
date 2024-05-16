import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, STRING } from '../../../lib/dist/db'
import { DashboardApi, DataAccessApi, MongoDataAccessApi } from '../../../lib/dist/api'
import { HicpDataset, IHicpCountry } from './shared-interfaces'
import {
    IDBDataType,
    IDBHicpEstat,
    IDBHicpEstatData,
    IDBHicpIndicator,
    IDBHicpIndicatorData,
    IEstatToIndicatorMap,
    IHicpPipelineParams,
    IHicpRaw
} from './index'
import { CacheMap } from '../../../lib/dist'
import { ICountry } from '../../../lib/dist/menu'
import { IMongoDoc } from '../../../lib/dist/mongo/shared-interfaces'


export class HicpMongoService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly INDEX_COLLECTION = 'PRC_HICP_MIDX'
    private static readonly TAX_RATE_COLLECTION = 'PRC_HICP_CIND'
    private static readonly WEIGHT_COLLECTION = 'PRC_HICP_INW'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _countries = new CacheMap<string, IHicpCountry[]>()
    private _estatMap = new CacheMap<IDBDataType, IEstatToIndicatorMap>()

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(): Promise<IHicpCountry[]> {
        return this.getCountryCodes().then(countryIds => this.getHicpCountries(countryIds))
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(dataset: HicpDataset, countryId: string): Promise<IDBHicpIndicatorData[]> {
        return this.getHicpDataWithWeights(dataset, countryId).then(
            data => data.map(i => ({
              INDICATOR_CODE_SID: i.INDICATOR_CODE_SID,
              START_YEAR: i.START_YEAR,
              TIMESERIE_DATA: i.TIMESERIE_DATA,
              DATA_TYPE: i.DATA_TYPE
          })))
    }

    /**********************************************************************************************
     * @method getRawIndicatorsData
     *********************************************************************************************/
    public async getRawIndicatorsData(
        countryId: string, dataType: IDBDataType, indicatorIds: string[]
    ): Promise<IHicpRaw[]> {
        return this.getHicpData(dataType, countryId, indicatorIds).then(
            data => data.map(
                i => [i.INDICATOR_ID, i.PERIODICITY_ID, i.START_YEAR, i.TIMESERIE_DATA]
            )
        )
    }

    /**********************************************************************************************
     * @method getExcelData
     *********************************************************************************************/
    public async getExcelData(
        dataset: HicpDataset, countryId: string, indicatorIds: string[]
    ): Promise<IDBHicpIndicator[]> {
        return this.getHicpDataWithWeights(dataset, countryId, indicatorIds).then(
            data => data.map(i => ({
                indicatorCodeSid: i.INDICATOR_CODE_SID,
                indicatorId: i.INDICATOR_ID,
                indicatorSid: i.INDICATOR_SID,
                descr: i.DESCR,
                dataType: i.DATA_TYPE,
                startYear: i.START_YEAR,
                timeserieData: i.TIMESERIE_DATA,
                lastUpdated: i.LAST_UPDATED,
                updatedBy: 'airflow',
            }))
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getHicpData
     *********************************************************************************************/
    private async getHicpData(
        dataType: IDBDataType, countryId: string, indicatorIds?: string[]
    ): Promise<IDBHicpEstatData[]> {

        const estatMap: IEstatToIndicatorMap = await this.getEstatMap(dataType).then(estatMap => {
            if (!indicatorIds || !indicatorIds.length) return estatMap

            const indSet = new Set<string>(indicatorIds)
            return Object.entries(estatMap).filter(
                /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
                ([key, indicator]) => indSet.has(indicator.INDICATOR_ID)
            ).reduce((acc, [key, indicator]) => (acc[key] = indicator, acc), {})
        })
        const params: IHicpPipelineParams = this.getPipelineParams(dataType, countryId, Object.keys(estatMap))

        const docs: IMongoDoc[] = await MongoDataAccessApi.aggregateStoredPipeline(
            params.collection, params.pipelineId, params.params
        )

        const results: IDBHicpEstatData[] = []
        docs.forEach(doc => {
            // remove geo from full estat code to match HICP definition, e.g. A.IGD_NNRG_SD.BE => A.IGD_NNRG_SD.
            const dims = doc._id.split('.')
            dims[dims.length - 1] = '' // remove country
            const estatCode = dims.join('.')

            const indicator: IDBHicpEstat = estatMap[estatCode]
            if (indicator) {
                const startDate = new Date(doc.timestamp[0])
                const indData: IDBHicpEstatData = Object.assign({
                    START_YEAR: startDate.getFullYear(),
                    TIMESERIE_DATA: doc.values.join(','),
                    LAST_UPDATED: doc.last_update ? new Date(doc.last_update) : undefined,
                }, indicator)

                if (dataType === 'I' || dataType === 'T') {
                    // add missing periods at the beginning for monthly data
                    if (startDate.getMonth() > 0) {
                        indData.TIMESERIE_DATA = Array.from(
                            { length: startDate.getMonth() + 1 }, () => ''
                        ).join(',') + indData.TIMESERIE_DATA
                    }
                }
                results.push(indData)
            }
        })

        return results
    }

    /**********************************************************************************************
     * @method getHicpDataWithWeights
     *********************************************************************************************/
    private async getHicpDataWithWeights(
        dataset: HicpDataset, countryId: string, indicatorIds?: string[]
    ): Promise<IDBHicpEstatData[]> {
        const dataType: IDBDataType = dataset === HicpDataset.CONSTANT_TAX_RATES ? 'T' : 'I'
        return Promise.all([
            this.getHicpData('W', countryId, indicatorIds),
            this.getHicpData(dataType, countryId, indicatorIds),
        ]).then(([weights, indicators]) => [].concat(weights).concat(indicators))
    }

    /**********************************************************************************************
     * @method getEstatMap
     *********************************************************************************************/
    private async getEstatMap(dataType: IDBDataType): Promise<IEstatToIndicatorMap> {
        if (!this._estatMap.has(dataType)) {
            const eurostatCodes: IDBHicpEstat[] = await this.getIndicators(dataType)

            const estatMap: IEstatToIndicatorMap = eurostatCodes.reduce((acc, value) =>
                (acc[`${value.EUROSTAT_CODE.split('|')[1]}`] = value, acc), {})
            this._estatMap.set(dataType, estatMap)
        }

        return this._estatMap.get(dataType)
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    private async getIndicators(dataType: IDBDataType): Promise<IDBHicpEstat[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_data_type', type: STRING, dir: BIND_IN, value: dataType },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        return DataAccessApi.execSP('auxtools_hicp.getIndicators', options).then(dbResult => dbResult.o_cur)
    }

    /**********************************************************************************************
     * @method getPipelineParams
     *********************************************************************************************/
    private getPipelineParams(
        dataType: IDBDataType, countryId: string, eurostatCodes: string[]
    ): IHicpPipelineParams {
        switch (dataType) {
            case 'I': return this.getIndexPipelineParams(HicpMongoService.INDEX_COLLECTION, countryId, eurostatCodes)
            case 'T': return this.getIndexPipelineParams(HicpMongoService.TAX_RATE_COLLECTION, countryId, eurostatCodes)
            case 'W': return this.getWeightsPipelineParams(countryId, eurostatCodes)
            default: throw Error(`Cannot prepare pipeline parameters, unknown data type: ${dataType}!`)
        }
    }

    /**********************************************************************************************
     * @method getIndexPipelineParams
     * Hicp index eurostat dimentions: freq.unit.coicop.geo, where geo is always empty
     *********************************************************************************************/
    private getIndexPipelineParams(collection: string, countryId: string, eurostatCodes: string[]): IHicpPipelineParams {

        const units = new Set<string>()
        const coicops = new Set<string>()
        eurostatCodes.forEach(code => {
            // eslint-disable-next-line @typescript-eslint/no-unused-vars
            const [freq, unit, coicop, ...rest] = code.split('.')
            units.add(unit)
            coicops.add(coicop)
        })

        return {
            collection,
            pipelineId: 'hicp.get_index_data',
            params: {
                'p_country_id': countryId,
                'p_units': Array.from(units.values()),
                'p_coicops': Array.from(coicops.values()),
            },
        }
    }

    /**********************************************************************************************
     * @method getWeightsPipelineParams
     * Hicp index eurostat dimentions: freq.coicop.geo, where geo is always empty
     *********************************************************************************************/
    private getWeightsPipelineParams(countryId: string, eurostatCodes: string[]): IHicpPipelineParams {

        const coicops = new Set<string>()
        eurostatCodes.forEach(code => {
            // eslint-disable-next-line @typescript-eslint/no-unused-vars
            const [freq, coicop, ...rest] = code.split('.')
            coicops.add(coicop)
        })

        return {
            collection: HicpMongoService.WEIGHT_COLLECTION,
            pipelineId: 'hicp.get_weights_data',
            params: {
                'p_country_id': countryId,
                'p_coicops': Array.from(coicops.values()),
            },
        }
    }

    /**********************************************************************************************
     * @method getCountryCodes
     *********************************************************************************************/
    private async getCountryCodes(): Promise<string[]> {
        return MongoDataAccessApi.distinct('PRC_HICP_MIDX', 'dimensions.geo').then(
            docs => docs.map(doc => doc.toString())
        )
    }

    /**********************************************************************************************
     * @method getCountryDescription
     *********************************************************************************************/
    private getCountryDescription(country: ICountry): string {
        switch (country.COUNTRY_ID) {
            case 'EU28': return 'EU28 [discontinued]'
            case 'EU': return 'EU [EU27]'
            default: return country.DESCR
        }
    }

    /**********************************************************************************************
     * @method getHicpCountries
     *********************************************************************************************/
    private async getHicpCountries(countryIds: string[]): Promise<IHicpCountry[]> {
        const key = countryIds.sort().join('_')

        if (!this._countries.has(key)) {
            this._countries.set(
                key,
                await DashboardApi.getCountries(countryIds).then(
                    countries => countries.map(country => ({
                        countryId: country.COUNTRY_ID,
                        descr: this.getCountryDescription(country),
                    }))
                )
            )
        }

        return this._countries.get(key)
    }

}
