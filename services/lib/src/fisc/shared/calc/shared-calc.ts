import { EApps } from 'config'

import { OGCalculationSource, WorkbookGroup } from '../../../../../shared-lib/dist/prelib/fisc-grids'
import { CountryStatusApi } from '../../../api/country-status.api'
import { IOutputGapIndicator } from '../../output-gaps'

import {
    ICalculatedIndicatorValidation,
    IDBCalculatedIndicator,
    ILine,
    ILineVector,
    ISemiElasticity,
    IVector,
    IVectorRange,
} from '.'
import { SharedCalcService } from './shared-calc.service'

export class SharedCalc<S extends SharedCalcService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _numberOptionalYears: number
    private _roundYear: number
    private _ratsInputYears: number
    private _countryStatus: string
    private _yearsRange: number

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly _countryId: string,
        protected readonly roundSid: number,
        protected readonly calcService: S,
        protected readonly user?: string,
        protected readonly scpRoundSid?: number
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get countryId(): string {
        return this._countryId
    }

    public get ratsInputYears$(): Promise<number> {
        if (this._ratsInputYears !== undefined) return Promise.resolve(this._ratsInputYears)

        return Promise.all([this.yearsRange$, this.numberOptionalYears$]).then(([yearsRange, optionalYears]) => {
                this._ratsInputYears = yearsRange + optionalYears
                return this._ratsInputYears

        })
    }

    public get countryStatus$(): Promise<string> {
        if (this._countryStatus !== undefined) return Promise.resolve(this._countryStatus)

        return CountryStatusApi.getCountryStatusId(
            this.appId, this.countryId, {roundSid: this.roundSid}
        ).then(result => {
            this._countryStatus = result
            return this._countryStatus
        })
    }

    protected get yearsRange$(): Promise<number> {
        if (this._yearsRange !== undefined) return Promise.resolve(this._yearsRange)

        return this.calcService.getYearsRange(this.appId).then(yearsRange => {
            this._yearsRange = yearsRange
            return this._yearsRange
        })
    }

    protected get numberOptionalYears$(): Promise<number> {
        if (this._numberOptionalYears !== undefined) return Promise.resolve(this._numberOptionalYears)

        return Promise.all([
            this.roundYear$,
            this.getLineVector('T01aL01'),
            this.yearsRange$,
        ]).then(([roundYear, lineVector, yearsRange]) => {
            this._numberOptionalYears = lineVector.startYear ?
                (lineVector.values[roundYear + yearsRange] ? 1 : 0) +
                (lineVector.values[roundYear + yearsRange + 1] ? 1 : 0) : 0
            return this._numberOptionalYears
        })
    }

    protected get roundYear$(): Promise<number> {
        if (this._roundYear) return Promise.resolve(this._roundYear)

        return this.calcService.getRoundYear(this.roundSid).then(year => {
            this._roundYear = year
            return year
        })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method validateCalculatedIndicator
     *********************************************************************************************/
    public async validateCalculatedIndicator(code: string): Promise<ICalculatedIndicatorValidation> {
        const ratsId = ratsMapping[code]
        const [roundYear, line, optionalYears, yearsRange] = await Promise.all([
            this.roundYear$,
            this.calcService.getLineByRatsId(ratsId, this.roundSid),
            this.numberOptionalYears$,
            this.yearsRange$,
        ])
        const vector = await this.getLineStringVector(line.LINE_ID, roundYear, yearsRange + optionalYears)

        return {
            code,
            line_id: line.LINE_ID,
            descr: line.DESCR,
            hasError: vector?.replace(/null|undefined|,/g, '').trim() === '',
        }
    }

    /**********************************************************************************************
     * @method getCalculatedIndicators
     *********************************************************************************************/
    public getCalculatedIndicators(indicators: string[], startYear: number): Promise<IOutputGapIndicator[]> {
        return this.calcService.getCalculatedIndicators(
            this.countryId,
            [OGCalculationSource.RATS, OGCalculationSource.CALC],
            indicators.map(indicator => `${indicator}.ecfin`),
            this.roundSid,
        ).then(calculatedIndicators => calculatedIndicators.map(ci => {
            const vector =
                Array.from({length: ci.START_YEAR > startYear ? ci.START_YEAR - startYear : 0}, () => 'n.a.')
                    .concat(ci.VECTOR.split(','))
                    .slice(startYear > ci.START_YEAR ? startYear - ci.START_YEAR : 0)

            return {descr: ci.DESCR, vector, source: ci.SOURCE, indicatorId: ci.INDICATOR_ID, orderBy: ci.ORDER_BY}
        }))
    }

    /**********************************************************************************************
     * @method getLineVector gets line data as vector object and start year of the vector
     *********************************************************************************************/
    public async getLineVector(lineId: string): Promise<ILineVector> {
        const lineData = await this.calcService.getLineDataNoLevel(this.appId, lineId, this.countryId, this.roundSid)
        return {
            startYear: lineData.length ? lineData[0].YEAR + lineData[0].YEAR_VALUE : 0,
            values: lineData.reduce((acc, line) => {
                acc[line.YEAR + line.YEAR_VALUE] = line.VALUE_CD
                return acc
            }, {})
        }
    }

    /**********************************************************************************************
     * @method getVectorRange
     *********************************************************************************************/
    public async getVectorRange(): Promise<IVectorRange> {
        const [optionalYears, roundYear, yearsRange] =
            await Promise.all([this.numberOptionalYears$, this.roundYear$, this.yearsRange$])
        return {
            startYear: roundYear - 11,
            yearsCount: 11 + yearsRange + optionalYears,
        }
    }

    /**********************************************************************************************
     * @method getRatsLastChangeDate
     *********************************************************************************************/
    public getRatsLastChangeDate(): Promise<Date> {
        return this.calcService.getCalculatedIndicatorLastChangeDate('OG.ecfin', this.countryId, this.roundSid)
    }

    /**********************************************************************************************
     * @method getEcfinLastChangeDate
     *********************************************************************************************/
    public getEcfinLastChangeDate(): Promise<Date> {
        return this.calcService.getCalculatedIndicatorLastChangeDate('SB.ecfin', this.countryId, this.roundSid)
    }

    /**********************************************************************************************
     * @method getSemiElasticityValue
     *********************************************************************************************/
    public getSemiElasticityValue(): Promise<number> {
        return this.calcService.getSemiElasticityInfo(this.countryId, this.roundSid).then(
            semiElasticity => semiElasticity.VALUE
        )
    }

    /**********************************************************************************************
     * @method getSemiElasticityInfo
     *********************************************************************************************/
     public getSemiElasticityInfo(): Promise<ISemiElasticity> {
        return this.calcService.getSemiElasticityInfo(this.countryId, this.roundSid)
    }

    /**********************************************************************************************
     * @method getAmecoLastChangeDate
     *********************************************************************************************/
    public getAmecoLastChangeDate(): Promise<Date> {
        return this.calcService.getAmecoLastChangeDate(this.countryId, this.roundSid)
    }

    /**********************************************************************************************
     * @method getAmecoIndicators
     *********************************************************************************************/
    public getAmecoIndicators(indicators: string[]): Promise<IDBCalculatedIndicator[]> {
        return this.calcService.getAmecoIndicators(this.countryId, indicators, this.roundSid)
    }

    /**********************************************************************************************
     * @method getRequiredLinesForWorkbook
     *********************************************************************************************/
    public getRequiredLinesForWorkbook(useScpRound: boolean, workbookGroupId: WorkbookGroup): Promise<ILine[]> {
        return this.calcService.getRequiredLinesForWorkbook(
            workbookGroupId,
            useScpRound ? this.scpRoundSid : this.roundSid,
        )
    }

    /**********************************************************************************************
     * @method getLinesWithCountryDeskValues
     *********************************************************************************************/
    public getLinesWithCountryDeskValues(useScpRound: boolean, lines: string[]): Promise<string[]> {
        return this.calcService.getGridLinesWithCountryDeskValues(
            useScpRound ? this.scpRoundSid : this.roundSid,
            this.countryId,
            lines,
        )
    }

    /**********************************************************************************************
     * @method getScpCountryStatus
     *********************************************************************************************/
    public getScpCountryStatus(): Promise<string> {
        return CountryStatusApi.getCountryStatusId(EApps.SCP, this.countryId, {roundSid: this.scpRoundSid})
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getLineStringVector
     *********************************************************************************************/
    protected async getLineStringVector(lineId: string, startYear: number, numYears: number): Promise<string> {
        const vector = await this.getLineTableVector(lineId, startYear, numYears)
        return vector.values.join()
    }

    /**********************************************************************************************
     * @method getLineTableVector
     *********************************************************************************************/
    protected async getLineTableVector(lineId: string, startYear: number, numYears: number): Promise<IVector> {
        const vector = await this.getLineVector(lineId)
        return {
            startYear,
            values: Array.from({length: numYears}, (_, idx) => startYear + idx).map(year => vector.values[year])
        }
    }
}

export const ratsMapping = {
    NETD: '_G_SLED',
    OVGD: '_G_GDP',
    OIGT: '_G_INV',
    ZUTN: '_LUR',
    // G_AH has never been defined before (not sure its in scopax/dbp), so using "_undefined_G_AH"
    // this should force NAs in rats download, which it should be able to deal with
    _undefined_G_AH: '_G_AH',
    NLHA9: '_G_AH1',
    HWCDW: '_WINF',
    UWCD: '_WINF1',
    UBLGE: '_BB',
    UYIGE: '_INT',
    UOOMS: '_OO',
    UIGT: '_IN',
    PCPH: '_PCE',
}
