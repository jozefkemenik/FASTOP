import { EApps } from 'config'

import { BIND_OUT, CURSOR, ISPOptions, MEASUREARRAY, NUMBER, STRING } from '../../db'
import { IArchiveParams, IMeasuresRange } from '../shared'
import { IDBLibMeasureDetails, ILibMeasureDetails } from '.'
import { IMeasureUpload, MeasureSharedService, config } from '..'
import { DataAccessApi } from '../../api/data-access.api'

export abstract class LibMeasureService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        protected readonly appId: EApps,
        protected readonly sharedService: MeasureSharedService
    ) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method deleteMeasure
     *********************************************************************************************/
    public async deleteMeasure(measureSid: number, countryId: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_measure_sid', type: NUMBER, value: measureSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.appId}_measure.deleteMeasure`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getEnterMeasures
     *********************************************************************************************/
    public getEnterMeasures(countryId: string, archive: IArchiveParams): Promise<IDBLibMeasureDetails[]> {
        return this.sharedService.getReportData(`${this.appId}_measure.getMeasures`, countryId, false, archive)
    }

    /**********************************************************************************************
     * @method getMeasureDetails
     *********************************************************************************************/
    public async getMeasureDetails(
        measureSid: number, countryId: string, archive: IArchiveParams
    ): Promise<IDBLibMeasureDetails[]> {
        let procedure = `${this.appId}_measure.getMeasureDetails`
        const options: ISPOptions = {
            params: [
                { name: 'p_measure_sid', type: NUMBER, value: measureSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        if (archive && (archive.roundSid || archive.storageId) && !archive.ctyVersion) {
            procedure += 'Archived'
            options.params.unshift(
                { name: 'p_round_sid', type: NUMBER, value: archive.roundSid },
                { name: 'p_storage_sid', type: NUMBER, value: archive.storageSid },
                { name: 'p_cust_text_sid', type: NUMBER, value: archive.custTextSid },
                { name: 'p_storage_id', type: STRING, value: archive.storageId },
            )
        }

        const dbResult = await DataAccessApi.execSP(procedure, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getMeasuresRange
     *********************************************************************************************/
    public async getMeasuresRange(): Promise<IMeasuresRange> {
        return config
    }

    /**********************************************************************************************
     * @method getWizardMeasures
     *********************************************************************************************/
    public abstract getWizardMeasures(
        countryId: string, roundSid: number, dataHistoryOffset?: number,
    ): Promise<IDBLibMeasureDetails[]>

    /**********************************************************************************************
     * @method saveMeasure
     *********************************************************************************************/
    public abstract saveMeasure(measure: ILibMeasureDetails): Promise<number>

    /**********************************************************************************************
     * @method setMeasureValues
     *********************************************************************************************/
    public async setMeasureValues(
        measureSid: number, countryId: string,  year: number, startYear: number, values: string
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_measure_sid', type: NUMBER, value: measureSid },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_year', type: NUMBER, value: year },
                { name: 'p_start_year', type: NUMBER, value: startYear || config.startYear },
                { name: 'p_values', type: STRING, value: values },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.appId}_measure.setMeasureValues`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method updateMeasureScale
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    public async updateMeasureScale(countryId: string, scaleSid: number): Promise<number> {
        return -1
    }

    /**********************************************************************************************
     * @method storeUploadMeasures
     * Store uploaded measures in the measures table
     *********************************************************************************************/
    public async storeUploadMeasures(measureUpload: IMeasureUpload): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: measureUpload.countryId },
                { name: 'p_scale_sid', type: NUMBER, value: measureUpload.scaleSid },
                { name: 'p_measures', type: MEASUREARRAY, value: measureUpload.measures },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`${this.appId}_measure.uploadWizardMeasures`, options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
