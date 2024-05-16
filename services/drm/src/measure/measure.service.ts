import { BIND_OUT, CURSOR, ISPOptions, NUMBER, SIDSLIST, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { LibMeasureService } from '../../../lib/dist/measure'

import { IDBWizardMeasureDetails, IMeasureDetails } from '.'

export class MeasureService extends LibMeasureService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method copyPreviousRoundMeasures
     *********************************************************************************************/
     public async copyPreviousRoundMeasures(roundSid: number, countryId: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('drm_measure.copyPreviousRoundMeasures', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getWizardMeasures
     * @implements
     *********************************************************************************************/
    public async getWizardMeasures(
        countryId: string, roundSid: number, dataHistoryOffset: number,
    ): Promise<IDBWizardMeasureDetails[]> {
        let storedProc = 'getWizardMeasures'
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        if (dataHistoryOffset) {
            options.params.push(
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_history_offset', type: NUMBER, value: dataHistoryOffset },
            )
            storedProc = 'getWizardArchivedMeasures'
        }

        const dbResult = await DataAccessApi.execSP(`drm_measure.${storedProc}`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method saveMeasure
     * @implements
     *********************************************************************************************/
    public async saveMeasure(measure: IMeasureDetails): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_measure_sid', type: NUMBER, value: measure.MEASURE_SID },
                { name: 'p_country_id', type: STRING, value: measure.COUNTRY_ID },
                { name: 'p_title', type: STRING, value: measure.TITLE },
                { name: 'p_descr', type: STRING, value: measure.DESCR },
                { name: 'p_esa_sid', type: NUMBER, value: measure.ESA_SID },
                { name: 'p_one_off_sid', type: NUMBER, value: measure.ONE_OFF_SID },
                { name: 'p_one_off_type_sid', type: NUMBER, value: measure.ONE_OFF_TYPE_SID },
                { name: 'p_acc_princip_sid', type: NUMBER, value: measure.ACC_PRINCIP_SID },
                { name: 'p_adopt_status_sid', type: NUMBER, value: measure.ADOPT_STATUS_SID },
                { name: 'p_label_sids', type: SIDSLIST, value: measure.labelSids },
                { name: 'p_is_eu_funded_sid', type: NUMBER, value: measure.IS_EU_FUNDED_SID },
                { name: 'p_eu_fund_sid', type: NUMBER, value: measure.EU_FUND_SID },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('drm_measure.saveMeasureDetails', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method updateMeasureScale
     *********************************************************************************************/
    public async updateMeasureScale(countryId: string, newScaleSid: number): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_scale_sid', type: NUMBER, value: newScaleSid },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('drm_measure.saveMeasureScale', options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
