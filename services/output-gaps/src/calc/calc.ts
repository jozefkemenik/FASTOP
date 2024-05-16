import {
    ICalcIndicDataParams,
    ICalculatedIndicator,
    IDBCalculatedIndicator,
    IVector,
} from '../../../lib/dist/fisc/shared/calc'
import { SharedCalc, ratsMapping } from '../../../lib/dist/fisc/shared/calc/shared-calc'
import { OGCalculationSource } from '../../../shared-lib/dist/prelib/fisc-grids'

import { CalcService } from './calc.service'
import { ICalculatedIndicators } from '.'

export class Calc extends SharedCalc<CalcService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculateCAB
     *********************************************************************************************/
    public async calculateCAB(input: ICalculatedIndicators, bse: number): Promise<ICalculatedIndicators> {
        const calculated = await this.calculate(
            input.OG, -bse,
            input.UBLGE, 1,
            input.UBLGE_ms,
            'CAB', 'UBLGE', false
        )
        return Object.assign(input, calculated)
    }

    /**********************************************************************************************
     * @method calculateCAPB
     *********************************************************************************************/
    public async calculateCAPB(input: ICalculatedIndicators): Promise<ICalculatedIndicators> {
        const calculated = await this.calculate(
            input.CAB, 1,
            input.UYIGE, 1,
            input.UYIGE_ms,
            'CAPB'
        )
        return Object.assign(input, calculated)
    }

    /**********************************************************************************************
     * @method calculateSB
     *********************************************************************************************/
    public async calculateSB(input: ICalculatedIndicators): Promise<ICalculatedIndicators> {
        const calculated = await this.calculate(
            input.CAB, 1,
            input.UOOMS, -1,
            input.UOOMS_ms,
            'SB', 'UOOMS'
        )
        return Object.assign(input, calculated)
    }

    /**********************************************************************************************
     * @method calculateSPB
     *********************************************************************************************/
    public async calculateSPB(input: ICalculatedIndicators): Promise<ICalculatedIndicators> {
        const calculated = await this.calculate(
            input.CAPB, 1,
            {startYear: input.UOOMS.startYear, values: []}, -1,
            input.UOOMS,
            'SPB'
        )
        return Object.assign(input, calculated)
    }

    /**********************************************************************************************
     * @method getInputIndicators
     *********************************************************************************************/
    public getInputIndicators(indicators: string[]): Promise<ICalculatedIndicators> {
        return Promise.all([
            Promise.all(indicators.map(this.getInputIndicator)).then(results =>
                results.reduce((acc, res) => Object.assign(acc, res), {})),
            this.calcService.getAmecoIndicators(
                this.countryId,
                indicators.map(indicator => `1.0.319.0.${indicator}`),
                this.roundSid,
            ).then(this.reduceCalculatedIndicators(/[^.]*$/)),
            this.calcService.getCalculatedIndicators(
                this.countryId,
                [OGCalculationSource.RATS, OGCalculationSource.CALC],
                ['OG.ecfin'],
                this.roundSid,
            ).then(this.reduceCalculatedIndicators()),
        ]).then(results => results.reduce((acc, res) => Object.assign(acc, res), {}))
    }

    /**********************************************************************************************
     * @method preapareCalculatedIndicatorParams
     *********************************************************************************************/
    public prepareCalculatedIndicatorParams(calcIdr: ICalculatedIndicator): ICalcIndicDataParams {
        return {
            p_round_sid: this.roundSid,
            p_indicator_sid: calcIdr.indicator_sid,
            p_country_id: this.countryId,
            p_start_year: calcIdr.startYear,
            p_vector: calcIdr.vector,
            p_last_change_user: this.user,
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calculate
     *********************************************************************************************/
    private async calculate(
        ecfinVector: IVector, ecfinMultiplier: number,
        amecoVector: IVector, amecoMultiplier: number,
        msVector: IVector,
        name: string, mergedName?: string, replaceNaNs = true
    ): Promise<ICalculatedIndicators> {
        const ecfinData = this.vectorToData(ecfinVector, replaceNaNs)
        const amecoData = this.vectorToData(amecoVector, replaceNaNs)
        const msData = this.vectorToData(msVector, replaceNaNs)
        // join ameco and ms data in one vector
        const both = amecoData.slice(0, msVector.startYear - amecoVector.startYear).concat(msData)
        // normalize start year
        const normalised = both.slice(ecfinVector.startYear > amecoVector.startYear ?
            ecfinVector.startYear - amecoVector.startYear : 0)
        // set offset if ameco start year is later than ecfin start year
        const offset = amecoVector.startYear > ecfinVector.startYear ?
            amecoVector.startYear - ecfinVector.startYear : 0
        const calculated = normalised.map((x, i) =>
            this.valueToString((amecoMultiplier * x) + (ecfinMultiplier * ecfinData[i + offset])))

        let indicator = await this.calcService.getIndicatorById(`${name}.ecfin`)
        if (indicator) {
            await this.calcService.uploadCalculatedIndicatorData(
                this.prepareCalculatedIndicatorParams({
                    indicator_sid: indicator.INDICATOR_SID,
                    startYear: ecfinVector.startYear + offset,
                    vector: calculated.join(),
                })
            )
        } else return Promise.reject('Invalid indicator name')

        const ret: ICalculatedIndicators = {}
        ret[name] = {startYear: ecfinVector.startYear + offset, values: calculated}

        if (mergedName) {
            ret[mergedName] = {startYear: amecoVector.startYear, values: both.map(this.valueToString)}

            indicator = await this.calcService.getIndicatorById(`${mergedName}.ecfin`)
            if (indicator) {
                await this.calcService.uploadCalculatedIndicatorData(
                    this.prepareCalculatedIndicatorParams({
                        indicator_sid: indicator.INDICATOR_SID,
                        startYear: amecoVector.startYear,
                        vector: ret[mergedName].values.join(),
                    })
                )
            }
        }
        return ret
    }

    /**********************************************************************************************
     * @method getInputIndicator
     *********************************************************************************************/
    private getInputIndicator = async (code: string): Promise<ICalculatedIndicators> => {
        const ratsId = ratsMapping[code]
        const [roundYear, line, yearsRange, optionalYears] = await Promise.all([
            this.roundYear$,
            this.calcService.getLineByRatsId(ratsId, this.roundSid),
            this.yearsRange$,
            this.numberOptionalYears$
        ])
        const ret = {}
        ret[`${code}_ms`] = await this.getLineTableVector(line.LINE_ID, roundYear, yearsRange + optionalYears)
        return ret
    }

    /**********************************************************************************************
     * @method reduceCalculatedIndicators
     *********************************************************************************************/
    private reduceCalculatedIndicators(extractName = /^[^.]*/) {
        return (indicators: IDBCalculatedIndicator[]): ICalculatedIndicators =>
            indicators.filter(indicator => indicator.START_YEAR)
                .reduce((acc, indicator) => {
                const name = indicator.INDICATOR_ID.match(extractName)[0]
                acc[name] = {
                    startYear: indicator.START_YEAR,
                    values: indicator.VECTOR.split(',')
                }
                return acc
            }, {})
    }

    /**********************************************************************************************
     * @method valueToString
     *********************************************************************************************/
    private valueToString = (value: number): string => isNaN(value) ? 'n.a.' : value.toString()

    /**********************************************************************************************
     * @method vectorToData
     *********************************************************************************************/
    private vectorToData(vector: IVector, replaceNaNs: boolean): number[] {
        let data = vector.values.map(x => x ? Number(x) : NaN)
        if (replaceNaNs) data = data.map(x => isNaN(x) ? 0 : x)
        return data
    }
}
