import { EApps } from 'config'
import { ILine } from '../shared/calc'
import { IMemberStateValidation } from '../output-gaps'
import { MeasureSharedService } from '../../measure'
import { SharedCalc } from '../shared/calc/shared-calc'
import { SharedCalcController } from '../shared/calc/shared-calc.controller'
import { WorkbookGroup } from '../../../../shared-lib/dist/prelib/fisc-grids'

import {
    IGridsValidation,
    ILinkedTableBaseExcelParams,
    ILinkedTableExcelData,
    ILinkedTableExcelParams,
    ILinkedTableIndicatorsData,
    ILinkedTableTemplateFile,
    ILinkedTableValidation,
} from '.'
import { LibLinkedTablesExcelService } from './linked-tables-excel.service'
import { LibLinkedTablesService } from './linked-tables.service'

export class LibLinkedTablesController extends SharedCalcController<LibLinkedTablesService> {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected readonly excelService: LibLinkedTablesExcelService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, readonly sharedService: MeasureSharedService) {
        super(new LibLinkedTablesService(appId))

        this.excelService = new LibLinkedTablesExcelService(sharedService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method downloadExcelData
     *********************************************************************************************/
    public async downloadExcelData(countryId: string, roundSid: number): Promise<ILinkedTableExcelData> {
        const roundYear = await this.excelService.getRoundYear(roundSid)
        const params: ILinkedTableExcelParams = Object.assign(
            { countryId, roundYear, range: { startYear: roundYear - 20, endYear: roundYear + 6 }, roundSid },
            await this.getExcelDataParams(roundSid),
        )
        return {
            uploaded: await this.excelService.getUploadedData(params),
            scp: await this.excelService.getScpIndicatorsData(params),
            dbp: await this.getExcelDbpIndicatorsData(params),
        }
    }

    /**********************************************************************************************
     * @method validate
     *********************************************************************************************/
    public async validate(countryId: string, roundSid: number): Promise<ILinkedTableValidation> {
        const calc = await this.createSharedCalc(countryId, roundSid)

        return Promise.all([
            this.validateAmecoIndicators(calc),
            this.validateGrids(calc.countryStatus$),
            this.validateMemberStateData(false, calc),
            this.validateScpGrids(calc),
            this.validateScpMemberState(calc),
        ]).then(([ameco, grids, memberState, scpGrids, scpMemberState]) => {
            return {
                hasErrors: ameco.hasErrors || memberState.hasErrors || (scpMemberState && scpMemberState.hasErrors),
                ameco,
                grids,
                memberState,
                scpGrids,
                scpMemberState,
            }
        })
    }

    /**********************************************************************************************
     * @method downloadExcelTemplate
     *********************************************************************************************/
    public async downloadExcelTemplate(): Promise<ILinkedTableTemplateFile> {
        return this.calcService.getLinkedTablesTemplate(this.appId)
    }

    /**********************************************************************************************
     * @method checkExcelTemplate
     *********************************************************************************************/
    public async checkExcelTemplate(): Promise<boolean> {
        return this.calcService.checkActiveTemplate(this.appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method validateScpGrids
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected async validateScpGrids(calc: SharedCalc<LibLinkedTablesService>): Promise<IGridsValidation> {
        return null
    }

    /**********************************************************************************************
     * @method validateScpMemberState
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected async validateScpMemberState(calc: SharedCalc<LibLinkedTablesService>): Promise<IMemberStateValidation> {
        return null
    }

    /**********************************************************************************************
     * @method getExcelDbpIndicatorsData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected async getExcelDbpIndicatorsData(params: ILinkedTableExcelParams): Promise<ILinkedTableIndicatorsData> {
        return undefined
    }

    /**********************************************************************************************
     * @method getRequiredAmecoIndicators
     *********************************************************************************************/
    protected async getRequiredAmecoIndicators(): Promise<string[]> {
        return this.calcService.getRequiredAmecoIndicators()
    }

    /**********************************************************************************************
     * @method getExcelDataParams
     *********************************************************************************************/
    protected async getExcelDataParams(roundSid: number): Promise<ILinkedTableBaseExcelParams> {
        return {
            isDBP: false,
            scpRoundSid: roundSid,
        }
    }

    /**********************************************************************************************
     * @method getScpRound
     *********************************************************************************************/
    protected async getScpRound(roundSid: number): Promise<number> {
        return roundSid
    }

    /**********************************************************************************************
     * @method validateGrids
     *********************************************************************************************/
    protected async validateGrids(ctyStatusPromise: Promise<string>): Promise<IGridsValidation> {
        const ctyStatus = await ctyStatusPromise
        return {
            validated: this.calcService.canModifyCountry(ctyStatus),
        }
    }

    /**********************************************************************************************
     * @method validateMemberStateData
     *********************************************************************************************/
    protected async validateMemberStateData(
        useScpRound: boolean,
        calc: SharedCalc<LibLinkedTablesService>,
    ): Promise<IMemberStateValidation> {
        const result: IMemberStateValidation = {
            hasErrors: false,
            gridLines: [],
        }

        const requiredLines: ILine[] = await calc.getRequiredLinesForWorkbook(useScpRound, WorkbookGroup.LINKED_TABLES)
        const lines: string[] = await calc.getLinesWithCountryDeskValues(
            useScpRound,
            requiredLines.map(l => l.lineId),
        )
        const map: ILineMap = !lines
            ? {}
            : lines.reduce((acc, value) => {
                  acc[value] = value
                  return acc
              }, {})

        for (const requiredLine of requiredLines) {
            const lineId: string = map[requiredLine.lineId]
            let hasError = false
            if (!lineId) {
                result.hasErrors = true
                hasError = true
            }
            result.gridLines.push({
                lineId: requiredLine.lineId,
                lineDesc: requiredLine.lineDesc,
                hasError,
            })
        }

        result.gridLines.sort((a, b) => a.lineId.localeCompare(b.lineId))
        return result
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createSharedCalc
     *********************************************************************************************/
    private async createSharedCalc(countryId: string, roundSid: number): Promise<SharedCalc<LibLinkedTablesService>> {
        return new SharedCalc(this.appId, countryId, roundSid, this.calcService, null, await this.getScpRound(roundSid))
    }
}

interface ILineMap {
    [key: string]: string
}
