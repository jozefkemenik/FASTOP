import * as XLSX from 'xlsx'

import { BIND_IN, BIND_OUT, CLOBLIST, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import {
    IDBEerCountry,
    IDBEerGeoGroup,
    IDBEerIndicatorData,
    IDBProviderUpload,
    IDBPublicationEertData,
    IDBPublicationGeoArea,
    IDBPublicationWeightData,
} from '.'
import { IEerMatrixData, IXlsxSheet } from './shared-interfaces'
import { DataAccessApi } from '../../../lib/dist/api'

export class EerService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isCalculated
     *********************************************************************************************/
    public async isCalculated(providerId: string): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_getters.isCalculated', options)
        return dbResult.o_res > 0
    }

    /**********************************************************************************************
     * @method getUploads
     *********************************************************************************************/
    public async getUploads(): Promise<IDBProviderUpload[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_upload.getUploads', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getProviderUpload
     *********************************************************************************************/
    public async getProviderUpload(providerId: string): Promise<IDBProviderUpload> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_upload.getProviderUpload', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getProviderIndicatorData
     *********************************************************************************************/
    public async getProviderIndicatorData(
        providerId: string,
        group: string,
        periodicity: string,
    ): Promise<IDBEerIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'p_group_id', type: STRING, dir: BIND_IN, value: group },
                { name: 'p_periodicity_id', type: STRING, dir: BIND_IN, value: periodicity },
            ],
            fetchInfo: {
                timeserieData: { type: STRING },
            },
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_indicator.getIndicatorData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getNeerCountries
     *********************************************************************************************/
    public async getNeerCountries(): Promise<IDBEerCountry[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_getters.getNeerCountries', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method uploadIndicatorData
     *********************************************************************************************/
    public async uploadIndicatorData(
        providerId: string,
        indicatorId: string,
        periodicityId: string,
        geoGrpId: string,
        startYear: number,
        countries: string[],
        timeseries: string[],
        user: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'p_indicator_id', type: STRING, dir: BIND_IN, value: indicatorId },
                { name: 'p_periodicity_id', type: STRING, dir: BIND_IN, value: periodicityId },
                { name: 'p_start_year', type: NUMBER, dir: BIND_IN, value: startYear },
                { name: 'p_country_ids', type: STRING, dir: BIND_IN, value: countries },
                { name: 'p_time_series', type: CLOBLIST, dir: BIND_IN, value: timeseries },
                { name: 'p_geo_grp_id', type: STRING, dir: BIND_IN, value: geoGrpId },
                { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_upload.setIndicatorData', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method uploadMatrixData
     *********************************************************************************************/
    public async uploadMatrixData(
        providerId: string,
        year: number,
        importers: string[],
        exporters: string[],
        geoGrpId: string,
        values: string[],
        user: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                { name: 'p_importers', type: STRING, dir: BIND_IN, value: importers },
                { name: 'p_exporters', type: STRING, dir: BIND_IN, value: exporters },
                { name: 'p_values', type: STRING, dir: BIND_IN, value: values },
                { name: 'p_geo_grp_id', type: STRING, dir: BIND_IN, value: geoGrpId },
                { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_upload.setMatrixData', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getProviderMatrixData
     *********************************************************************************************/
    public async getProviderMatrixData(providerId: string, group: string, years: number[]): Promise<IEerMatrixData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'p_group_id', type: STRING, dir: BIND_IN, value: group },
                { name: 'p_years', type: NUMBER, dir: BIND_IN, value: years || [] },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_matrix.getMatrixData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method setDataUploads
     *********************************************************************************************/
    public async setDataUploads(providerId: string, user: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_upload.setDataUpload', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getGeoGroups
     *********************************************************************************************/
    public async getGeoGroups(activeOnly: boolean): Promise<IDBEerGeoGroup[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_active_only', type: NUMBER, dir: BIND_IN, value: Number(activeOnly) },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_getters.getEerGeoGroups', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getMatrixYears
     *********************************************************************************************/
    public async getMatrixYears(providerId: string): Promise<number[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_provider_id', type: STRING, dir: BIND_IN, value: providerId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true,
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_matrix.getMatrixYears', options)
        return dbResult.o_cur.flat()
    }

    /**********************************************************************************************
     * @method makeExcel
     *********************************************************************************************/
    public makeExcel(sheets: IXlsxSheet[]): Buffer {
        const sheetNames = sheets.map(sheet => sheet.name)
        const xlsSheets: { [sheet: string]: XLSX.Sheet } = sheets.reduce(
            (acc, { name, rows, header }) => ((acc[name] = XLSX.utils.json_to_sheet(rows, { header })), acc),
            {},
        )
        const workbook = { Sheets: xlsSheets, SheetNames: sheetNames }
        return XLSX.write(workbook, { bookType: 'xlsx', type: 'buffer' })
    }

    /**********************************************************************************************
     * @method getPublicationWeightData
     *********************************************************************************************/
    public async getPublicationWeightData(): Promise<IDBPublicationWeightData[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_publication.getWeights', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getPublicationReerData
     *********************************************************************************************/
    public async getPublicationReerData(): Promise<IDBPublicationEertData[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            fetchInfo: {
                timeserieData: { type: STRING },
            },
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_publication.getReer', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getPublicationNeerData
     *********************************************************************************************/
    public async getPublicationNeerData(): Promise<IDBPublicationEertData[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
            fetchInfo: {
                timeserieData: { type: STRING },
            },
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_publication.getNeer', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getPublicationEerGeoColumns
     *********************************************************************************************/
    public async getPublicationEerGeoColumns(): Promise<IDBPublicationGeoArea[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_publication.getEerGeoColumns', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getPublicationWeightGeoColumns
     *********************************************************************************************/
    public async getPublicationWeightGeoColumns(): Promise<IDBPublicationGeoArea[]> {
        const options: ISPOptions = {
            params: [{ name: 'o_cur', type: CURSOR, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_publication.getWeightGeoColumns', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getBaseYear
     *********************************************************************************************/
    public async getBaseYear(): Promise<number> {
        const options: ISPOptions = {
            params: [{ name: 'o_res', type: NUMBER, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_getters.getBaseYear', options)
        return dbResult.o_res
    }

     /**********************************************************************************************
     * @method getBaseYear
     *********************************************************************************************/
     public async setBaseYear(year:number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_year', type: NUMBER, dir: BIND_IN, value: year },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT }],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_eer_getters.setBaseYear', options)
        return dbResult.o_res
    }
}
