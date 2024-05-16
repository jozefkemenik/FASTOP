import { BIND_OUT, CURSOR, ISPOptions, STRING } from '../../../lib/dist/db'
import { IDBAmecoData, IDBAmecoInputSource, IDBAmecoNsiData } from '.'
import { DataAccessApi } from '../../../lib/dist/api'
import { EApps } from 'config'


export class ReportService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {}

    /**********************************************************************************************
     * @method getAmecoCalculatedData
     *********************************************************************************************/
    public async getAmecoCalculatedData(
        providerId: string, periodicityId: string
    ): Promise<IDBAmecoData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_provider_id', type: STRING, value: providerId },
                { name: 'p_periodicity_id', type: STRING, value: periodicityId ?? 'A' },
            ],
        }
        const dbResult = await DataAccessApi.execSP('ameco_indicator.getIndicatorMetadata', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getAmecoInputSources
     *********************************************************************************************/
    public async getAmecoInputSources(): Promise<IDBAmecoInputSource[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('ameco_indicator.getInputSources', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getAmecoNsiData
     *********************************************************************************************/
    public async getAmecoNsiData(
        periodicityId: string, countryId?: string,
    ): Promise<IDBAmecoNsiData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId || null },
                { name: 'p_periodicity_id', type: STRING, value: periodicityId ?? 'A' },
            ],
        }
        const dbResult = await DataAccessApi.execSP('ameco_nsi.getNSIData', options)
        return dbResult.o_cur
    }
}
