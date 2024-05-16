import {
    IBaselineData,
    IBaselineDefinition,
    IBaselineUpload,
    ICountryParamsData,
    ICountryParamsDefinition,
    ICountryParamsUpload,
    IGeneralParamValue,
} from '.'

import { UploadService } from './upload.service'

export class UploadController {

    private static readonly CHANGEY_PARAM_ID = 'changey'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private uploadService: UploadService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getChangeY
     *********************************************************************************************/
    public async getChangeY(roundSid: number): Promise<number> {
        const paramValue = await this.uploadService.getOutputGapParameter(roundSid, UploadController.CHANGEY_PARAM_ID)
        const value = Number(paramValue)
        return isNaN(value) ? 0 : value
    }

    /**********************************************************************************************
     * @method updateChangeY
     *********************************************************************************************/
    public async updateChangeY(roundSid: number, changeY: number): Promise<number> {
        return this.uploadService.updateOutputGapParameter(roundSid, UploadController.CHANGEY_PARAM_ID, `${changeY}`)
    }

    /**********************************************************************************************
     * @method getBaselineDefinition
     *********************************************************************************************/
    public async getBaselineDefinition(): Promise<IBaselineDefinition> {
        const [countries, variables] = await Promise.all([
            this.uploadService.getCountryGroupCountries('EU'),
            this.uploadService.getBaselineVariables(),
        ])

        return {
            countries,
            variables
        }
    }

    /**********************************************************************************************
     * @method getBaselineData
     *********************************************************************************************/
    public async getBaselineData(roundSid: number): Promise<IBaselineData[]> {
        return this.uploadService.getBaselineData(roundSid)
    }

    /**********************************************************************************************
     * @method uploadBaselineData
     *********************************************************************************************/
    public async uploadBaselineData(roundSid: number, data: IBaselineUpload[]): Promise<number> {
        return this.uploadService.uploadBaselineData(roundSid, data)
    }

    /**********************************************************************************************
     * @method getCountryParamsDefinition
     *********************************************************************************************/
    public async getCountryParamsDefinition(): Promise<ICountryParamsDefinition> {
        const [countries, params] = await Promise.all([
            this.uploadService.getCountryGroupCountries('EU'),
            this.uploadService.getCountryParams(),
        ])

        return {
            countries: countries.concat('US'),
            params
        }
    }

    /**********************************************************************************************
     * @method getCountryParamsData
     *********************************************************************************************/
    public async getCountryParamsData(roundSid: number): Promise<ICountryParamsData[]> {
        return this.uploadService.getCountryParamsData(roundSid)
    }

    /**********************************************************************************************
     * @method uploadCountryParameters
     *********************************************************************************************/
    public async uploadCountryParameters(roundSid: number, data: ICountryParamsUpload[]): Promise<number> {
        return this.uploadService.uploadCountryParameters(roundSid, data)
    }

    /**********************************************************************************************
     * @method getGeneralParams
     *********************************************************************************************/
    public async getGeneralParams(roundSid: number): Promise<IGeneralParamValue[]> {
        return this.uploadService.getOutputGapParameters(roundSid)
    }

    /**********************************************************************************************
     * @method uploadGeneralParameters
     *********************************************************************************************/
    public async uploadGeneralParameters(roundSid: number, data: IGeneralParamValue[]): Promise<number> {
        return this.uploadService.updateOutputGapParameters(roundSid, data.map(p => p.code), data.map(p => p.value))
    }
}
