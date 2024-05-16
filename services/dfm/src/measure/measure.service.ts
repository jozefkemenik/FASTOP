import { BIND_OUT, CURSOR, ISPOptions, NUMBER, SIDSLIST, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { IArchiveParams } from '../../../lib/dist/measure/shared'
import { IDBLibMeasureDetails } from '../../../lib/dist/measure/measure'
import { LibMeasureService } from '../../../lib/dist/measure'

import { IDBCountryMeasure, IDBMeasureDetails, IMeasureDetails } from '.'

export class MeasureService extends LibMeasureService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAllMeasures
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async getAllMeasures(): Promise<any[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_measure.getAllMeasures', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCountryMeasures
     *********************************************************************************************/
    public getCountryMeasures(countryId: string, archive: IArchiveParams): Promise<IDBCountryMeasure[]> {
        return this.sharedService.getReportData('dfm_measure.getCountryMeasures', countryId, false, archive)
    }

    /**********************************************************************************************
     * @method getWizardMeasures
     * @implements
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    public async getWizardMeasures(countryId: string, roundSid: number): Promise<IDBMeasureDetails[]> {
        return this.getEnterMeasures(countryId, null) as Promise<IDBMeasureDetails[]>
    }

    /**********************************************************************************************
     * @method saveMeasure
     * @implements
     *********************************************************************************************/
    public async saveMeasure(measure: IMeasureDetails): Promise<number> {
        const adoptDateYear = measure.ADOPT_DATE_YR ? Number(measure.ADOPT_DATE_YR) : -1
        const adoptDateMonth = measure.ADOPT_DATE_MH ? Number(measure.ADOPT_DATE_MH) : -1

        const options: ISPOptions = {
            params: [
                { name: 'p_measure_sid', type: NUMBER, value: measure.MEASURE_SID },
                { name: 'p_country_id', type: STRING, value: measure.COUNTRY_ID },
                { name: 'p_status_sid', type: NUMBER, value: measure.STATUS_SID },
                { name: 'p_need_research_sid', type: NUMBER, value: measure.NEED_RESEARCH_SID },
                { name: 'p_title', type: STRING, value: measure.TITLE },
                { name: 'p_descr', type: STRING, value: measure.DESCR },
                { name: 'p_info_src', type: STRING, value: measure.INFO_SRC },
                { name: 'p_adopt_date_yr', type: NUMBER, value: adoptDateYear },
                { name: 'p_adopt_date_mh', type: NUMBER, value: adoptDateMonth },
                { name: 'p_comments', type: STRING, value: measure.COMMENTS },
                { name: 'p_rev_exp_sid', type: NUMBER, value: measure.revexpSid },
                { name: 'p_esa_sid', type: NUMBER, value: measure.ESA_SID },
                { name: 'p_esa_comments', type: STRING, value: measure.ESA_COMMENTS },
                { name: 'p_one_off_sid', type: NUMBER, value: measure.ONE_OFF_SID },
                { name: 'p_one_off_type_sid', type: NUMBER, value: measure.ONE_OFF_TYPE_SID },
                { name: 'p_one_off_disagree_sid', type: NUMBER, value: measure.ONE_OFF_DISAGREE_SID },
                { name: 'p_one_off_comments', type: STRING, value: measure.ONE_OFF_COMMENTS },
                { name: 'p_quant_comments', type: STRING, value: measure.QUANT_COMMENTS },
                { name: 'p_oo_principle_sid', type: NUMBER, value: measure.OO_PRINCIPLE_SID },
                { name: 'p_label_sids', type: SIDSLIST, value: measure.labelSids },
                { name: 'p_is_eu_funded_sid', type: NUMBER, value: measure.IS_EU_FUNDED_SID },
                { name: 'p_eu_fund_sid', type: NUMBER, value: measure.EU_FUND_SID },
                { name: 'p_is_uploaded', type: STRING },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_measure.saveMeasureDetails', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method saveTransparencyReport
     *********************************************************************************************/
    public async saveTransparencyReport(countryId: string, measureSids: number[]): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_measure_sids', type: NUMBER, value: measureSids },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dfm_measure.saveTransparencyReport', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getTransparencyReportMeasures
     *********************************************************************************************/
    public async getTransparencyReportMeasures(countryId: string, roundSid?: number): Promise<IDBLibMeasureDetails[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
            ],
        }
        if (roundSid) {
            options.params.push({ name: 'p_round_sid', type: NUMBER, value: roundSid })
        }

        const dbResult = await DataAccessApi.execSP('dfm_measure.getTransparencyReportMeasures', options)
        return dbResult.o_cur
    }
}
