import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../../lib/dist/db'
import { ICompressedData, ICountryTable, IIndicatorData, ITableRow } from '../shared-interfaces'
import { IDBTceMatrixData, IDBTcePartner, IDBTceReportDefinition, IDBTceResult, IDBTceTradeItem } from '.'
import { DataAccessApi } from '../../../../lib/dist/api'
import { EApps } from 'config'
import { ICountry } from '../../../../lib/dist/menu'
import { SharedService } from '../../shared/shared.service'


export class TceService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static TCE_DATA_COMPRESSED_COLUMNS = [
        SharedService.cc('COUNTRY_ID'),                 SharedService.cc('INDICATOR_ID'),
        SharedService.cc('SCALE_ID'),                   SharedService.cc('START_YEAR'),
        SharedService.cc('TIMESERIE_DATA', true, true), SharedService.cc('PERIODICITY_ID'),
        SharedService.cc('COUNTRY_DESCR'),              SharedService.cc('SCALE_DESCR'),
        SharedService.cc('UPDATE_DATE', true),          SharedService.cc('DATA_SOURCE'),
        SharedService.cc('DATA_TYPE')
    ]

    private static readonly TCE_YEARS = 3

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly sharedService: SharedService,
    ) {}


    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTceResultsCountries
     *********************************************************************************************/
    public async getTceResultsCountries(roundSid?: number, storageSid?: number, ): Promise<ICountry[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTceResultsCountries', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getPartners
     *********************************************************************************************/
    public async getPartners(): Promise<IDBTcePartner[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTcePartners', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTradeItems
     *********************************************************************************************/
    public async getTradeItems(): Promise<IDBTceTradeItem[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTceTradeItems', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getMatrixData
     *********************************************************************************************/
    public async getMatrixData(
        providerId: string, roundSid?: number, storageSid?: number,
    ): Promise<IDBTceMatrixData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, value: providerId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid ?? null },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid ?? null },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTceMatrixData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTceCountryTable
     *********************************************************************************************/
    public async getTceCountryTable(
        roundSid: number,
        storageSid: number,
        countryId: string
    ): Promise<ICountryTable> {
        const [roundInfo, country, reportDef, tceResults, currency] = await Promise.all([
            this.sharedService.getCurrentRoundInfo(this.appId),
            this.sharedService.getCountry(countryId),
            this.getTceReportDefinition(),
            this.getTceResults(roundSid, storageSid, countryId),
            this.sharedService.getCurrency(countryId)
        ])

        const countryName = country.DESCR
        const years = TceService.TCE_YEARS
        const startYear = tceResults?.length ?
            tceResults[0].START_YEAR + tceResults[0].TIMESERIE_DATA.split(',').length - years :
            roundInfo.year

        return {
            header: [
                [
                    { header: 'index', colSpan: 1 },
                    { header: 'Trade in Goods', colSpan: years },
                    { header: 'Trade in Services', colSpan: years },
                    { header: 'Trade in Goods and Services', colSpan: years },
                ],
                Array.from({length: 3 * years}, (_, i) => ({ header: `${startYear + i % 3}`, colSpan: 1 }))
            ],
            data: this.getTceReportData(reportDef, tceResults, currency),
            dataColumnOffset: 1,
            tableNumber: null,
            title: `Consistency analysis of trade flows - ${countryName}`,
            footer: 'CD - Country Desk;\n' +
                'TP - Weighted Average of Trade Partners\' import volumes (= export markets) or export prices;'
        }
    }

    /**********************************************************************************************
     * @method getTceResults
     *********************************************************************************************/
    public async getTceResults(roundSid: number, storageSid: number, countryId: string): Promise<IDBTceResult[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: storageSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTceResults', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTceResultsData
     *********************************************************************************************/
    public async getTceResultsData(
        countryIds: string[], indicatorIds: string[], partnerIds: string[], periodicityId: string,
        roundSid: number, storageSid: number, compress?: boolean
    ): Promise<IIndicatorData[] | ICompressedData> {
        if (compress) {
            return this.sharedService.getTceDataArray(
                countryIds, indicatorIds, partnerIds, periodicityId, roundSid, storageSid
            ).then(
                data => this.sharedService.compress(TceService.TCE_DATA_COMPRESSED_COLUMNS, data)
            )
        } else {
            return this.sharedService.getTceData(
                countryIds, indicatorIds, partnerIds, periodicityId, roundSid, storageSid
            ).then(SharedService.indicatorsDataVectorToArray)
        }
    }

    /**********************************************************************************************
     * @method getTceTradeItemsData
     *********************************************************************************************/
    public async getTceTradeItemsData(
        countryIds: string[], tradeItemIds: string[], periodicityId: string,
        roundSid: number, storageSid: number, compress?: boolean
    ): Promise<IIndicatorData[] | ICompressedData> {
        if (compress) {
            return this.sharedService.getTceTradeItemsDataArray(
                countryIds, tradeItemIds, periodicityId, roundSid, storageSid
            ).then(
                data => this.sharedService.compress(TceService.TCE_DATA_COMPRESSED_COLUMNS, data)
            )
        } else {
            return this.sharedService.getTceTradeItemsData(
                countryIds, tradeItemIds, periodicityId, roundSid, storageSid
            ).then(SharedService.indicatorsDataVectorToArray)
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTceReportDefinition
     *********************************************************************************************/
    private async getTceReportDefinition(): Promise<IDBTceReportDefinition[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('fdms_tce.getTceReportDefinition', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTceReportData
     *********************************************************************************************/
    private getTceReportData(
        reportDef: IDBTceReportDefinition[],
        tceResults: IDBTceResult[],
        currency: string
    ): ITableRow[] {
        if (!reportDef || !reportDef.length) return []

        const resultsMap: {[keyId: string]: IDBTceResult} = tceResults?.reduce((acc, value) => {
            acc[value.KEY_ID] = value
            return acc
        }, {}) ?? {}

        return reportDef.map(row => row.DESCR
            ? { values: [row.DESCR.replace('{CURRENCY}', currency)]
                    .concat(this.getTceTimeSeries(resultsMap[row.GN_KEY_ID]))
                    .concat(this.getTceTimeSeries(resultsMap[row.SN_KEY_ID]))
                    .concat(this.getTceTimeSeries(resultsMap[row.GS_KEY_ID]))}
            : { values: [], rowType: 'HEADER', colSpans: [9] }
        )
    }

    /**********************************************************************************************
     * @method getTceTimeSeries
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private getTceTimeSeries(tceResult: IDBTceResult): any[] {
        const vector = tceResult ? tceResult.TIMESERIE_DATA.split(',').slice(-3) : []

        return Array(TceService.TCE_YEARS - vector.length).fill('')
            .concat(vector)
    }

}
