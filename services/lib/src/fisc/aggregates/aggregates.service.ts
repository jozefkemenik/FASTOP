import { BIND_IN, BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { EApps } from 'config'
import { RequestService } from '../../request.service'
import { SharedLibService } from '../shared/shared-lib.service'

import {
    IAggregateParameters,
    ICalculatedAggregate,
    IDBAggregateVariable,
    IDBCellValue,
    IDBLevel,
    IDBVariable,
    IDBVariableVector
} from '.'

export class AggregatesService extends SharedLibService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps, private readonly params: IAggregateParameters) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getVariables
     *********************************************************************************************/
    public async getVariables(roundSid: number, variableIds?: string[]): Promise<IDBVariable[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_area_id', type: STRING, dir: BIND_IN, value: this.params.eaArea },
                { name: 'p_variable_ids', type: STRING, dir: BIND_IN, value: variableIds || []},
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('agg_getters.getVariables', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getGridCellValues
     *********************************************************************************************/
    public async getGridCellValues(roundSid: number, lineIds: string[]): Promise<IDBCellValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_line_ids', type: STRING, dir: BIND_IN, value: lineIds },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('agg_getters.getGridCells', options)
        return dbResult.o_cur || []
    }

    /**********************************************************************************************
     * @method getIndicatorVectors
     *********************************************************************************************/
    public async getIndicatorVectors(roundSid: number, indicatorIds: string[]): Promise<IDBVariableVector[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_area', type: STRING, dir: BIND_IN, value: this.params.countryArea },
                { name: 'p_indicator_ids', type: STRING, dir: BIND_IN, value: indicatorIds },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('agg_getters.getIndicatorVectors', options)
        return dbResult.o_cur || []
    }

    /**********************************************************************************************
     * @method getAggregatedVectors
     *********************************************************************************************/
    public async getAggregatedVectors(roundSid: number, variableIds: string[]): Promise<IDBVariableVector[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_variable_ids', type: STRING, dir: BIND_IN, value: variableIds },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('agg_getters.getAggregatedVectors', options)
        return dbResult.o_cur || []
    }

    /**********************************************************************************************
     * @method getLevels
     *********************************************************************************************/
    public async getLevels(roundSid: number): Promise<IDBLevel[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, dir: BIND_IN, value: roundSid },
                { name: 'p_line_id', type: STRING, dir: BIND_IN, value: this.params.nominalCode },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP('agg_getters.getLevels', options)
        return dbResult.o_cur || []
    }

    /**********************************************************************************************
     * @method saveAggregatedLines
     *********************************************************************************************/
    public async saveAggregatedLines(roundSid: number, countryAreaId: string,
                                     variables: IDBAggregateVariable[], user: string): Promise<number> {
        return this.saveAggregatedVariables(roundSid, countryAreaId, variables, user, 'saveAggLines')
    }

    /**********************************************************************************************
     * @method saveAggregatedIndicators
     *********************************************************************************************/
    public async saveAggregatedIndicators(roundSid: number, countryAreaId: string,
                                          variables: IDBAggregateVariable[], user: string): Promise<number> {
        return this.saveAggregatedVariables(roundSid, countryAreaId, variables, user, 'saveAggIndicators')
    }

    /**********************************************************************************************
     * @method calculateAggregates
     *********************************************************************************************/
    public async calculateAggregates(startYear: number, endYear: number,
                                     /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                                     variables: any[]): Promise<ICalculatedAggregate> {
        const promises = Array.from(new Set([this.params.countryArea, this.params.eaArea])).map(
            cg => this.getCountryGroupDefinition(cg)
        )

        const countryGroups = await Promise.all(promises).then(countryGroupDefs => {
            return countryGroupDefs.reduce((acc, val) => {
                acc[val.countryGroupId] = val.countries
                return acc
            }, {})
        })

        const body = { startYear, endYear, countryGroups, variables }
        return RequestService.request(EApps.FDMSSTAR, `/calc/aggregate`, 'post', body)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method saveAggregatedVariables
     *********************************************************************************************/
    private async saveAggregatedVariables(roundSid: number,
                                          countryAreaId: string,
                                          variables: IDBAggregateVariable[],
                                          user: string,
                                          procedureName: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_round_sid', type: NUMBER, value: roundSid },
                { name: 'p_area', type: STRING, value: countryAreaId },
                { name: 'p_variables', type: 'VECTORARRAY', value: variables },
                { name: 'p_user', type: STRING, value: user },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }

        const dbResult = await DataAccessApi.execSP(`agg_data.${procedureName}`, options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method getCountryGroupDefinition
     *********************************************************************************************/
    private async getCountryGroupDefinition(countryGroupId: string): Promise<ICountryGroupDefinition> {
        return {
            countryGroupId,
            countries: await this.getCountryCodes(countryGroupId)
        }
    }
}

interface ICountryGroupDefinition {
    countryGroupId: string
    countries: string[]
}
