import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { CacheMap, Level, LoggingService, VectorService } from '../../../lib/dist'
import { DashboardApi, DataAccessApi } from '../../../lib/dist/api'
import { ICompressedColumn, ICompressedData, IDBRaw, IIndicatorData, RawValue } from '../report/shared-interfaces'
import { ICountry, IDBCountry } from '../../../lib/dist/menu'
import {
    IDBIndicatorData,
    ITempDictionary,
} from '../report'
import { EApps } from 'config'
import { ForecastType } from '../../../fdms/src/forecast/shared-interfaces'
import { IRoundInfo } from '../../../dashboard/src/config/shared-interfaces'
import { IRoundStorage } from './shared-interfaces'


export class SharedService {

    public static cc(name: string, decompressed?: boolean, timeserie?: boolean): ICompressedColumn {
        return { name, dictionary: !decompressed ? [] : undefined, timeserie }
    }

    // do not change the order! it has to match order of columns returned by FDMS_INDICATOR.getProvidersIndicatorData
    private static INDICATOR_DATA_COMPRESSED_COLUMNS = [
        SharedService.cc('COUNTRY_ID'),                 SharedService.cc('INDICATOR_ID'),
        SharedService.cc('SCALE_ID'),                   SharedService.cc('START_YEAR'),
        SharedService.cc('TIMESERIE_DATA', true, true), SharedService.cc('PERIODICITY_ID'),
        SharedService.cc('COUNTRY_DESCR'),              SharedService.cc('SCALE_DESCR'),
        SharedService.cc('UPDATE_DATE', true),          SharedService.cc('DATA_SOURCE')
    ]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private _currencies = new CacheMap<string, string>()
    private _countries: CacheMap<string, IDBCountry> = new CacheMap<string, IDBCountry>()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(private logs: LoggingService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCurrentRoundInfo
     *********************************************************************************************/
    public async getCurrentRoundInfo(appId: EApps): Promise<IRoundInfo> {
        return DashboardApi.getCurrentRoundInfo(appId)
    }

    /**********************************************************************************************
     * @method getCountry
     *********************************************************************************************/
    public async getCountry(countryId: string): Promise<ICountry> {
        if (!this._countries.has(countryId)) {
            this._countries.set(countryId, await DashboardApi.getCountry(countryId))
        }
        return this._countries.get(countryId)
    }

    /**********************************************************************************************
     * @method getProvidersIndicatorData
     *********************************************************************************************/
    public async getProvidersIndicatorData(
        providerIds: string[],
        countryIds?: string[],
        indicatorIds?: string[],
        periodicityId?: string,
        ogFull?: boolean,
        roundSid?: number,
        storageSid?: number,
        custTextSid?: number,
    ): Promise<IDBIndicatorData[]> {

        const getData = (indicators: string[]) => this.getProvidersIndicatorDataInternal(
            providerIds, countryIds, indicators, periodicityId, ogFull, roundSid, storageSid, custTextSid
        )

        return this.batchRequests(indicatorIds, getData.bind(this))
    }

    /**********************************************************************************************
     * @method getProvidersIndicatorDataArray
     *********************************************************************************************/
    public async getProvidersIndicatorDataArray(
        providerIds: string[],
        countryIds?: string[],
        indicatorIds?: string[],
        periodicityId?: string,
        ogFull?: boolean,
        roundSid?: number,
        storageSid?: number,
        custTextSid?: number,
    ): Promise<IDBRaw[]> {

        const getData = (indicators: string[]) => this.getProvidersIndicatorDataInternal(
            providerIds, countryIds, indicators, periodicityId, ogFull, roundSid, storageSid, custTextSid, true
        )

        return this.batchRequests(indicatorIds, getData.bind(this))
    }

     /**********************************************************************************************
     * @method getProvidersIndicatorDataByKeys
      * All keys must have the same frequency!
     *********************************************************************************************/
     public async getProvidersIndicatorDataByKeys(
         providerIds: string[],
         keys: string[],
         roundSid: number,
         storageSid: number,
         custTextSid: number,
         compress: boolean,
    ): Promise<ICompressedData | IIndicatorData[]> {

         // validate frequency
         const parsedKeys: IParsedKey[] = keys.map(key => this.parseIndicatorKey(key))
         let commonFreq: string = undefined
         /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
         parsedKeys.forEach(([cty, freq, ...res]) => {
             if (!commonFreq) commonFreq = freq
             else if (commonFreq !== freq) throw Error('Cannot mix frequencies when reading indicator data by keys!')
         })

         return Promise.all(
             parsedKeys
                 .map(([countryIds, periodicity, codes, trns, aggs, units, refs]) =>
                     this.getProvidersIndicatorDataInternal(
                         providerIds, countryIds, null, periodicity, null, roundSid, storageSid, custTextSid, true,
                         codes, trns, aggs, units, refs,
                     )
                 )
         ).then(rawResults => {
             const uniqueResults = this.getUniqueIndicatorData(rawResults?.flat())
             return compress ? this.compress(SharedService.INDICATOR_DATA_COMPRESSED_COLUMNS, uniqueResults)
                             : SharedService.indicatorsDataVectorToArray(this.rawIndicatorsToIndicatorData(uniqueResults))
         })
    }

    /**********************************************************************************************
     * @method getCompressedIndicatorsData
     *********************************************************************************************/
    public async getCompressedIndicatorsData(
        providerIds: string[], countryIds: string[], indicatorIds: string[],
        periodicityId: string, roundSid: number, storageSid: number, custTextSid: number, compress?: boolean
    ): Promise<ICompressedData | IIndicatorData[]> {
        return compress ? this.getProvidersIndicatorDataArray(
                providerIds, countryIds, indicatorIds, periodicityId, null, roundSid, storageSid, custTextSid
            ).then(data => this.compress(SharedService.INDICATOR_DATA_COMPRESSED_COLUMNS, data))
            : this.getProvidersIndicatorData(
                providerIds, countryIds, indicatorIds, periodicityId, null, roundSid, storageSid, custTextSid
            ).then(SharedService.indicatorsDataVectorToArray)
    }

    /**********************************************************************************************
     * @method indicatorsDataVectorToArray
     *********************************************************************************************/
    public static indicatorsDataVectorToArray(data: IDBIndicatorData[]): IIndicatorData[] {
        return data?.map(({TIMESERIE_DATA, ...rest}) => ({
            TIMESERIE_DATA: VectorService.stringToVector(TIMESERIE_DATA),
            ...rest
        }))
    }

    /**********************************************************************************************
     * @method isOgFull
     *********************************************************************************************/
     public async isOgFull(
        countryId: string, roundSid: number, storageSid: number
    ): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_indicator.isOgFull', options)
        return Boolean(dbResult.o_res)
    }

