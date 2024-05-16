import {
    IGridsValidation,
    ILinkedTableBaseExcelParams,
    ILinkedTableExcelParams,
    ILinkedTableIndicatorsData,
} from '../../../lib/dist/fisc/linked-tables'
import { LibLinkedTablesController, LibLinkedTablesService } from '../../../lib/dist/fisc'
import { IMemberStateValidation } from '../../../lib/dist/fisc/output-gaps'
import { SharedCalc } from '../../../lib/dist/fisc/shared/calc/shared-calc'

export class LinkedTablesController extends LibLinkedTablesController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getExcelDataParams
     *********************************************************************************************/
    protected async getExcelDataParams(roundSid: number): Promise<ILinkedTableBaseExcelParams> {
        return {
            isDBP: true,
            scpRoundSid: await this.getScpRound(roundSid)
        }
    }

    /**********************************************************************************************
     * @method getScpRound
     *********************************************************************************************/
    protected async getScpRound(roundSid: number): Promise<number> {
        return await this.calcService.getScpLatestRoundSid(roundSid)
    }

    /**********************************************************************************************
     * @method getExcelDbpIndicatorsData
     *********************************************************************************************/
    protected async getExcelDbpIndicatorsData(params: ILinkedTableExcelParams): Promise<ILinkedTableIndicatorsData> {
        return this.excelService.getDbpIndicatorsData(params)
    }

    /**********************************************************************************************
     * @method validateScpGrids
     *********************************************************************************************/
    protected async validateScpGrids(calc: SharedCalc<LibLinkedTablesService>): Promise<IGridsValidation> {
        return this.validateGrids(calc.getScpCountryStatus())
    }

    /**********************************************************************************************
     * @method validateScpMemberState
     *********************************************************************************************/
    protected async validateScpMemberState(calc: SharedCalc<LibLinkedTablesService>): Promise<IMemberStateValidation> {
        return this.validateMemberStateData(true, calc)
    }
}
