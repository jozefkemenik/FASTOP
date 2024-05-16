import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { GridColType, GridLineType, GridVersionType } from '../../../../shared-lib/dist/prelib/fisc-grids'
import { IDBGrid, IDataType, IHelpMessage } from '../shared'
import { DataAccessApi } from '../../api/data-access.api'
import { EApps } from 'config'
import { HelpMsgType } from '../help/shared-interfaces'
import { IDBIndicator } from '../shared/calc'
import { IScale } from '../../measure'

import {
    ICellValue,
    ICells,
    ICtyGridCells,
    ICtyGridData,
    ICtyGridLineCells,
    ICtyGridValues,
    IDBCountryDefaultLevel,
    IDBCountryGrid,
    IDBCountryGridData,
    IDBCtyGridName,
    IDBGridName,
    IDBOptionalCell,
    IDBRoundsLine,
    IFiscCtyGridDefinition,
    IFiscExportData,
    IFiscGridData,
    IFiscGridDefinition,
    IGridCol,
    IGridLine,
    IGridOptionalCells,
    IGridRound,
    IGridTypeInfo,
    IGridsCols,
    IGridsLines,
    ILineCells,
    ILineIdToLineSid,
} from '.'

export abstract class FiscGridService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // cache
    private readonly maxCacheSize = 100
    private _gridLines: {[roundGridSid: number]: IGridLine[]} = {}
    private _gridCols: {[roundGridSid: number]: IGridCol[]} = {}
    private _optionalCells: IGridOptionalCells
    private _gridTypes: {[ctyGridSid: number]: IGridTypeInfo} = {}
    private _indicators: {[source: string]: IDBIndicator[]} = {}
    private _dataTypes: IDataType[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method copyCtyGridVersion
     *********************************************************************************************/
    public async copyCtyGridVersion(
        countryId: string, ctyGridSid: number, fromVersion: string, toVersion: string
    ): Promise<number> {

        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_cty_grid_sid', type: NUMBER, value: ctyGridSid },
                { name: 'p_version_from', type: STRING, value: fromVersion },
                { name: 'p_version_to', type: STRING, value: toVersion },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_grid_data.copyCtyGridVersion`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method copyVersionToAnother
     *********************************************************************************************/
    public async copyVersionToAnother(
        countryId: string, versionFrom: string, versionTo: string,
    ): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_version_from', type: STRING, value: versionFrom },
                { name: 'p_version_to', type: STRING, value: versionTo },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_grid_data.copyAllGridsFromVersion`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getIndicatorsForCSV
     *********************************************************************************************/
    public async getIndicatorsForCSV(
        rounds: number[], countries: string[], indicators: string[], type: string
    ): Promise<Array<Array<string|number>>> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sids', type: NUMBER, value: rounds },
                { name: 'p_country_ids', type: STRING, value: countries },
                { name: 'p_indicator_ids', type: STRING, value: indicators },
            ],
            arrayFormat: true,
            maxRows: 1000,
        }
        const dbResult = await DataAccessApi.execSP(`idr_calculated.get${type}IndicatorsForCSV`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCountryDefaultLevels
     *********************************************************************************************/
    public async getCountryDefaultLevels(ctyGridSid: number): Promise<IDBCountryDefaultLevel[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_cty_grid_sid', type: NUMBER, value: ctyGridSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_getters.getCtyDefaultLevels`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCountryRoundScale
     *********************************************************************************************/
     public async  getCountryRoundScale(countryId: string, roundSid: number, ctyVersion?: number): Promise<IScale> {
        const options: ISPOptions = {
            params: [
                { name: 'p_cty_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_cty_version', type: NUMBER, value: ctyVersion },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_getters.getCtyRoundScale`, options)
        return dbResult.o_cur && dbResult.o_cur.length === 1 ? dbResult.o_cur[0] : null
    }

    /**********************************************************************************************
     * @method getCountryRoundScaleByCtyGrid
     *********************************************************************************************/
    public async  getCountryRoundScaleByCtyGrid(ctyGridSid: number): Promise<IScale> {
        const options: ISPOptions = {
            params: [
                { name: 'p_cty_grid_sid', type: NUMBER, value: ctyGridSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_getters.getCtyRoundScaleByCtyGrid`, options)
        return dbResult.o_cur && dbResult.o_cur.length === 1 ? dbResult.o_cur[0] : null
    }

    /**********************************************************************************************
     * @method saveCountryRoundScale
     *********************************************************************************************/
    public async  saveCountryRoundScale(countryId: string, roundSid: number, scaleId: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_cty_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_scale_id', type: STRING, value: scaleId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_grid_data.saveCtyRoundScale`, options)
        return dbResult.o_res
    }
    

    /**********************************************************************************************
     * @method getCountryDivergenceGridData
     *********************************************************************************************/
    public async getCountryDivergenceGridData(
        gridInfo: IGridTypeInfo, gridVersionType: GridVersionType
    ): Promise<IFiscGridData[]> {

        const [gridLines, gridCols] = await Promise.all([
            this.getGridLines(gridInfo.roundGridSid),
            this.getGridCols(gridInfo.roundGridSid),
        ])
        const yearColumns = gridCols.filter(col => col.colTypeId === GridColType.YEAR)

        const cells: ICells = {}
        const calculationLines = gridLines.filter(line => line.lineTypeId === GridLineType.CALCULATION)
        for (const line of calculationLines) {
            if (this.isCopyLineRule(line.calcRule)) {
                await this.evaluateCopyLineRule(gridInfo.countryId, gridInfo.roundSid,
                                                line, yearColumns, gridVersionType, cells)
            } else {
                this.evaluateCalculationRule(line, gridLines, yearColumns, cells)
            }
        }

        const data: IFiscGridData[] = []
        Object.getOwnPropertyNames(cells).forEach(lineSid =>
            Object.getOwnPropertyNames(cells[lineSid]).forEach(colSid => {
                const cell: ICellValue = cells[lineSid][colSid]
                if (cell) {
                    data.push({
                        lineSid: +lineSid,
                        colSid: +colSid,
                        gridId: gridInfo.gridId,
                        lineId: cell.lineId,
                        yearValue: cell.yearValue,
                        gridVersionType,
                        footnote: undefined,
                        cellValue: isNaN(cell.value) ? '' :
                            (gridVersionType === GridVersionType.PUBLIC ?
                                cell.value.toFixed(1) : cell.value.toString())
                    })
                }
            })
        )

        return data
    }

    /**********************************************************************************************
     * @method getCountryGrid
     *********************************************************************************************/
    public async getCountryGrid(
        countryId: string, gridId: string, roundSid: number, version: number
    ): Promise<IDBCountryGrid> {
        const options: ISPOptions = {
            params: [
                { name: 'p_grid_id', type: STRING, value: gridId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_version', type: NUMBER, value: version },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`${this.appId}_getters.getCtyGrid`, options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method getCountryGridData
     *********************************************************************************************/
    public async getCountryGridData(
        countryId: string, ctyGridSid: number, gridVersionType: GridVersionType
    ): Promise<IDBCountryGridData[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_cty_grid_sid', type: NUMBER, value: ctyGridSid },
                { name: 'p_grid_version_type', type: STRING, value: gridVersionType },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_grid_data.getCtyGridData`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getCountryGridsDefinitions
     *********************************************************************************************/
    public async getCountryGridsDefinitions(countryId: string, gridId: string): Promise<IFiscCtyGridDefinition[]> {
        const gridNames: IDBCtyGridName[] = await this.getCountryGridNames(countryId, gridId)
        const roundGridSids: number[] = gridNames.map(g => g.ROUND_GRID_SID)
        const [lines, cols, optionalCells] = await Promise.all([
            this.getGridsLinesMap(roundGridSids),
            this.getGridsColsMap(roundGridSids),
            this.getOptionalCellsMap(),
        ])

        return gridNames.map(gridName => ({
            ctyGridSid: gridName.CTY_GRID_SID,
            gridSid: gridName.GRID_SID,
            gridId: gridName.GRID_ID,
            gridTypeId: gridName.GRID_TYPE_ID,
            description: gridName.DESCR,
            year: gridName.YEAR,
            lines: lines[gridName.ROUND_GRID_SID],
            cols: cols[gridName.ROUND_GRID_SID],
            optionalCells,
            orderBy: gridName.ORDER_BY,
        }))
    }

    /**********************************************************************************************
     * @method getCurrentCountryVersion
     *********************************************************************************************/
    public async getCurrentCountryVersion(countryId: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_getters.getCurrentCtyVersion`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountryVersions
     *********************************************************************************************/
    public async getCountryVersions(countryId: string, roundSid: number): Promise<number[]> {
        const options: ISPOptions = {
            arrayFormat: true,
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ]
        }

        const dbResult = await DataAccessApi.execSP(`gd_getters.getCtyVersions`, options)
        // flatten results
        return [].concat(...dbResult.o_cur)
    }

    /**********************************************************************************************
     * @method getCurrentGridRound
     *********************************************************************************************/
    public async getCurrentGridRound(): Promise<IGridRound> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: this.appId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_getters.getCurrentRound', options)
        return dbResult.o_cur && dbResult.o_cur.length === 1 ? {
            roundSid: Number(dbResult.o_cur[0].ROUND_SID),
            year: Number(dbResult.o_cur[0].YEAR),
            periodId: dbResult.o_cur[0].PERIOD_ID,
        } : null
    }

    /**********************************************************************************************
     * @method getGridCols
     *********************************************************************************************/
    public async getGridCols(roundGridSid: number): Promise<IGridCol[]> {
        if (!this._gridCols[roundGridSid]) {
            this._gridCols = this.prepareCache(this._gridCols)
            const options: ISPOptions = {
                params: [
                    { name: 'p_round_grid_sid', type: NUMBER, dir: BIND_IN, value: roundGridSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('gd_getters.getGridCols', options)
            this._gridCols[roundGridSid] = dbResult.o_cur
        }
        return this._gridCols[roundGridSid]
    }

    /**********************************************************************************************
     * @method getGridLines
     *********************************************************************************************/
    public async getGridLines(roundGridSid: number): Promise<IGridLine[]> {
        if (!this._gridLines[roundGridSid]) {
            this._gridLines = this.prepareCache(this._gridLines)
            const options: ISPOptions = {
                params: [
                    { name: 'p_round_grid_sid', type: NUMBER, dir: BIND_IN, value: roundGridSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('gd_getters.getGridLines', options)
            if (dbResult.o_cur) {
                this._gridLines[roundGridSid] = []
                dbResult.o_cur.forEach(gridLine => {
                    const mandatoryCtyIds: string[] = gridLine.mandatoryCtyIds ?
                                                      gridLine.mandatoryCtyIds.split(',') : undefined
                    this._gridLines[roundGridSid].push(Object.assign(gridLine, { mandatoryCtyIds }))
                })
            }
        }
        return this._gridLines[roundGridSid]
    }

    /**********************************************************************************************
     * @method getGrids
     *********************************************************************************************/
    public async getGrids(roundSid: number): Promise<IDBGrid[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sids', type: NUMBER, value: roundSid },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP(`gd_getters.getGrids`, options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getGridsColsMap
     *********************************************************************************************/
    public async getGridsColsMap(roundGridSids: number[]): Promise<IGridsCols> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_grid_sids', type: NUMBER, value: roundGridSids },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_getters.getGridsCols', options)

        return dbResult.o_cur.reduce((acc: IGridsCols, col: IGridCol) => {
            acc[col.roundGridSid] = acc[col.roundGridSid] || []
            acc[col.roundGridSid].push(col)
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getGridsLinesMap
     *********************************************************************************************/
    public async getGridsLinesMap(roundGridSids: number[]): Promise<IGridsLines> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_grid_sids', type: NUMBER, value: roundGridSids },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_getters.getGridsLines', options)

        return dbResult.o_cur.reduce((acc: IGridsLines, line: IGridLine) => {
            acc[line.roundGridSid] = acc[line.roundGridSid] || []
            acc[line.roundGridSid].push(line)
            return acc
        }, {})
    }

    /**********************************************************************************************
     * @method getGridsDefinitions
     *********************************************************************************************/
    public async getGridsDefinitions(
        gridId: string, includeReadOnlyGrids: boolean, roundSid?: number
    ): Promise<IFiscGridDefinition[]> {
        const gridNames: IDBGridName[] = await this.getGridNames(gridId, includeReadOnlyGrids, roundSid)
        const roundGridSids: number[] = gridNames.map(g => g.ROUND_GRID_SID)
        const [lines, cols, optionalCells] = await Promise.all([
            this.getGridsLinesMap(roundGridSids),
            this.getGridsColsMap(roundGridSids),
            this.getOptionalCellsMap(),
        ])

        return gridNames.map(gridName => ({
            gridSid: gridName.GRID_SID,
            gridId: gridName.GRID_ID,
            gridTypeId: gridName.GRID_TYPE_ID,
            description: gridName.DESCR,
            year: gridName.YEAR,
            lines: lines[gridName.ROUND_GRID_SID],
            cols: cols[gridName.ROUND_GRID_SID],
            optionalCells
        }))
    }

    /**********************************************************************************************
     * @method getGridTypeInfo
     *********************************************************************************************/
    public async getGridTypeInfo(ctyGridSid: number): Promise<IGridTypeInfo> {
        if (!this._gridTypes[ctyGridSid]) {
            this._gridTypes = this.prepareCache(this._gridTypes)

            const options: ISPOptions = {
                params: [
                    { name: 'p_cty_grid_sid', type: NUMBER, dir: BIND_IN, value: ctyGridSid },
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('gd_getters.getGridTypeInfo', options)
            this._gridTypes[ctyGridSid] = {
                gridType: dbResult.o_cur[0].gridTypeId,
                gridId: dbResult.o_cur[0].gridId,
                roundGridSid: dbResult.o_cur[0].roundGridSid,
                roundSid: dbResult.o_cur[0].roundSid,
                countryId: dbResult.o_cur[0].countryId,
            }
        }

        return this._gridTypes[ctyGridSid]
    }

    /**********************************************************************************************
     * @method getIndicatorListBySource
     *********************************************************************************************/
    public async getIndicatorListBySource(source: string): Promise<IDBIndicator[]> {
        if (!this._indicators[source]) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }

            if (source) {
                options.params.push({ name: 'p_source', type: STRING, value: source })
            }

            const dbResult = await DataAccessApi.execSP('idr_getters.getIndicatorListBySource', options)
            this._indicators[source] = dbResult.o_cur
        }
        return this._indicators[source]
    }

    /**********************************************************************************************
     * @method getDataTypes
     *********************************************************************************************/
    public async getDataTypes(): Promise<IDataType[]> {
        if (!this._dataTypes) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }

            const dbResult = await DataAccessApi.execSP('gd_getters.getDataTypes', options)
            this._dataTypes = dbResult.o_cur
        }

        return this._dataTypes
    }


    /**********************************************************************************************
     * @method getHelpMessages
     *********************************************************************************************/
    public async getHelpMessages(helpMsgTypeId: HelpMsgType): Promise<IHelpMessage[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_help_msg_type_id', type: STRING, value: helpMsgTypeId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('idr_getters.getHelpMessages', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getLinesData
     *********************************************************************************************/
    public async getLinesData(
        rounds: number[], countries: string[], lines: string[]
    ): Promise<Array<Array<string|number>>> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sids', type: NUMBER, value: rounds },
                { name: 'p_country_ids', type: STRING, value: countries },
                { name: 'p_line_ids', type: STRING, value: lines },
            ],
            arrayFormat: true,
            maxRows: 1000,
        }
        const dbResult = await DataAccessApi.execSP('gd_grid_data.getLinesData', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getOptionalCellsMap
     *********************************************************************************************/
    public async getOptionalCellsMap(): Promise<IGridOptionalCells> {
        if (!this._optionalCells) {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await DataAccessApi.execSP('gd_getters.getOptionalCells', options)

            this._optionalCells = dbResult.o_cur.reduce((acc: IGridOptionalCells, cell: IDBOptionalCell) => {
                acc[cell.lineSid] = acc[cell.lineSid] || {}
                acc[cell.lineSid][cell.colSid] = true
                return acc
            }, {})
        }

        return this._optionalCells
    }

    /**********************************************************************************************
     * @method getRoundsLines
     *********************************************************************************************/
    public async getRoundsLines(roundSids: number[], allColumns = false): Promise<IDBRoundsLine[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sids', type: NUMBER, value: roundSids },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        if (allColumns) {
            options.params.push({ name: 'p_all_columns', type: NUMBER, value: 1});
        }

        const dbResult = await DataAccessApi.execSP('gd_getters.getRoundsLines', options)

        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getGridsExportDefinition
     *********************************************************************************************/
    public async getGridsExportDefinition(
        countryId: string, gridVersionType: GridVersionType, gridId: string, roundSid: number
    ): Promise<IFiscExportData> {
        const data: IFiscGridData[] = await this.getGridsDataForExcel(countryId, gridVersionType, gridId, roundSid)
        const definitions: IFiscGridDefinition[] = await this.getGridsDefinitions(gridId, true, roundSid)
        const ctyRoundScale: IScale = await this.getCountryRoundScale(countryId, roundSid) // ctyRoundScale value
        return {
            data: this.convertToGridCells(countryId, gridVersionType, data, ctyRoundScale),
            definitions
        }
    }

    /**********************************************************************************************
     * @method newCountryVersion
     *********************************************************************************************/
    public async newCountryVersion(countryId: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_grid_data.newCtyVersion`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method patchCountryGridData
     *********************************************************************************************/
    public async patchCountryGridData(
        countryId: string, ctyGridSid: number, gridVersionType: GridVersionType,
        lines: number[], cols: number[], data: string[]
    ): Promise<number> {

        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_cty_grid_sid', type: NUMBER, value: ctyGridSid },
                { name: 'p_grid_version_type', type: STRING, value: gridVersionType },
                { name: 'p_lines', type: NUMBER, value: lines },
                { name: 'p_cols', type: NUMBER, value: cols },
                { name: 'p_data', type: STRING, value: data },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`gd_grid_data.patchCtyGridData`, options)
        return dbResult.o_res
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method isNotEmpty
     *********************************************************************************************/
    private isNotEmpty(data: string): boolean {
        return !!data?.trim()
    }

    /**********************************************************************************************
     * @method getGridsDataForExcel
     *********************************************************************************************/
    private async getGridsDataForExcel(
        countryId: string, gridVersionType: GridVersionType, gridId: string, roundSid: number
    ): Promise<IFiscGridData[]> {

        let result: IFiscGridData[] = []

        // load normal grids data
        roundSid = roundSid || (await this.getCurrentGridRound()).roundSid

        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_grid_id', type: STRING, dir: BIND_IN, value: gridId || null },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'p_version', type: NUMBER, dir: BIND_IN, value: 0 },
                { name: 'p_grid_version_type', type: STRING, dir: BIND_IN, value: gridVersionType },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_grid_data.getCtyGridCells', options)
        if (dbResult.o_cur) {
            result = result.concat(dbResult.o_cur)
        }

        // load divergence grid data
        const ctyGridSids: number[] = await this.getDivergenceCtyGridSids(roundSid, countryId, gridId)
        for (const ctyGridSid of ctyGridSids) {
            const gridInfo: IGridTypeInfo = await this.getGridTypeInfo(ctyGridSid)
            const divGridData: IFiscGridData[] = await this.getCountryDivergenceGridData(gridInfo, gridVersionType)
            result = result.concat(divGridData)
        }

        return result
    }

    /**********************************************************************************************
     * @method getGridNames
     *********************************************************************************************/
    private async getGridNames(
        gridId: string, includeReadOnlyGrids: boolean, roundSid: number
    ): Promise<IDBGridName[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_grid_id', type: STRING, dir: BIND_IN, value: gridId || null},
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: this.appId },
                { name: 'p_ro_grids', type: NUMBER, dir: BIND_IN, value: includeReadOnlyGrids ? 1 : 0 },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_round_sid', type: NUMBER, value: roundSid || null },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_uploads.getTemplateGrids', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getGridNames
     *********************************************************************************************/
    private async getCountryGridNames(countryId: string, gridId: string): Promise<IDBCtyGridName[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_grid_id', type: STRING, dir: BIND_IN, value: gridId || null},
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: this.appId },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_uploads.getCountryGrids', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getGridNames
     *********************************************************************************************/
    private convertToGridCells(countryId: string, gridVersionType: GridVersionType,
                               gridsData: IFiscGridData[], scale: IScale): ICtyGridData {
        const gridCells: ICtyGridCells = {}

        gridsData.forEach((gridData) => {
            let cell: ICtyGridLineCells = gridCells[gridData.gridId]
            if (!cell) {
                cell = {}
                gridCells[gridData.gridId] = cell
            }

            let values: ICtyGridValues = cell[gridData.lineId]
            if (!values) {
                values = {}
                cell[gridData.lineId] = values
            }

            if (!values[gridData.colSid]) {
                values[gridData.colSid] = {
                    cellValue: gridData.cellValue,
                    gridVersionType: gridData.gridVersionType,
                    footnote: gridData.footnote ? gridData.footnote : undefined
                }
            }
        })

        return {
            countryId,
            gridCells,
            gridVersionType,
            scale
        }
    }

    /**********************************************************************************************
     * @method prepareCache
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private prepareCache(cache: any): any {
        return Object.getOwnPropertyNames(cache).length > this.maxCacheSize ? {} : cache
    }

    /**********************************************************************************************
     * @method evaluateCopyLineRule
     *********************************************************************************************/
    private async evaluateCopyLineRule(countryId: string, roundSid: number, line: IGridLine,
                                       yearCols: IGridCol[], gridVersionType: GridVersionType, cells: ICells) {
        const lineIds: string[] = line.copyLineRule.split(/[+-]/)
        const calcParams: string[] = line.calcRule.split(':')

        const lineCells: ILineCells = await this.getApplicationLineCells(
            countryId, roundSid, gridVersionType, calcParams[0] as EApps, calcParams[1], lineIds
        )
        if (cells[line.lineSid] === undefined) {
            cells[line.lineSid] = {}
        }

        yearCols.forEach(col => {
            let rule: string = line.copyLineRule
            let sign = 1
            let value = 0
            lineIds.forEach(lineId => {
                const index: number = rule.indexOf(lineId)
                if (index > 0) {
                    sign = rule.substr(index - 1, 1) === '-' ? -1 : 1
                }
                rule = rule.replace(lineId, '')
                value += sign * (lineCells[lineId] ? +lineCells[lineId][col.yearValue] : NaN)
            })

            if (!isNaN(value)) {
                cells[line.lineSid][col.colSid] = {
                    lineId: line.lineId,
                    yearValue: col.yearValue,
                    value
                }
            }
        })
    }

    /**********************************************************************************************
     * @method evaluateCalculationRule
     *********************************************************************************************/
    private evaluateCalculationRule(line: IGridLine,
                                    lines: IGridLine[],
                                    yearCols: IGridCol[],
                                    cells: ICells) {
        const lineIds: string[] = line.calcRule.split(/[+-]/)
        const lineIdToLineSid: ILineIdToLineSid = lines.reduce((acc, l) => {
            acc[l.lineId] = l.lineSid
            return acc
        }, {})

        let rule: string = line.calcRule
        let sign = 1
        lineIds.forEach(lineId => {
            const lineSid = lineIdToLineSid[lineId]
            const index: number = rule.indexOf(lineId)
            if (index > 0) {
                sign = rule.substr(index - 1, 1) === '-' ? -1 : 1
            }
            if (cells[line.lineSid] === undefined) {
                cells[line.lineSid] = {}
            }
            yearCols.forEach(col => {
                const value: number = lineSid && cells[lineSid] && cells[lineSid][col.colSid] ?
                    (sign * (cells[lineSid][col.colSid].value)) : NaN
                if (cells[line.lineSid][col.colSid] === undefined) {
                    cells[line.lineSid][col.colSid] = {
                        lineId: line.lineId,
                        yearValue: col.yearValue,
                        value
                    }
                } else {
                    cells[line.lineSid][col.colSid].value += value
                }
            })
            rule = rule.replace(lineId, '')
        })
    }

    /**********************************************************************************************
     * @method getApplicationLineCells
     *********************************************************************************************/
    private async getApplicationLineCells(
        countryId: string,
        roundSid: number,
        gridVersionType: GridVersionType,
        appId: EApps,
        gridId: string,
        lineIds: string[]
    ): Promise<ILineCells> {
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, dir: BIND_IN, value: appId},
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid},
                { name: 'p_grid_id', type: STRING, dir: BIND_IN, value: gridId },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'p_version', type: NUMBER, dir: BIND_IN, value: 0 },
                { name: 'p_grid_version_type', type: STRING, dir: BIND_IN, value: gridVersionType },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_grid_data.getApplicationCtyGridCells', options)
        return dbResult.o_cur
            .filter(gridData => lineIds.includes(gridData.lineId))
            .reduce((acc: ILineCells, gridData) => {
                acc[gridData.lineId] = acc[gridData.lineId] || {}
                acc[gridData.lineId][gridData.yearValue] = this.getCellValue(gridData.cellValue)
                return acc
            }, {})
    }

    /**********************************************************************************************
     * @method getCellValue
     *********************************************************************************************/
    private getCellValue(value: string, ): string {
        let numeric: number = null
        if (value !== null && value !== undefined) {
            if (value.indexOf('¼') > -1) numeric = Number(value.replace('¼', '.25'))
            else if (value.indexOf('½') > -1) numeric = Number(value.replace('½', '.5'))
            else if (value.indexOf('¾') > -1) numeric = Number(value.replace('¾', '.75'))
            else if (value.indexOf(' to ') > 0) {
                const tmp = value.split(' to ')
                if (tmp.length === 2) {
                    numeric = (Number(this.getCellValue(tmp[0])) + Number(this.getCellValue(tmp[1]))) / 2.0
                }
            }
        }

        return numeric !== null ? numeric.toString() : value
    }

    /**********************************************************************************************
     * @method getDivergenceCtyGridSids
     *********************************************************************************************/
    private async getDivergenceCtyGridSids(roundSid: number, countryId: string, gridId: string): Promise<number[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_country_id', type: STRING, dir: BIND_IN, value: countryId },
                { name: 'p_grid_id', type: STRING, dir: BIND_IN, value: gridId || null },
                { name: 'p_version', type: NUMBER, dir: BIND_IN, value: 0 },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_uploads.getDivergenceCtyGridSids', options)
        return dbResult.o_cur.map(value => value.ctyGridSid)
    }

    /**
     * Copy line rule must be in format: <App_ID>:<grid_ID>
     * @param calcRule
     */
    private isCopyLineRule(calcRule: string): boolean {
        return this.isNotEmpty(calcRule) && calcRule.split(':').length > 1
    }

}