    /**********************************************************************************************
     * @method getTceData
     *********************************************************************************************/
    public async getTceData(
        countryIds?: string[],
        indicatorIds?: string[],
        partnerIds?: string[],
        periodicityId?: string,
        roundSid?: number,
        storageSid?: number,
    ): Promise<IDBIndicatorData[]> {
        return this.getTceDataInternal(
            countryIds, indicatorIds, partnerIds, periodicityId, roundSid, storageSid
        ).then(raw => raw as IDBIndicatorData[])
    }

    /**********************************************************************************************
     * @method getTceDataArray
     *********************************************************************************************/
    public async getTceDataArray(
        countryIds?: string[],
        indicatorIds?: string[],
        partnerIds?: string[],
        periodicityId?: string,
        roundSid?: number,
        storageSid?: number,
    ): Promise<IDBRaw[]> {
        return this.getTceDataInternal(
            countryIds, indicatorIds, partnerIds, periodicityId, roundSid, storageSid, true
        ).then(raw => raw as IDBRaw[])
    }

    /**********************************************************************************************
     * @method compress
     *********************************************************************************************/
    public compress(columns: ICompressedColumn[], rawData: IDBRaw[]): ICompressedData {
        // build dictionary
        const tempDict: ITempDictionary = {}
        for (const row of rawData) {
            columns.forEach((col, index) => {
                if (col.dictionary) {
                    const data = row[index]
                    if (!tempDict[index]) tempDict[index] = { set: new Set<RawValue>(), reverse: new Map<RawValue, number>() }
                    tempDict[index].set.add(data)
                }
            })
        }

        // sort dictionaries + create reverse map
        columns.forEach( (col, index) => {
            if (tempDict[index]) {
                const values = Array.from(tempDict[index].set.values())
                values.sort()
                col.dictionary = values
                values.forEach((val, valIndex) => tempDict[index].reverse.set(val, valIndex))
            }
        })

        // compress data
        return {
            columns,
            data: rawData.map(row => row.map((v, index) => tempDict[index] ? tempDict[index].reverse.get(v) : v))
        }
    }

    /**********************************************************************************************
     * @method getTceTradeItemsDataArray
     *********************************************************************************************/
    public async getTceTradeItemsDataArray(
        countryIds: string[],
        tradeItemIds: string[],
        periodicityId: string,
        roundSid?: number,
        storageSid?: number,
    ): Promise<IDBRaw[]> {
        return this.getTceTradeItemsDataInternal(
            countryIds, tradeItemIds, periodicityId, roundSid, storageSid, true
        ).then(raw => raw as IDBRaw[])
    }

