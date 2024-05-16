import { EApps } from 'config'

import {
    IAggregateCalcResults,
    IBaseData,
    IDBAggregateVariable,
    IDBCellValue,
    IDBLevel,
    IDBVariable,
    IDBVariableVector,
    ILevelData,
    ILineData,
    IVariable,
    IVariableExcelParams,
    IVariableGroup,
    IVariableParams,
    IVectorData,
    IWeightVariable,
} from '.'
import { AggregatesService } from './aggregates.service'
import { IExcelExport } from '../../excel'
import { LoggingService } from '../../logging.service'

export class AggregatesController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly logs: LoggingService,
        private readonly aggregatesService: AggregatesService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getVariables
     *********************************************************************************************/
    public async getVariables(roundSid: number): Promise<IVariableGroup[]> {
        const dbVariables: IDBVariable[] = await this.aggregatesService.getVariables(roundSid)
        const map: { [key: string]: IVariable[] } = dbVariables.reduce((acc, value) => {
            const variables = acc[value.GR_DESCR] || []
            variables.push({
                code: value.AGG_TYPE_ID,
                name: value.DESCR,
                lastChangeUser: value.LAST_CHANGE_USER,
                lastChangeDate: value.LAST_CHANGE_DATE,
                aggDataSid: value.AGG_DATA_SID,
                weightIndicator: value.WEIGHT_INDICATOR,
                weightingYear: value.WEIGHTING_YEAR,
                aggType: value.AGG_TYPE,
                comparableVariableId: value.COMPARABLE_VARIABLE_ID,
            })

            acc[value.GR_DESCR] = variables

            return acc
        }, {})

        return Object.keys(map).map(key => {
            return {
                name: key,
                variables: map[key],
            }
        })
    }

    /**********************************************************************************************
     * @method exportAggregatesToExcel
     *********************************************************************************************/
    public async exportAggregatesToExcel(roundSid: number, params: IVariableExcelParams): Promise<IExcelExport[]> {
        const roundYear = await this.aggregatesService.getRoundYear(roundSid)
        const startYear = roundYear - 2
        const vectorLength = 8
        const yearArray = Array.from({ length: vectorLength }, (v, k) => `${startYear + k}`)

        const aggData: IAggregatedData = await Promise.all([
            this.getLineData(roundSid, startYear, vectorLength, params.lines),
            this.getIndicatorData(roundSid, startYear, vectorLength, params.indicators),
            this.getAggregatesData(roundSid, startYear, vectorLength, params.variables),
            this.getLevelData(roundSid),
        ]).then(([lineData, indicatorData, aggregateData, levelData]) => {
            return { lineData, indicatorData, aggregateData, levelData }
        })

        return [
            {
                worksheetName: `${this.appId.toLowerCase()}Country desk data`,
                headers: ['', 'Public', 'Country', 'Variable'].concat(yearArray),
                data: aggData.lineData
                    .filter(ld => !ld.isLevel)
                    .map(ld => [`00${ld.variableId}`, '01', ld.countryId, ld.variableId, ...ld.vectorCd])
                    .concat(
                        aggData.indicatorData.map(id => [
                            `01${id.variableId}`,
                            '01',
                            id.countryId,
                            id.variableId,
                            ...id.vector,
                        ]),
                    )
                    .concat(
                        aggData.aggregateData.map(ad => [
                            `01${ad.variableId}`,
                            '01',
                            ad.countryId,
                            ad.variableId,
                            ...ad.vector,
                        ]),
                    ),
            },
            {
                worksheetName: `${this.appId.toLowerCase()}Public data`,
                headers: ['', 'Public', 'Country', 'Variable'].concat(yearArray),
                data: aggData.lineData.map(ld => [
                    `00${ld.variableId}`,
                    '00',
                    ld.countryId,
                    ld.variableId,
                    ...ld.vectorPublic,
                ]),
            },
            {
                worksheetName: `${this.appId.toLowerCase()}Nominal GDP level data`,
                headers: ['Country', 'Value'],
                data: aggData.levelData.map(ld => [ld.countryId, ld.value]),
            },
        ]
    }

    /**********************************************************************************************
     * @method calculateAggregates
     *********************************************************************************************/
    public async calculateAggregates(
        roundSid: number,
        params: IVariableParams,
        user: string,
    ): Promise<IAggregateCalcResults> {
        const roundYear = await this.aggregatesService.getRoundYear(roundSid)
        const startYear = roundYear - 1
        const vectorLength = 3
        const weightIndicators = { '1.0.0.0.NLTN': 'POP', '1.0.99.0.UVGD': 'GDP' }
        const aggParams: IAggregateParams = await Promise.all([
            this.getLineData(
                roundSid,
                startYear,
                vectorLength,
                params.lines.map(l => l.code),
            ),
            this.getIndicatorData(
                roundSid,
                startYear,
                vectorLength,
                params.indicators.map(i => i.code),
            ),
            this.getIndicatorData(roundSid, startYear, vectorLength, Object.keys(weightIndicators)),
        ]).then(([lineData, indicatorData, weights]) => {
            return { lineData, indicatorData, weights }
        })

        const weightsVectorMap = aggParams.weights.reduce((acc, w) => {
            const key = weightIndicators[w.variableId]
            acc[key] = acc[key] || {}
            acc[key][w.countryId] = w.vector

            return acc
        }, {})

        const allVariables: IWeightVariable[] = params.indicators.concat(params.lines)
        const indicatorToWeight = allVariables.reduce((acc, v) => {
            acc[v.code] = v.weightIndicator || 'GDP'
            return acc
        }, {})

        const agg = aggParams.lineData.reduce((acc, ld) => {
            acc[ld.countryId] = acc[ld.countryId] || []
            const weights = weightsVectorMap[indicatorToWeight[ld.variableId]] || {}
            acc[ld.countryId].push({
                variableCode: ld.variableId,
                vector: ld.vectorCd,
                isLevel: ld.isLevel,
                weights: weights[ld.countryId] || [],
            })
            acc[ld.countryId].sort((a, b) => a.variableCode.localeCompare(b.variableCode))
            return acc
        }, {})

        aggParams.indicatorData.reduce((acc, id) => {
            acc[id.countryId] = acc[id.countryId] || []
            const weights = weightsVectorMap[indicatorToWeight[id.variableId]] || {}
            acc[id.countryId].push({
                variableCode: id.variableId,
                vector: id.vector,
                isLevel: false,
                weights: weights[id.countryId] || [],
            })
            acc[id.countryId].sort((a, b) => a.variableCode.localeCompare(b.variableCode))
            return acc
        }, agg)

        const variables = Object.keys(agg).map(countryId => {
            return { countryId, variables: agg[countryId] }
        })
        const calcAgg = await this.aggregatesService.calculateAggregates(
            startYear,
            startYear + vectorLength - 1,
            variables,
        )
        const results: IAggregateCalcResults = allVariables.reduce((acc, value) => {
            acc[value.code] = { calcResult: 'NO_CALC' }
            return acc
        }, {})

        const promises = []
        Object.keys(calcAgg).forEach(countryArea => {
            const aggLines = this.getAggregatedVectors(startYear, calcAgg[countryArea], aggParams.lineData)
            const aggIndicators = this.getAggregatedVectors(startYear, calcAgg[countryArea], aggParams.indicatorData)
            if (aggLines.length > 0) {
                aggLines.forEach(al => (results[al.VARIABLE_ID].calcResult = 'OK'))
                promises.push(this.aggregatesService.saveAggregatedLines(roundSid, countryArea, aggLines, user))
            }
            if (aggIndicators.length > 0) {
                aggIndicators.forEach(ai => (results[ai.VARIABLE_ID].calcResult = 'OK'))
                promises.push(
                    this.aggregatesService.saveAggregatedIndicators(roundSid, countryArea, aggIndicators, user),
                )
            }
        })

        // wait for DB updates
        await Promise.all(promises)

        // get updated variables
        const calculatedVariables = Object.keys(results).filter(code => results[code].calcResult === 'OK')
        if (calculatedVariables.length) {
            const updatedVariables: IDBVariable[] = await this.aggregatesService.getVariables(
                roundSid,
                calculatedVariables,
            )
            updatedVariables.forEach(v =>
                Object.assign(results[v.AGG_TYPE_ID], {
                    lastChangeUser: v.LAST_CHANGE_USER,
                    lastChangeDate: v.LAST_CHANGE_DATE,
                }),
            )
        }

        return results
    }

    /**********************************************************************************************
     * @method getGridCellValues
     *********************************************************************************************/
    public getGridCellValues(
        roundSid: number,
        params: IVariableExcelParams
    ): Promise<IDBCellValue[]> {
        return this.aggregatesService.getGridCellValues(roundSid, params.lines)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAggregatedVectors
     *********************************************************************************************/
    private getAggregatedVectors(
        startYear: number,
        aggregatedData: { [variableId: string]: string },
        data: IBaseData[],
    ): IDBAggregateVariable[] {
        return data
            .filter(value => aggregatedData[value.variableId])
            .map(value => {
                return {
                    VARIABLE_ID: value.variableId,
                    START_YEAR: startYear,
                    VECTOR: aggregatedData[value.variableId],
                }
            })
    }

    /**********************************************************************************************
     * @method getLineData
     *********************************************************************************************/
    private async getLineData(
        roundSid: number,
        startYear: number,
        vectorLength: number,
        lineIds: string[],
    ): Promise<ILineData[]> {
        const cellValues: IDBCellValue[] = await this.aggregatesService.getGridCellValues(roundSid, lineIds)

        const aggregated: { [key: string]: ILineData } = cellValues.reduce((acc, cell) => {
            const isLevel = cell.IS_LEVEL === 1
            const key = `${cell.LINE_ID}_${cell.COUNTRY_ID}_${isLevel}`
            acc[key] = acc[key] || {
                variableId: cell.LINE_ID,
                countryId: cell.COUNTRY_ID,
                vectorCd: Array(vectorLength).fill(''),
                vectorPublic: Array(vectorLength).fill(''),
                isLevel,
            }

            const index = cell.START_YEAR + cell.YEAR_VALUE - startYear
            if (index >= 0 && index < vectorLength) {
                acc[key].vectorCd[index] = this.getData(cell.VALUE_CD)
                acc[key].vectorPublic[index] = this.getData(cell.VALUE_P)
            }

            return acc
        }, {})

        return Object.values(aggregated).sort((a, b) => a.variableId.localeCompare(b.variableId))
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    private async getIndicatorData(
        roundSid: number,
        startYear: number,
        vectorLength: number,
        indicatorIds: string[],
    ): Promise<IVectorData[]> {
        const indVectors: IDBVariableVector[] = await this.aggregatesService.getIndicatorVectors(roundSid, indicatorIds)
        return this.mapToVectorData(startYear, vectorLength, indVectors)
    }

    /**********************************************************************************************
     * @method getAggregatesData
     *********************************************************************************************/
    private async getAggregatesData(
        roundSid: number,
        startYear: number,
        vectorLength: number,
        variableIds: string[],
    ): Promise<IVectorData[]> {
        const indVectors: IDBVariableVector[] = await this.aggregatesService.getAggregatedVectors(roundSid, variableIds)
        return this.mapToVectorData(startYear, vectorLength, indVectors)
    }

    /**********************************************************************************************
     * @method getLevelData
     *********************************************************************************************/
    private async getLevelData(roundSid: number): Promise<ILevelData[]> {
        const levels: IDBLevel[] = await this.aggregatesService.getLevels(roundSid)
        return levels.map(level => {
            return {
                countryId: level.COUNTRY_ID,
                value: this.getData(level.VALUE_CD),
            }
        })
    }

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private getData(data: any): any {
        if (data !== undefined && data !== null) {
            const numeric = Number(data)
            return isNaN(numeric) ? data : numeric
        }
        return ''
    }

    /**********************************************************************************************
     * @method mapToVectorData
     *********************************************************************************************/
    private mapToVectorData(
        startYear: number,
        vectorLength: number,
        idbVariableVectors: IDBVariableVector[],
    ): IVectorData[] {
        return idbVariableVectors
            .map(dbInd => {
                const dbVector = dbInd.VECTOR ? dbInd.VECTOR.split(',') : null

                return {
                    variableId: dbInd.VARIABLE_ID,
                    countryId: dbInd.COUNTRY_ID,
                    vector:
                        !dbVector || !dbVector.length
                            ? null
                            : Array.from({ length: vectorLength }, (v, index) => {
                                  const dbIndex = startYear - dbInd.START_YEAR + index
                                  return dbIndex > 0 && dbIndex < dbVector.length ? this.getData(dbVector[dbIndex]) : ''
                              }),
                }
            })
            .filter(vectorData => vectorData.vector !== null)
    }
}

interface IAggregatedData {
    lineData: ILineData[]
    indicatorData: IVectorData[]
    aggregateData: IVectorData[]
    levelData: ILevelData[]
}

interface IAggregateParams {
    lineData: ILineData[]
    indicatorData: IVectorData[]
    weights: IVectorData[]
}
