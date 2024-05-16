import { ELibColumn, getMeasureWizardColumnYearKey } from '../../../../shared-lib/dist/prelib/wizard'
import {
    ILibMeasureDetails,
    ILibMeasureValue,
    ILibMeasureWizardUpload,
    ILibVectorConfig,
    ILibWorkbookConfig,
    ILibWorksheetConfig,
    IMeasureObject,
    IMeasureUpload,
    IMeasuresRange,
    IObjectSIDs,
    IScale,
    IWizardTemplate,
} from '..'

import { LibUploadService } from './lib-upload.service'

export abstract class MeasureUploadService<B extends ILibMeasureDetails> extends LibUploadService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getWizardTemplate
     * Generate excel template for DFM uploads.
     *********************************************************************************************/
    public async getWizardTemplate(countryId: string, roundSid: number, withData: boolean,
                                   measures: B[], range: IMeasuresRange
    ): Promise<IWizardTemplate<B>> {
        const workbookConfig: ILibWorkbookConfig = await this.getTemplateConfig(countryId, roundSid, range)

        return {
            measures,
            withData,
            range,
            workbookConfig
        }
    }

    /**********************************************************************************************
     * @method convertToMeasureUpload
     *********************************************************************************************/
    public convertToMeasureUpload(countryId: string, roundSid: number,
                                  uploadMeasures: ILibMeasureWizardUpload): IMeasureUpload {
        if (!uploadMeasures || !uploadMeasures.measures || !uploadMeasures.measures.length) {
            throw new Error('There are no valid measures to be stored!')
        }

        return {
            countryId,
            scaleSid: this.getScaleSid(uploadMeasures),
            measures: uploadMeasures.measures.map<IMeasureObject>( data =>
                this.convertToMeasureObject(roundSid, data.measureSid, data.values)
            )
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertToMeasureObject
     * Prepare DB procedure parameter
     *********************************************************************************************/
    protected convertToMeasureObject(roundSid: number, measureSid: number, values: ILibMeasureValue): IMeasureObject {
        return {
            TITLE: values[ELibColumn.TITLE],
            SHORT_DESCR: values[ELibColumn.DESCRIPTION],
            ESA_SID: +values[ELibColumn.ESA_CODE],
            DATA: values[ELibColumn.DATA_VECTOR],
            START_YEAR: values[ELibColumn.START_YEAR],
            YEAR: +values[ELibColumn.IMPACT_YEAR],
            UPLOADED_MEASURE_SID: measureSid ? measureSid : -1,
            SOURCE_SID: -1,
            ACC_PRINCIP_SID: -1,
            ADOPT_STATUS_SID: -1,
            ONE_OFF_SID: -1,
            ONE_OFF_TYPE_SID: -1,
            ONE_OFF_DISAGREE_SID: -1,
            ONE_OFF_COMMENTS: null,
            EXERCISE_SID: -1,
            STATUS_SID: -1,
            NEED_RESEARCH_SID: -1,
            INFO_SRC: null,
            ADOPT_DATE_YR: -1,
            ADOPT_DATE_MH: -1,
            COMMENTS: null,
            REV_EXP_SID: -1,
            ESA_COMMENTS: null,
            QUANT_COMMENTS: null,
            OO_PRINCIPLE_SID: -1,
            LABEL_SIDS: values[ELibColumn.LABELS] ?? [],
            IS_EU_FUNDED_SID: values[ELibColumn.IS_EU_FUNDED] ?? -1,
            EU_FUND_SID: values[ELibColumn.EU_FUND] ?? -1,
        }
    }

    /**********************************************************************************************
     * @method filterMeasuresForWorksheet
     * Apply additional filtering depending on worksheet
     *********************************************************************************************/
    protected filterMeasuresForWorksheet(worksheetConfig: ILibWorksheetConfig, measures: B[]): B[] {
        return measures
    }

    /**********************************************************************************************
     * @method getVectorConfig
     *********************************************************************************************/
    protected getVectorConfig(range: IMeasuresRange): ILibVectorConfig {
        return {
            startYear: range.startYear,
            endYear: range.startYear + range.yearsCount - 1
        }
    }

    /**********************************************************************************************
     * @method getMeasureDataColumnKey
     *********************************************************************************************/
    protected getMeasureDataColumnKey(year: number) {
        return getMeasureWizardColumnYearKey(year)
    }

    /**********************************************************************************************
     * @method getScalesAsObjectSIDs
     *********************************************************************************************/
    protected async getScalesAsObjectSIDs(scales: IScale[]): Promise<IObjectSIDs> {
        return scales.reduce((acc, scale) => {
            acc[scale.sid] = scale.description
            return acc
        }, {})
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getScaleSid
     *********************************************************************************************/
    private getScaleSid(uploadMeasures: ILibMeasureWizardUpload): number {
        return uploadMeasures && uploadMeasures.globalData ? +uploadMeasures.globalData : -1
    }
}