    /**********************************************************************************************
     * @method getTceTradeItemsData
     *********************************************************************************************/
    public async getTceTradeItemsData(
        countryIds: string[],
        tradeItemIds: string[],
        periodicityId: string,
        roundSid?: number,
        storageSid?: number,
    ): Promise<IDBIndicatorData[]> {
        return this.getTceTradeItemsDataInternal(
            countryIds, tradeItemIds, periodicityId, roundSid, storageSid
        ).then(raw => raw as IDBIndicatorData[])
    }

    /**********************************************************************************************
     * @method getCurrency
     *********************************************************************************************/
    public async getCurrency(geoAreaId: string, defaultCurrency = 'EUR'): Promise<string> {
        if (!this._currencies.has(geoAreaId)) {
            const options: ISPOptions = {
                params: [
                    { name: 'p_geo_area_id', type: STRING, value: geoAreaId },
                    { name: 'o_currency', type: STRING, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('core_getters.getCurrency', options)
            this._currencies.set(geoAreaId, dbResult.o_currency || defaultCurrency)
        }

        return this._currencies.get(geoAreaId)
    }

    /**********************************************************************************************
     * @method getForecastRoundAndStorage
     *********************************************************************************************/
    public async getForecastRoundAndStorage(forecastType: ForecastType): Promise<IRoundStorage> {
        const options: ISPOptions = {
            params: [
                { name: 'p_forecast_id', type: STRING, value: forecastType },
                { name: 'o_round', type: NUMBER, dir: BIND_OUT },
                { name: 'o_storage', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_forecast.getRoundAndStorage', options)
        return {
            roundSid: dbResult.o_round,
            storageSid: dbResult.o_storage
        }
    }

    /**********************************************************************************************
     * @method markForecast
     *********************************************************************************************/
    public async markForecast(forecastType: ForecastType, user: string) {
        await this.setForecastRoundAndStorage(forecastType, user).then(
            (res) => {
                if (res) {
                    this.logs.log(
                        `Marked current round and storage as ${forecastType} forecast`,
                        Level.INFO
                    )
                } else {
                    this.logs.log(
                        `Failed marking current round and storage as ${forecastType} forecast`,
                        Level.WARNING
                    )
                }
            },
            (err) => {
                this.logs.log(
                    `Error while marking current round and storage as ${forecastType} forecast: ${err.toString()}`,
                    Level.ERROR
                )
                throw err
            }
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getChunks
     *********************************************************************************************/
    private getChunks(data: string[]): Array<string[]> {
        if (!data?.length) return [[]]
        const chunkSize = 500
        const chunks = []
        for (let i = 0; i < data.length; i += chunkSize) {
            chunks.push(data.slice(i, i + chunkSize))
        }
        return chunks
    }

    /**********************************************************************************************
     * @method batchRequests
     *********************************************************************************************/
    private async batchRequests<T>(indicators: string[], dataGetter: DataGetter<T>): Promise<T[]> {
        return Promise.all(this.getChunks(indicators).map(dataGetter)).then(results => results.flat())
    }

    /**********************************************************************************************
     * @method getProvidersIndicatorDataInternal
     *********************************************************************************************/
    private async getProvidersIndicatorDataInternal(
        providerIds: string[],
        countryIds?: string[],
        indicatorIds?: string[],
        periodicityId?: string,
        ogFull?: boolean,
        roundSid?: number,
        storageSid?: number,
        custTextSid?: number,
        arrayFormat?: boolean,
        codes?: string[],
        trns?: string[],
        aggs?: string[],
        units?: string[],
        refs?: string[]
    ): Promise<IDBRaw[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_ids', type: STRING, value: providerIds ?? [] },
                { name: 'p_country_ids', type: STRING, value: countryIds ?? [] },
                { name: 'p_indicator_ids', type: STRING, value: indicatorIds ?? [] },
                { name: 'p_og_full', type: NUMBER, value: ogFull ? 1 : null },
                { name: 'p_periodicity_id', type: STRING, value: periodicityId ?? 'A' },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
                { name: 'p_cust_text_sid', type: NUMBER, value: custTextSid ?? null },
                { name: 'p_codes', type: STRING, value: codes ?? [] },
                { name: 'p_trns', type: STRING, value: trns ?? [] },
                { name: 'p_aggs', type: STRING, value: aggs ?? [] },
                { name: 'p_units', type: STRING, value: units ?? [] },
                { name: 'p_refs', type: STRING, value: refs ?? [] },

            ],
            arrayFormat
        }
        const dbResult = await DataAccessApi.execSP('fdms_indicator.getProvidersIndicatorData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTceDataInternal
     *********************************************************************************************/
    private async getTceDataInternal(
        countryIds?: string[],
        indicatorIds?: string[],
        partnerIds?: string[],
        periodicityId?: string,
        roundSid?: number,
        storageSid?: number,
        arrayFormat?: boolean,
    ): Promise<IDBRaw[] | IDBIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_ids', type: STRING, value: countryIds ?? [] },
                { name: 'p_indicator_ids', type: STRING, value: indicatorIds ?? [] },
                { name: 'p_partner_ids', type: STRING, value: partnerIds ?? [] },
                { name: 'p_periodicity_id', type: STRING, value: periodicityId ?? 'A' },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
            ],
            arrayFormat,
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTCEIndicatorData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTceTradeItemsDataInternal
     *********************************************************************************************/
    private async getTceTradeItemsDataInternal(
        countryIds: string[],
        tradeItemIds: string[],
        periodicityId: string,
        roundSid?: number,
        storageSid?: number,
        arrayFormat?: boolean,
    ): Promise<IDBRaw[] | IDBIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_ids', type: STRING, value: countryIds ?? [] },
                { name: 'p_tradeItem_ids', type: STRING, value: tradeItemIds ?? [] },
                { name: 'p_periodicity_id', type: STRING, value: periodicityId ?? 'A' },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
            ],
            arrayFormat,
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTCETradeItemData', options)
        return dbResult.o_cur
    }


    /**********************************************************************************************
     * @method getUniqueIndicatorData
     *********************************************************************************************/
    private getUniqueIndicatorData(raw: IDBRaw[]): IDBRaw[] {
        // group by country_id and indicator_id
        const ctyIndex = SharedService.INDICATOR_DATA_COMPRESSED_COLUMNS.findIndex(col => col.name === 'COUNTRY_ID')
        const indicatorIndex = SharedService.INDICATOR_DATA_COMPRESSED_COLUMNS.findIndex(col => col.name === 'INDICATOR_ID')

        const keys = new Set<string>()

        return raw.reduce((acc, value) => {
            const key = `${value[ctyIndex]}_${value[indicatorIndex]}`
            if (!keys.has(key)) {
                acc.push(value)
                keys.add(key)
            }

            return acc
        }, [] as IDBRaw[])
    }

    /**********************************************************************************************
     * @method rawIndicatorsToIndicatorData
     * Convert raw array values into objects
     *********************************************************************************************/
    private rawIndicatorsToIndicatorData(raws: IDBRaw[]): IDBIndicatorData[] {
        return raws.map(
            raw => SharedService.INDICATOR_DATA_COMPRESSED_COLUMNS.reduce((acc, col, index) => {
                acc[col.name] = raw[index]
                return acc
            }, {
                COUNTRY_ID: undefined,
                INDICATOR_ID: undefined,
                SCALE_ID: undefined,
                START_YEAR: undefined,
                TIMESERIE_DATA: undefined,
                PERIODICITY_ID: undefined,
                COUNTRY_DESCR: undefined,
                SCALE_DESCR: undefined,
                UPDATE_DATE: undefined,
                DATA_SOURCE: undefined,
            })
        )
    }

    /**********************************************************************************************
     * @method parseIndicatorKey
     * key can be in short format: <cty>.<code>.<freq>
     *     or in the full format: <cty>.<code>.<trn>.<agg>.<unit>.<ref>.<freq>
     * Each value (except frequency) can contain list of values (separated with +)
     * e.g. PL+BE.UVDG.1.0.0.319+123.A
     *********************************************************************************************/
    private parseIndicatorKey(key: string): IParsedKey {
        const countries: string[] = []
        const codes: string[] = []
        const trns: string[] = []
        const aggs: string[] = []
        const units: string[] = []
        const refs: string[] = []

        const values = (dim: string) => dim?.split('+').map(t => t?.trim()) || []

        const dimensions = key.split('.')
        if (dimensions.length > 2) {
            countries.push(...values(dimensions[0]))
            codes.push(...values(dimensions[1]))
        }

        if (dimensions.length === 7) {
            trns.push(...values(dimensions[2]))
            aggs.push(...values(dimensions[3]))
            units.push(...values(dimensions[4]))
            refs.push(...values(dimensions[5]))
        }

        return [countries, dimensions[dimensions.length - 1] || 'A', codes, trns, aggs, units, refs]
    }

    /**********************************************************************************************
     * @method setForecastRoundAndStorage
     *********************************************************************************************/
    private async setForecastRoundAndStorage(forecastType: ForecastType, user: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_forecast_id', type: STRING, value: forecastType },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        return DataAccessApi.execSP(
            `fdms_forecast.setRoundAndStorage`, options
        ).then(dbResult => dbResult.o_res)
    }
}

type DataGetter<T> = (params: string[]) => Promise<T[]>

// [countryIds, periodicity, codes, trns, aggs, units, refs]
type IParsedKey = [string[], string, string[], string[], string[], string[], string[]]
