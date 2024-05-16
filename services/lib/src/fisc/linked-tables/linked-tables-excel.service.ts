import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { MeasureSharedService } from '../../measure'
import { SharedLibService } from '../shared/shared-lib.service'

import {
    FetchFunctionType,
    IDBAmecoData,
    IDBCalculatedData,
    IDBCountryData,
    IDBGrowthData,
    IDBLevelsData,
    IDBUPloadedData,
    ILinkedTableData,
    ILinkedTableExcelParams,
    ILinkedTableIndicatorsData,
    ILinkedTableValues,
    IYearRange,
    ProgramFunctionType,
    VariablesFunctionType,
} from '.'

export class LibLinkedTablesExcelService extends SharedLibService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static FIRST_COLUMN = '_row_name_'
    private static COUNTRY_COLUMN = 'COUNTRY'
    private static CODE_COLUMN = 'CODE'
    private static SOURCE_COLUMN = 'SOURCE'
    private static LAST_UPDATED_COLUMN = 'LAST UPDATED DATE'
    private static TRN_COLUMN = 'TRN'
    private static AGG_COLUMN = 'AGG'
    private static UNIT_COLUMN = 'UNIT'
    private static REF_COLUMN = 'REF'
    private static VARIABLE_COLUMN = 'VARIABLE'
    private static NUMERIC_COLUMN = 'NUMERIC'

    private static COUNTRY_VARIABLE = 'country'
    private static COUNTRY_ID_VARIABLE = 'countryID'
    private static PROGRAM_VARIABLE = 'program'
    private static PROGRAM_ID_VARIABLE = 'programID'
    private static CURRENT_YEAR_VARIABLE = 'current_year'
    private static MEASURES_UNIT = 'table5_unit'

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly sharedService: MeasureSharedService) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getUploadedData
     *********************************************************************************************/
    public getUploadedData(params: ILinkedTableExcelParams): Promise<ILinkedTableData> {
        return this.getLinkedTableData(
            params.countryId,
            params.roundSid,
            [
                LibLinkedTablesExcelService.FIRST_COLUMN,
                LibLinkedTablesExcelService.COUNTRY_COLUMN,
                LibLinkedTablesExcelService.CODE_COLUMN,
                LibLinkedTablesExcelService.SOURCE_COLUMN,
                LibLinkedTablesExcelService.LAST_UPDATED_COLUMN,
            ],
            params.range,
            this.fetchUploadedData,
        )
    }

    /**********************************************************************************************
     * @method getScpIndicatorsData
     *********************************************************************************************/
    public getScpIndicatorsData(params: ILinkedTableExcelParams): Promise<ILinkedTableIndicatorsData> {
        return this.getIndicatorsData(
            params.countryId,
            params.scpRoundSid,
            params.roundYear,
            params.range,
            this.getScpVariables,
        )
    }

    /**********************************************************************************************
     * @method getDbpIndicatorsData
     *********************************************************************************************/
    public async getDbpIndicatorsData(params: ILinkedTableExcelParams): Promise<ILinkedTableIndicatorsData> {
        return params.isDBP
            ? this.getIndicatorsData(
                  params.countryId,
                  params.roundSid,
                  params.roundYear,
                  params.range,
                  this.getDbpVariables,
              )
            : undefined
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicatorsData
     *********************************************************************************************/
    private async getIndicatorsData(
        countryId: string,
        roundSid: number,
        roundYear: number,
        range: IYearRange,
        variablesFunction: VariablesFunctionType,
    ): Promise<ILinkedTableIndicatorsData> {
        return {
            ameco: await this.getAmecoData(countryId, roundSid, range),
            levels: await this.getLevelsData(countryId, roundSid, range),
            calculated: await this.getCalculatedData(countryId, roundSid, range),
            growth: await this.getGrowthData(countryId, roundSid, range),
            variables: await variablesFunction.call(this, countryId, roundYear, roundSid),
        }
    }

    /**********************************************************************************************
     * @method getAmecoData
     *********************************************************************************************/
    private getAmecoData(countryId: string, roundSid: number, range: IYearRange): Promise<ILinkedTableData> {
        return this.getLinkedTableData(
            countryId,
            roundSid,
            [
                LibLinkedTablesExcelService.FIRST_COLUMN,
                LibLinkedTablesExcelService.COUNTRY_COLUMN,
                LibLinkedTablesExcelService.TRN_COLUMN,
                LibLinkedTablesExcelService.AGG_COLUMN,
                LibLinkedTablesExcelService.UNIT_COLUMN,
                LibLinkedTablesExcelService.REF_COLUMN,
                LibLinkedTablesExcelService.VARIABLE_COLUMN,
                LibLinkedTablesExcelService.SOURCE_COLUMN,
                LibLinkedTablesExcelService.LAST_UPDATED_COLUMN,
            ],
            range,
            this.fetchAmecoData,
        )
    }

    /**********************************************************************************************
     * @method getLevelsData
     *********************************************************************************************/
    private getLevelsData(countryId: string, roundSid: number, range: IYearRange): Promise<ILinkedTableData> {
        return this.getLinkedTableData(
            countryId,
            roundSid,
            [
                LibLinkedTablesExcelService.FIRST_COLUMN,
                LibLinkedTablesExcelService.NUMERIC_COLUMN,
                LibLinkedTablesExcelService.COUNTRY_COLUMN,
                LibLinkedTablesExcelService.VARIABLE_COLUMN,
            ],
            range,
            this.fetchLevelsData,
        )
    }

    /**********************************************************************************************
     * @method getCalculatedData
     *********************************************************************************************/
    private getCalculatedData(countryId: string, roundSid: number, range: IYearRange): Promise<ILinkedTableData> {
        return this.getLinkedTableData(
            countryId,
            roundSid,
            [
                LibLinkedTablesExcelService.FIRST_COLUMN,
                LibLinkedTablesExcelService.COUNTRY_COLUMN,
                LibLinkedTablesExcelService.CODE_COLUMN,
                LibLinkedTablesExcelService.SOURCE_COLUMN,
                LibLinkedTablesExcelService.LAST_UPDATED_COLUMN,
            ],
            range,
            this.fetchCalculatedData,
        )
    }

    /**********************************************************************************************
     * @method getGrowthData
     *********************************************************************************************/
    private getGrowthData(countryId: string, roundSid: number, range: IYearRange): Promise<ILinkedTableData> {
        return this.getLinkedTableData(
            countryId,
            roundSid,
            [
                LibLinkedTablesExcelService.FIRST_COLUMN,
                LibLinkedTablesExcelService.NUMERIC_COLUMN,
                LibLinkedTablesExcelService.COUNTRY_COLUMN,
                LibLinkedTablesExcelService.VARIABLE_COLUMN,
            ],
            range,
            this.fetchGrowthData,
        )
    }

    /**********************************************************************************************
     * @method getDbpVariables
     *********************************************************************************************/
    private getDbpVariables(countryId: string, roundYear: number, roundSid: number): Promise<ILinkedTableValues> {
        return this.getLinkedTableVariables(countryId, roundYear, roundSid, this.getDbpProgram)
    }

    /**********************************************************************************************
     * @method getScpVariables
     *********************************************************************************************/
    private getScpVariables(countryId: string, roundYear: number, roundSid: number): Promise<ILinkedTableValues> {
        return this.getLinkedTableVariables(countryId, roundYear, roundSid, this.getScpProgram)
    }

    /**********************************************************************************************
     * @method getDbpProgram
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private async getDbpProgram(countryId: string, roundSid: number, isInEAGroup: boolean): Promise<ILinkedTableValues> {
        const v: ILinkedTableValues = {}
        v[LibLinkedTablesExcelService.PROGRAM_VARIABLE] = 'Draft Budgetary Plan'
        v[LibLinkedTablesExcelService.PROGRAM_ID_VARIABLE] = 'DBP'
        v[LibLinkedTablesExcelService.MEASURES_UNIT] = (await this.sharedService.getDbpScale(countryId, roundSid))?.DESCRIPTION

        return v
    }

    /**********************************************************************************************
     * @method getScpProgram
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private async getScpProgram(countryId:string, roundSid: number, isInEAGroup: boolean): Promise<ILinkedTableValues> {
        const v: ILinkedTableValues = {}
        v[LibLinkedTablesExcelService.PROGRAM_VARIABLE] = isInEAGroup ? 'Stability Programme' : 'Convergence Programme'
        v[LibLinkedTablesExcelService.PROGRAM_ID_VARIABLE] = isInEAGroup ? 'SP' : 'CP'

        return v
    }

    /**********************************************************************************************
     * @method getLinkedTableVariables
     *********************************************************************************************/
    private async getLinkedTableVariables(
        countryId: string,
        roundYear: number,
        roundSid: number,
        programFunction: ProgramFunctionType,
    ): Promise<ILinkedTableValues> {
        const countryData: IDBCountryData = await this.fetchCountryData(countryId)

        const v: ILinkedTableValues = {}
        v[LibLinkedTablesExcelService.COUNTRY_VARIABLE] = countryData.countryDesc
        v[LibLinkedTablesExcelService.COUNTRY_ID_VARIABLE] = countryData.countryId
        Object.assign(v, await programFunction.call(this, countryId, roundSid, countryData.isInEAGroup === 1))

        // year should be on the last position
        v[LibLinkedTablesExcelService.CURRENT_YEAR_VARIABLE] = `${roundYear}`
        return v
    }

    /**********************************************************************************************
     * @method fetchCountryData
     *********************************************************************************************/
    private async fetchCountryData(countryId: string): Promise<IDBCountryData> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getCountryData', options)
        return dbResult.o_cur && dbResult.o_cur.length === 1 ? dbResult.o_cur[0] : null
    }

    /**********************************************************************************************
     * @method getLinkedTableData
     *********************************************************************************************/
    private async getLinkedTableData(
        countryId: string,
        roundSid: number,
        columns: string[],
        range: IYearRange,
        fetchFunction: FetchFunctionType,
    ): Promise<ILinkedTableData> {
        return {
            cols: columns.concat(
                [...Array(range.endYear - range.startYear + 1).keys()].map(x => `${x + range.startYear}`),
            ),
            rows: await fetchFunction.call(this, countryId, roundSid, range),
        }
    }

    /**********************************************************************************************
     * @method fetchUploadedData
     *********************************************************************************************/
    private async fetchUploadedData(
        countryId: string,
        roundSid: number,
        range: IYearRange,
    ): Promise<ILinkedTableValues[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getLinkedTablesUploadedData', options)
        const data: IDBUPloadedData[] = dbResult.o_cur

        return data.map((value, index) => {
            const v: ILinkedTableValues = {}
            v[LibLinkedTablesExcelService.FIRST_COLUMN] = `C${index + 2}`
            v[LibLinkedTablesExcelService.COUNTRY_COLUMN] = value.countryCd
            v[LibLinkedTablesExcelService.CODE_COLUMN] = value.indicatorId
            v[LibLinkedTablesExcelService.SOURCE_COLUMN] = value.source
            v[LibLinkedTablesExcelService.LAST_UPDATED_COLUMN] = value.lastChangeDate

            return Object.assign(v, this.getVectorValues(value.vector, value.startYear, range))
        })
    }

    /**********************************************************************************************
     * @method getVectorValues
     *********************************************************************************************/
    private getVectorValues(vector: string, startYear: number, range: IYearRange) {
        return !vector
            ? {}
            : vector.split(',').reduce((acc, value, index) => {
                  const year = startYear + index
                  if (this.vectorHasValue(value) && this.isYearBetween(year, range)) {
                      acc[year] = value
                  }

                  return acc
              }, {})
    }

    /**********************************************************************************************
     * @method isYearBetween
     *********************************************************************************************/
    private isYearBetween(year: number, range: IYearRange): boolean {
        return year >= range.startYear && year <= range.endYear
    }

    /**********************************************************************************************
     * @method fetchAmecoData
     *********************************************************************************************/
    private async fetchAmecoData(
        countryId: string,
        roundSid: number,
        range: IYearRange,
    ): Promise<ILinkedTableValues[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getLinkedTablesAmecoData', options)
        const data: IDBAmecoData[] = dbResult.o_cur

        return data.map((value, index) => {
            const v: ILinkedTableValues = {}
            v[LibLinkedTablesExcelService.FIRST_COLUMN] = `C${index + 2}&E${index + 2}&G${index + 2}`
            v[LibLinkedTablesExcelService.COUNTRY_COLUMN] = value.countryCd

            const amecoCodes = value.amecoCode.split('.')
            v[LibLinkedTablesExcelService.TRN_COLUMN] = amecoCodes[0]
            v[LibLinkedTablesExcelService.AGG_COLUMN] = amecoCodes[1]
            v[LibLinkedTablesExcelService.UNIT_COLUMN] = amecoCodes[2]
            v[LibLinkedTablesExcelService.REF_COLUMN] = amecoCodes[3]

            v[LibLinkedTablesExcelService.VARIABLE_COLUMN] = value.variable
            v[LibLinkedTablesExcelService.SOURCE_COLUMN] = value.source
            v[LibLinkedTablesExcelService.LAST_UPDATED_COLUMN] = value.lastChangeDate

            return Object.assign(v, this.getVectorValues(value.vector, value.startYear, range))
        })
    }

    /**********************************************************************************************
     * @method fetchLevelsData
     *********************************************************************************************/
    private async fetchLevelsData(
        countryId: string,
        roundSid: number,
        range: IYearRange,
    ): Promise<ILinkedTableValues[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getLinkedTablesLevelsData', options)
        const data: IDBLevelsData[] = dbResult.o_cur
        const map: Map<string, ILinkedTableValues> = new Map<string, ILinkedTableValues>()

        return data.reduce((acc, value, index) => {
            let v: ILinkedTableValues = map.get(value.key)
            if (!v) {
                v = {}
                v[LibLinkedTablesExcelService.FIRST_COLUMN] = `B${index + 2}&D${index + 2}`
                v[LibLinkedTablesExcelService.NUMERIC_COLUMN] = '01'
                v[LibLinkedTablesExcelService.COUNTRY_COLUMN] = value.countryCd
                v[LibLinkedTablesExcelService.VARIABLE_COLUMN] = value.lineId
                map.set(value.key, v)
                acc.push(v)
            }

            if (this.vectorHasValue(value.value) && this.isYearBetween(value.year, range)) {
                v[value.year] = value.value
            }

            return acc
        }, [])
    }

    /**********************************************************************************************
     * @method fetchCalculatedData
     *********************************************************************************************/
    private async fetchCalculatedData(
        countryId: string,
        roundSid: number,
        range: IYearRange,
    ): Promise<ILinkedTableValues[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getLinkedTablesCalculatedData', options)
        const data: IDBCalculatedData[] = dbResult.o_cur

        return data.map((value, index) => {
            const v: ILinkedTableValues = {}
            v[LibLinkedTablesExcelService.FIRST_COLUMN] = `C${index + 2}`
            v[LibLinkedTablesExcelService.COUNTRY_COLUMN] = value.countryCd
            v[LibLinkedTablesExcelService.CODE_COLUMN] = value.indicatorId
            v[LibLinkedTablesExcelService.SOURCE_COLUMN] = value.source
            v[LibLinkedTablesExcelService.LAST_UPDATED_COLUMN] = value.lastChangeDate

            return Object.assign(v, this.getVectorValues(value.vector, value.startYear, range))
        })
    }

    /**********************************************************************************************
     * @method fetchGrowthData
     *********************************************************************************************/
    private async fetchGrowthData(
        countryId: string,
        roundSid: number,
        range: IYearRange,
    ): Promise<ILinkedTableValues[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_id', type: STRING, value: countryId },
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
            ],
        }
        const dbResult = await DataAccessApi.execSP('gd_link_tables.getLinkedTablesGrowthData', options)
        const data: IDBGrowthData[] = dbResult.o_cur
        const map: Map<string, ILinkedTableValues> = new Map<string, ILinkedTableValues>()
        const result: ILinkedTableValues[] = data.reduce((acc, value) => {
            this.processGrowthValue(value, value.valueP, '00', range, map, acc)
            this.processGrowthValue(value, value.valueCd, '01', range, map, acc)

            return acc
        }, [])
        result.forEach((item, index) => {
            item[LibLinkedTablesExcelService.FIRST_COLUMN] = `B${index + 2}&D${index + 2}`
        })

        return result
    }

    /**********************************************************************************************
     * @method processGrowthValue
     *********************************************************************************************/
    private processGrowthValue(
        data: IDBGrowthData,
        value: string,
        numeric: string,
        range: IYearRange,
        tmpMap: Map<string, ILinkedTableValues>,
        result: ILinkedTableValues[],
    ) {
        const key = `${data.key}_${numeric}`
        let v: ILinkedTableValues = tmpMap.get(key)
        if (!v) {
            v = {}
            v[LibLinkedTablesExcelService.FIRST_COLUMN] = ''
            v[LibLinkedTablesExcelService.NUMERIC_COLUMN] = numeric
            v[LibLinkedTablesExcelService.COUNTRY_COLUMN] = data.countryCd
            v[LibLinkedTablesExcelService.VARIABLE_COLUMN] = data.lineId
            tmpMap.set(key, v)
            result.push(v)
        }

        if (this.vectorHasValue(value) && this.isYearBetween(data.year, range)) {
            v[data.year] = value
        }
    }

    /**********************************************************************************************
     * @method vectorHasValue
     *********************************************************************************************/
    private vectorHasValue(vectorValue: string): boolean {
        let hasValue = false
        if (vectorValue) {
            const normalizedValue = vectorValue.trim().toLowerCase()
            hasValue = normalizedValue !== 'n.a.' && normalizedValue !== 'na'
        }
        return hasValue
    }
}
