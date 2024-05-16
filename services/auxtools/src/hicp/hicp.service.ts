import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import {
    HicpDataset,
    IDBHicpCategory,
    IDBHicpCountry,
    IDBHicpIndicator,
    IDBHicpIndicatorCode,
    IDBHicpIndicatorData,
} from '.'
import { DataAccessApi } from '../../../lib/dist/api'


export class HicpService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorCodes
     *********************************************************************************************/
    public async getIndicatorCodes(): Promise<IDBHicpIndicatorCode[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getIndicatorCodes', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getExcelData
     * @deprecated use hicp.mongo.service
     *********************************************************************************************/
    public async getExcelData(
        dataset: HicpDataset, countryId: string, indicatorIds: string[]
    ): Promise<IDBHicpIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_dataset', type: STRING, dir: BIND_IN, value: dataset },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'p_indicator_ids', type: STRING, dir: BIND_IN, value: indicatorIds }
            ],
        }

        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getExcelDatasetData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(dataset: string, countryId: string): Promise<IDBHicpIndicatorData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_dataset', type: STRING, dir: BIND_IN, value: dataset },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getDatasetData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getUserCategories
     *********************************************************************************************/
    public async getUserCategories(user: string): Promise<IDBHicpCategory[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_user', type: STRING, dir: BIND_IN, value: user },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getUserCategories', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method createCategory
     *********************************************************************************************/
    public async createCategory(
        categoryId: string, descr: string, rootIndicatorId: string, baseIndicatorId: string,
        indicatorIds: string[], owner: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_category_id', type: STRING, dir: BIND_IN, value: categoryId },
                { name: 'p_descr', type: STRING, dir: BIND_IN, value: descr },
                { name: 'p_root_indicator_id', type: STRING, dir: BIND_IN, value: rootIndicatorId },
                { name: 'p_base_indicator_id', type: STRING, dir: BIND_IN, value: baseIndicatorId },
                { name: 'p_indicator_ids', type: STRING, dir: BIND_IN, value: indicatorIds },
                { name: 'p_owner', type: STRING, dir: BIND_IN, value: owner },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.insertCategory', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method updateCategory
     *********************************************************************************************/
    public async updateCategory(
        categorySid: number, categoryId: string, descr: string, rootIndicatorId: string, baseIndicatorId: string,
        indicatorIds: string[], owner: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_category_sid', type: NUMBER, dir: BIND_IN, value: categorySid },
                { name: 'p_category_id', type: STRING, dir: BIND_IN, value: categoryId },
                { name: 'p_descr', type: STRING, dir: BIND_IN, value: descr },
                { name: 'p_root_indicator_id', type: STRING, dir: BIND_IN, value: rootIndicatorId },
                { name: 'p_base_indicator_id', type: STRING, dir: BIND_IN, value: baseIndicatorId },
                { name: 'p_indicator_ids', type: STRING, dir: BIND_IN, value: indicatorIds },
                { name: 'p_owner', type: STRING, dir: BIND_IN, value: owner },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.updateCategory', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method deleteCategory
     *********************************************************************************************/
    public async deleteCategory(categorySid: number, owner: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_category_sid', type: NUMBER, dir: BIND_IN, value: categorySid },
                { name: 'p_owner', type: STRING, dir: BIND_IN, value: owner },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.deleteCategory', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountries
     * @deprecated use hicp.mongo.service
     *********************************************************************************************/
    public async getCountries(): Promise<IDBHicpCountry[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getCountries', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getAnomaliesStartYear
     *********************************************************************************************/
    public async getAnomaliesStartYear(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getAnomaliesStartYear', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getAnomaliesEndYear
     *********************************************************************************************/
    public async getAnomaliesEndYear(): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('auxtools_hicp.getAnomaliesEndYear', options)
        return dbResult.o_res
    }

}
