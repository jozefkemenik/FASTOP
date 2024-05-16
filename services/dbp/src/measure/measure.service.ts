import { EApps } from 'config'

import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { LibMeasureService } from '../../../lib/dist/measure'

import { IDBWizardMeasureDetails, IMeasureDetails } from '.'
import { SharedService } from '../shared/shared.service'

export class MeasureService extends LibMeasureService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(sharedService: SharedService) {
        super(EApps.DBP, sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getWizardMeasures
     * @implements
     *********************************************************************************************/
    public async getWizardMeasures(countryId: string, roundSid: number): Promise<IDBWizardMeasureDetails[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('dbp_measure.getWizardMeasures', options)
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
                { name: 'p_source_sid', type: NUMBER, value: measure.SOURCE_SID },
                { name: 'p_acc_princip_sid', type: NUMBER, value: measure.ACC_PRINCIP_SID },
                { name: 'p_adopt_status_sid', type: NUMBER, value: measure.ADOPT_STATUS_SID },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dbp_measure.saveMeasureDetails', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method recalculateAggregated
     *********************************************************************************************/
    public async recalculateAggregated(countryId: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, },
                { name: 'p_version', type: NUMBER, },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('dbp_grid_data.calculateTable5AMeasures', options)
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
        const dbResult = await DataAccessApi.execSP('dbp_measure.saveMeasureScale', options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
}
