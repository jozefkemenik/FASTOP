import { BIND_OUT, CURSOR, DATE, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'

import { IDBSpiIndicator, IDBSpiMatrixData } from '.'
import { IDictionary } from './shared-interfaces'

export class SpiService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public constructor(private dbService: DbService<DbProviderService>) {
    }

    // cache
    private _countries: IDictionary
    private _products: IDictionary
    private _industries: IDictionary

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getMatrixData
     *********************************************************************************************/
    public async getMatrixData(
        indicator: string, countries: string[], products: string[],
        years: string[], startYear: number, endYear: number
    ): Promise<IDBSpiMatrixData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_indicator_id', type: STRING, value: indicator },
                { name: 'p_country_ids', type: STRING, value: countries },
                { name: 'p_products_ids', type: STRING, value: products },
                { name: 'p_years', type: STRING, value: years || [] },
                { name: 'p_start_year', type: NUMBER, value: startYear || -1 },
                { name: 'p_end_year', type: NUMBER, value: endYear || 9999 },
            ],
        }

        const dbResult = await this.execSP(`core_indicator.getMatrix`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(
        domain: string, indicators: string[], countries: string[],
        nomenclatureCodes: string[], nomenclature: string, destors: string[]
    ): Promise<IDBSpiIndicator[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_indicator_ids', type: STRING, value: indicators },
                { name: 'p_country_ids', type: STRING, value: countries },
                { name: 'p_destor_ids', type: STRING, value: destors },
                { name: 'p_nomenclature_codes', type: STRING, value: nomenclatureCodes },
                { name: 'p_nomenclature', type: STRING, value: nomenclature },
            ],
        }

        const dbResult = await this.execSP(`core_indicator.getIndicators${domain.toUpperCase()}`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getIndicatorDownloadDate
     *********************************************************************************************/
    public async getIndicatorDownloadDate(domain: string): Promise<Date> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: DATE, dir: BIND_OUT },
                { name: 'p_domain', type: STRING, value: domain },
            ],
        }
        const dbResult = await this.execSP('core_indicator.getIndicatorDownloadDate', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(): Promise<IDictionary> {
        if (!this._countries) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }

            const dbResult = await this.execSP(`core_commons.getCountries`, options)
            this._countries = this.convertToDictionary(dbResult.o_cur)
        }
        return this._countries
    }

    /**********************************************************************************************
     * @method getProducts
     *********************************************************************************************/
    public async getProducts(): Promise<IDictionary> {
        if (!this._products) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }

            const dbResult = await this.execSP(`core_commons.getProducts`, options)
            this._products = this.convertToDictionary(dbResult.o_cur)
        }
        return this._products
    }

    /**********************************************************************************************
     * @method getIndustries
     *********************************************************************************************/
    public async getIndustries(): Promise<IDictionary> {
        if (!this._industries) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }

            const dbResult = await this.execSP(`core_commons.getIndustries`, options)
            this._industries = this.convertToDictionary(dbResult.o_cur)
        }
        return this._industries
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method execSP
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private execSP(sp: string, options: ISPOptions): Promise<any> {
        return this.dbService.storedProc(sp, options)
    }

    /**********************************************************************************************
     * @method convertToDictionary
     *********************************************************************************************/
    private convertToDictionary(dbData: IDBDictionary[]): IDictionary {
        return dbData.reduce((acc, value) => {
            acc[value.CODE] = value.LABEL
            return acc
        }, {})

    }
}

interface IDBDictionary {
    CODE: string
    LABEL: string
}
