import { GridType, GridVersionType } from '../../../../shared-lib/dist/prelib/fisc-grids'
import { IDataType, IGrid, IHelpMessage, IIndicator } from '../shared'
import { CountryStatusApi } from '../../api/country-status.api'
import { EApps } from 'config'
import { HelpMsgType } from '../help/shared-interfaces'
import { IError } from '../../error.service'
import { IScale } from '../../measure'

import {
    ICountryDefaultLevels,
    ICountryGridData,
    IDBCountryDefaultLevel,
    IDBCountryGridData,
    IDBRoundsLine,
    IDownloadCSVParams,
    IFiscCtyGridDefinition,
    IFiscExportData,
    IFiscGridData,
    IFiscGridDefinition,
    IGridTypeInfo,
    IRoundsLine,
} from '.'
import { FiscGridService } from './grid.service'

export abstract class FiscGridController<S extends FiscGridService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(
        protected readonly appId: EApps,
        protected readonly gridService: S,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method copyCtyGridVersion
     *********************************************************************************************/
    public copyCtyGridVersion(
        countryId: string, ctyGridSid: number, fromVersion: string, toVersion: string
    ) {
        return ctyGridSid
            ? this.gridService.copyCtyGridVersion(countryId, ctyGridSid, fromVersion, toVersion)
                .catch(this.exceptionHandler('copyCtyGridVersion'))
            : this.gridService.copyVersionToAnother(countryId, fromVersion, toVersion)
                .catch(this.exceptionHandler('copyVersionToAnother'))
    }

    /**********************************************************************************************
     * @method downloadCSV
     *********************************************************************************************/
    public downloadCSV(params: IDownloadCSVParams): Promise<Array<Array<string|number>>> {
        const header = [
            'Application', 'Year of the application', 'Country code', 'Indicator code',
            'Version', 'Year of the value', 'Type of data', 'Value'
        ]
        return Promise.all([
            params.lineIds && params.lineIds.length ?
                this.gridService.getLinesData(
                    params.roundSids, params.countryIds, params.lineIds
                ) : Promise.resolve([]),
            params.calculated && params.calculated.length ?
                this.gridService.getIndicatorsForCSV(
                    params.roundSids, params.countryIds, params.calculated, 'Calculated'
                ).then(this.vectorToRows) : Promise.resolve([]),
            params.ameco && params.ameco.length ?
                this.gridService.getIndicatorsForCSV(
                    params.roundSids, params.countryIds, params.ameco, 'Ameco'
                ).then(this.vectorToRows) : Promise.resolve([]),
        ]).then(
            res => [header].concat(res[0], [[]], res[1], [[]], res[2]),
            this.exceptionHandler('downloadCSV')
        )
    }

    /**********************************************************************************************
     * @method getCountryGrid
     *********************************************************************************************/
    public getCountryGrid(
        countryId: string, gridId: string, roundSid: number, version: number
    ) {
        return this.gridService.getCountryGrid(countryId, gridId, roundSid, version)
            .catch(this.exceptionHandler('getCountryGrid'))
    }

    /**********************************************************************************************
     * @method getCountryGridData
     *********************************************************************************************/
    public async getCountryGridData(
        countryId: string, ctyGridSid: number, gridVersionType: GridVersionType, ctyDesk: boolean,
    ): Promise<[ICountryGridData, ICountryGridData, ICountryDefaultLevels]> {
        let compareWithVersion = GridVersionType.PUBLIC
        if (gridVersionType === GridVersionType.PUBLIC) {
            compareWithVersion = ctyDesk ? GridVersionType.COUNTRY_DESK : GridVersionType.NUMERIC
        }

        const gridInfo: IGridTypeInfo = await this.gridService.getGridTypeInfo(ctyGridSid)
        const isDivergence = gridInfo.gridType === GridType.DIVERGENCE
        const gridData = isDivergence ? [
            this.getCountryDivergenceDBGridData(gridInfo, gridVersionType),
            Promise.resolve([]),
        ] : [
            this.gridService.getCountryGridData(countryId, ctyGridSid, gridVersionType),
            this.gridService.getCountryGridData(countryId, ctyGridSid, compareWithVersion),
        ]

        return Promise.all([
            ...gridData,
            this.gridService.getCountryDefaultLevels(ctyGridSid),
            this.gridService.getCountryRoundScaleByCtyGrid(ctyGridSid)
        ]).then(
            result => [
                this.gridToObject(result[0] as IDBCountryGridData[]),
                this.gridToObject(result[1] as IDBCountryGridData[]),
                this.levelsToObject(result[2] as IDBCountryDefaultLevel[], (result[3] as IScale)?.id)
            ],
            this.exceptionHandler('getCountryGridData')
        )
    }

    /**********************************************************************************************
     * @method getCountryGridsDefinitions
     *********************************************************************************************/
    public getCountryGridsDefinitions(countryId: string, gridId: string): Promise<IFiscCtyGridDefinition[]> {
        return this.gridService.getCountryGridsDefinitions(countryId, gridId)
            .catch(this.exceptionHandler('getCountryGridsDefinitions'))
    }

    /**********************************************************************************************
     * @method getCurrentCountryVersion
     *********************************************************************************************/
    public getCurrentCountryVersion(countryId: string): Promise<number> {
        return this.gridService.getCurrentCountryVersion(countryId)
            .catch(this.exceptionHandler('getCurrentCountryVersion'))
    }

    /**********************************************************************************************
     * @method getCountryVersions
     *********************************************************************************************/
    public getCountryVersions(countryId: string, roundSid: number): Promise<number[]> {
        return this.gridService.getCountryVersions(countryId, roundSid)
            .catch(this.exceptionHandler('getCountryVersions'))
    }

    /**********************************************************************************************
     * @method getGridCols
     *********************************************************************************************/
    public getGridCols(roundGridSid: number) {
        return this.gridService.getGridCols(roundGridSid)
            .catch(this.exceptionHandler('getGridCols'))
    }

    /**********************************************************************************************
     * @method getGridLines
     *********************************************************************************************/
    public getGridLines(roundGridSid: number) {
        return this.gridService.getGridLines(roundGridSid)
            .catch(this.exceptionHandler('getGridLines'))
    }

    /**********************************************************************************************
     * @method getGrids
     *********************************************************************************************/
    public getGrids(roundSid: number): Promise<IGrid[]> {
        return this.gridService.getGrids(roundSid)
            .catch(this.exceptionHandler('getGrids'))
    }

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public getIndicators(source: string): Promise<IIndicator[]> {
        return this.gridService.getIndicatorListBySource(source)
            .catch(this.exceptionHandler('getIndicators'))
    }

    /**********************************************************************************************
     * @method getDataTypes
     *********************************************************************************************/
    public getDataTypes(): Promise<IDataType[]> {
        return this.gridService.getDataTypes()
            .catch(this.exceptionHandler('getDataTypes'))
    }

    /**********************************************************************************************
     * @method getIndicatorsForCSV
     *********************************************************************************************/
    public  getIndicatorsForCSV(
        csvParams: IDownloadCSVParams
        ): Promise<Array<Array<string|number>>> {
        return this.gridService.getIndicatorsForCSV(csvParams.roundSids,
                csvParams.countryIds,
                csvParams.ameco && csvParams.ameco.length ? csvParams.ameco : csvParams.calculated,
                csvParams.ameco && csvParams.ameco.length ? 'Ameco' : 'Calculated')
            .catch(this.exceptionHandler('getIndicatorsForCSV'))
    }

    /**********************************************************************************************
     * @method getHelpMessages
     *********************************************************************************************/
    public getHelpMessages(helpMsgTypeId: HelpMsgType): Promise<IHelpMessage[]> {
        return this.gridService.getHelpMessages(helpMsgTypeId)
            .catch(this.exceptionHandler('getHelpMessages'))
    }

    /**********************************************************************************************
     * @method getRoundsLines
     *********************************************************************************************/
    public getRoundsLines(roundSids: number[], allColumns = false): Promise<IRoundsLine[]> {
        return this.gridService.getRoundsLines(roundSids, allColumns).then(
            this.normaliseLines.bind(this),
            this.exceptionHandler('getRoundsLines')
        )
    }

    /**********************************************************************************************
     * @method getTemplateGridDefinition
     *********************************************************************************************/
    public getTemplateGridDefinition(gridId: string): Promise<IFiscGridDefinition[]> {
        return this.gridService.getGridsDefinitions(gridId, false)
            .catch(this.exceptionHandler('downloadGridTemplate'))
    }

    /**********************************************************************************************
     * @method getCountryRoundScale
     *********************************************************************************************/
    public getCountryRoundScale(ctyGridSid: number): Promise<IScale> {
        return this.gridService.getCountryRoundScaleByCtyGrid(ctyGridSid)
            .catch(this.exceptionHandler('getCountryRoundScale'))
    }

    /**********************************************************************************************
     * @method saveCountryRoundScale
     *********************************************************************************************/
    public saveCountryRoundScale(countryId: string, roundSid: number, scaleId: string): Promise<number> {
        return this.gridService.saveCountryRoundScale(countryId, roundSid, scaleId)
            .catch(this.exceptionHandler('getCountryRoundScale'))
    }

    /**********************************************************************************************
     * @method getGridsExportDefinition
     *********************************************************************************************/
    public getGridsExportDefinition(
        countryId: string, gridVersionType: GridVersionType, gridId: string, roundSid: number
    ): Promise<IFiscExportData> {
        return this.gridService.getGridsExportDefinition(countryId, gridVersionType, gridId, roundSid)
            .catch(this.exceptionHandler('exportGrids'))
    }

    /**********************************************************************************************
     * @method newCountryVersion
     *********************************************************************************************/
    public newCountryVersion(countryId: string): Promise<number> {
        return this.gridService.newCountryVersion(countryId)
            .catch(this.exceptionHandler('newCountryVersion'))
    }

    /**********************************************************************************************
     * @method patchCountryGridData
     *********************************************************************************************/
    public patchCountryGridData(
        countryId: string, ctyGridSid: number, gridVersionType: GridVersionType, data: ICountryGridData
    ): Promise<number> {
        const lines: number[] = []
        const cols: number[] = []
        const values: string[] = []

        for (const line in data) {
            if (!Object.prototype.hasOwnProperty.call(data, line)) continue
            for (const col in data[line]) {
                if (!Object.prototype.hasOwnProperty.call(data[line], col)) continue
                lines.push(Number(line))
                cols.push(Number(col))
                values.push(data[line][col])
            }
        }
        return this.gridService.patchCountryGridData(
            countryId, ctyGridSid, gridVersionType, lines, cols, values
        ).then(
            result => {
                if (result > 0) {
                    CountryStatusApi.setStatusChangeDate(this.appId, countryId, {statusChange: 'Input'})
                }
                return result
            },
            this.exceptionHandler('patchCountryGridData')
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method exceptionHandler
     *********************************************************************************************/
    protected exceptionHandler(methodName: string, className = 'FiscGridController') {
        return (err: IError) => {
            err.method = `${className}.${methodName}`
            throw err
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method gridToObject
     *********************************************************************************************/
    private gridToObject(data: IDBCountryGridData[]) {
        return data ? data.reduce((acc, d) => {
            acc[d.LINE_SID] = acc[d.LINE_SID] || {}
            acc[d.LINE_SID][d.COL_SID] = d.cellValue
            return acc
        }, {}) : {}
    }

    /**********************************************************************************************
     * @method levelsToObject transform DefaultLevels to object + rebase with scale
     *********************************************************************************************/
    private levelsToObject(data: IDBCountryDefaultLevel[], scaleId: string) {  
        const scaleMatrix = { // constains value of exponent to be applied when compare (when null, no scaling!)
            "Millions": {
                "Millions": 0,
                "Billions": 3
            },
            "Billions": {
                "Millions": -3,
                "Billions": 0
            }
        }
        const scaleExp = scaleMatrix[scaleId] ?? {}
        return data ? data.reduce((acc, d) => {
            acc[d.LINE_SID] = acc[d.LINE_SID] || {}
                // scale the value by multiplying it by 10^exponent value from matrix (if not found=0; 10^0=1)
                acc[d.LINE_SID][d.COL_SID] = d.VALUE * (10**(scaleExp[d.SCALE_ID] ?? 0))
            return acc
        }, {}) : {}
    }

    /**********************************************************************************************
     * @method getCountryDivergenceDBGridData
     *********************************************************************************************/
    private async getCountryDivergenceDBGridData(gridInfo: IGridTypeInfo,
                                                 gridVersionType: GridVersionType): Promise<IDBCountryGridData[]> {
        const fiscData: IFiscGridData[] = await this.gridService.getCountryDivergenceGridData(gridInfo, gridVersionType)
        return fiscData.map(value =>  {
            return {
                LINE_SID: value.lineSid,
                COL_SID: value.colSid,
                cellValue: value.cellValue
            }
        })
    }

    /**********************************************************************************************
     * @method vectorToRows
     *********************************************************************************************/
    private vectorToRows(rowsData: Array<Array<string|number>>): Array<Array<string|number>> {
        return rowsData.reduce((acc: Array<Array<string|number>>, row) => {
            const startYear = Number(row[3])
            const vector = row[4] as string
            if (vector) {
                acc.push(...vector.split(',').map((value, idx) =>
                    row.slice(0, 3).concat('NA', startYear + idx, 'DATA', value)))
            } else acc.push(row.slice(0, 3))
            return acc
        }, [])
    }

    /**********************************************************************************************
     * @method normaliseLines
     *********************************************************************************************/
    private normaliseLines(lines: IDBRoundsLine[]): IRoundsLine[] {
        return lines.map(line => Object.assign(line, {
            IS_MANDATORY: line.IS_MANDATORY === 1,
            IN_DD: line.IN_DD === 'Y',
            IN_LT: line.IN_LT === 'Y',
            IN_AGG: line.IN_AGG === 'Y'
        }))
    }
}
