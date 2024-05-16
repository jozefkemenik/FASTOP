import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { DataAccessApi } from '../../../lib/dist/api'

import {
    IBaselineData,
    IBaselineUpload,
    IBaselineVariable,
    ICountryParam,
    ICountryParamsData,
    ICountryParamsUpload,
    IGeneralParamValue
} from '.'

export class UploadService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryGroupCountries
     *********************************************************************************************/
    public getCountryGroupCountries(geoAreaId: string): Promise<string[]> {
        return DashboardApi.getCountryGroupCountries(geoAreaId)
            .then((countries) => countries.map(c => c.COUNTRY_ID))
    }

    /**********************************************************************************************
     * @method getBaselineVariables
     *********************************************************************************************/
    public async getBaselineVariables(): Promise<IBaselineVariable[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getBaselineVariables', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getBaselineData
     *********************************************************************************************/
    public async getBaselineData(roundSid: number): Promise<IBaselineData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_country_ids', type: STRING, value: [] },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getBaselineData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method uploadBaselineData
     *********************************************************************************************/
    public async uploadBaselineData(roundSid: number, data: IBaselineUpload[]): Promise<number> {
        const params = data.reduce((acc, value) => {
            acc.variables.push(value.variableSid)
            acc.countries.push(value.countryId)
            acc.years.push(value.year)
            acc.values.push(value.value ?? '')
            return acc
        }, { variables: [], countries: [], years: [], values: []})

        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_variable_sids', type: NUMBER, dir: BIND_IN, value: params.variables },
                { name: 'p_country_ids', type: STRING, dir: BIND_IN, value: params.countries },
                { name: 'p_years', type: NUMBER, dir: BIND_IN, value: params.years },
                { name: 'p_values', type: STRING, dir: BIND_IN, value: params.values },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.uploadBaselineData', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method uploadCountryParameters
     *********************************************************************************************/
    public async uploadCountryParameters(roundSid: number, data: ICountryParamsUpload[]): Promise<number> {
        const params = data.reduce((acc, value) => {
            acc.parameters.push(value.paramSid)
            acc.countries.push(value.countryId)
            acc.values.push(value.value ?? '')
            return acc
        }, { parameters: [], countries: [], values: []})

        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_parameter_sids', type: NUMBER, dir: BIND_IN, value: params.parameters },
                { name: 'p_country_ids', type: STRING, dir: BIND_IN, value: params.countries },
                { name: 'p_values', type: STRING, dir: BIND_IN, value: params.values },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.uploadCountryParameters', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountryParams
     *********************************************************************************************/
    public async getCountryParams(): Promise<ICountryParam[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getCountryParams', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCountryParamsData
     *********************************************************************************************/
    public async getCountryParamsData(roundSid: number): Promise<ICountryParamsData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_country_ids', type: STRING, value: [] },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getCountryParamsData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getOutputGapParameter
     *********************************************************************************************/
    public async getOutputGapParameter(roundSid: number, paramId: string): Promise<string> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_parameter_id', type: STRING, value: paramId },
                { name: 'o_res', type: STRING, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getParameter', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method updateOutputGapParameter
     *********************************************************************************************/
    public async updateOutputGapParameter(roundSid: number, paramId: string, paramValue: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_parameter_id', type: STRING, value: paramId },
                { name: 'p_parameter_value', type: STRING, value: paramValue },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.updateParameter', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getOutputGapParameters
     *********************************************************************************************/
    public async getOutputGapParameters(roundSid: number): Promise<IGeneralParamValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.getParameters', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method updateOutputGapParameters
     *********************************************************************************************/
    public async updateOutputGapParameters(
        roundSid: number, paramIds: string[],
        paramValues: string[]
    ): Promise<number> {

        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_parameter_ids', type: STRING, value: paramIds },
                { name: 'p_parameter_values', type: STRING, value: paramValues },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_og_params.updateParameters', options)
        return dbResult.o_res
    }
}
