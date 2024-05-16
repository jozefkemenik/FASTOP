import { IAggregateCalcParams, IDBCellValue, IVariableExcelParams } from '../fisc/aggregates'
import { IHicpCalcParams, IHicpCalcResult } from '../../../auxtools/src/hicp/shared-interfaces'
import { EApps } from 'config'
import { IVector } from '../../../web-queries/src/shared/shared-interfaces'
import { RequestService } from '../request.service'


export class FdmsStarApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getLinesData
     *********************************************************************************************/
    public static async getLinesData(app: EApps, params: IVariableExcelParams): Promise<IDBCellValue[]> {
        return RequestService.request(app, `/aggregates/lineData/:roundSid'`, 'post', params)
    }

    /**********************************************************************************************
     * @method calculateAggregates
     *********************************************************************************************/
    public static async calculateAggregates(params: IAggregateCalcParams): Promise<string> {
        return RequestService.request(EApps.FDMSSTAR, `/calc/aggregate`, 'post', params)
    }

    /**********************************************************************************************
     * @method convertFrequency
     *********************************************************************************************/
    public static async convertFrequency(
        vectors: IVector[], startYear: number, inputFrequency: string, outputFrequency: string
    ): Promise<IVector[]> {
        return RequestService.request(EApps.FDMSSTAR, `/calc/convert`, 'post', {
            vectors, startYear, inputFrequency, outputFrequency
        })
    }

    /**********************************************************************************************
     * @method calculatePCT
     *********************************************************************************************/
    public static async calculatePCT(vectors: IVector[], startYear: number, inputFrequency: string): Promise<IVector[]> {
        return RequestService.request(
            EApps.FDMSSTAR, `/calc/pct`, 'post', { vectors, startYear, inputFrequency }
        )
    }

    /**********************************************************************************************
     * @method calculateSum
     *********************************************************************************************/
    public static async calculateSum(vectors: IVector[], startYear: number, inputFrequency: string): Promise<IVector[]> {
        return RequestService.request(
            EApps.FDMSSTAR, `/calc/sum`, 'post', { vectors, startYear, inputFrequency }
        )
    }

    /**********************************************************************************************
     * @method calculateHicp
     *********************************************************************************************/
    public static async calculateHicp(params: IHicpCalcParams): Promise<IHicpCalcResult> {
        return RequestService.request(EApps.FDMSSTAR, `/calc/hicp`, 'post', params)
    }
}
