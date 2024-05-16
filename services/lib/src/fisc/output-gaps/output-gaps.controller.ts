import { EApps } from 'config'
import { EStatusRepo } from 'country-status'

import { IAmecoValidation, ICalculatedIndicatorValidation, ILineVector, ISemiElasticity, IVectorRange } from '../shared/calc'
import {
    IBaselineData,
    IBaselineDefinition,
    IBaselineUpload,
    ICountryParamsData,
    ICountryParamsDefinition,
    ICountryParamsUpload,
    IGeneralParamValue
} from 'output-gaps'
import { CountryStatusApi } from '../../api/country-status.api'
import { EucamLightApi } from '../../api/eucam-light.api'
import { OGCalculationSource } from '../../../../shared-lib/dist/prelib/fisc-grids'
import { RequestService } from '../../request.service'
import { SharedCalc } from '../shared/calc/shared-calc'
import { SharedCalcController } from '../shared/calc/shared-calc.controller'

import {
    IBSEValidation,
    IEcfinValidation,
    IEucamLightVersion,
    IMemberStateValidation,
    IOutputGapIndicator,
    IOutputGapResult,
    IOutputGapUpload,
    IOutputGapValidation,
} from '.'
import { LibOutputGapsService } from './output-gaps.service'

const amecoIndicators = ['UBLGE', 'UYIGE', 'UOOMS'].map(idr => `1.0.319.0.${idr}`)
const msIndicators = ['NETD', 'OVGD', 'OIGT', 'ZUTN', 'HWCDW', 'UWCD', 'UBLGE', 'UYIGE', 'UOOMS']
const calculatedIndicators = ['OG', 'CAB', 'CAPB', 'UOOMS', 'SB', 'SPB']
const ratsInputIndicators: Record<string, string> = {
    _G_AH: '',
    _WINF: 'T01cL07',
    _G_SLED: 'T01cL01',
    _G_AH1: 'T01cL02',
    _WPOPW: '',
    _G_INV: 'T01aL05',
    _G_GDP: 'T01aL01',
    _PCE: 'T01bL02',
    _BB: 'T02aL01',
    _IN: '',
    _OO: 'T02aL11',
    _WINF1: 'T01cL06',
    _INT: 'T02aL09',
    _LUR: 'T01cL03',
}

export class LibOutputGapsController extends SharedCalcController<LibOutputGapsService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {
        super(new LibOutputGapsService(appId))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getYearsRange
     *********************************************************************************************/
    public async getYearsRange(): Promise<number> {
        return this.calcService.getYearsRange(this.appId)
    }

    /**********************************************************************************************
     * @method updateYearsRange
     *********************************************************************************************/
    public async updateYearsRange(yearsRange: number): Promise<number> {
        return this.calcService.updateYearsRange(yearsRange)
    }

    /**********************************************************************************************
     * @method getChangeY
     *********************************************************************************************/
    public async getChangeY(roundSid: number): Promise<number> {
        return RequestService.request(
            EApps.OG,
            `/upload/changeY/${roundSid}`,
            'get',
        )
    }

    /**********************************************************************************************
     * @method updateChangeY
     *********************************************************************************************/
    public async updateChangeY(roundSid: number, changeY: number): Promise<number> {
        return RequestService.request(
            EApps.OG,
            `/upload/changeY/${roundSid}`,
            'put',
            { changeY },
        )
    }

    /**********************************************************************************************
     * @method getMemberStateGridLines
     *********************************************************************************************/
    public async getMemberStateGridLines(countryId: string, roundSid: number): Promise<string[]> {
        const result: string[] = []
        const calc = new SharedCalc(this.appId, countryId, roundSid, this.calcService)
        const indicatorsMap: Record<string, string> = this.getRatsInputIndicators()

        const vectorsMap: Map<string, ILineVector> = new Map<string, ILineVector>()
        const ratsIdsList = Object.getOwnPropertyNames(indicatorsMap)
        for (const ratsId of ratsIdsList) {
            if (indicatorsMap[ratsId] !== '') {
                vectorsMap.set(ratsId, await calc.getLineVector(indicatorsMap[ratsId]))
            }
        }
        const ratsYears = await calc.ratsInputYears$
        const startYear = await this.calcService.getRoundYear(roundSid)
        const endYear = startYear + ratsYears

        let header = `${countryId}_Y`
        for (let year = startYear; year < endYear; year++) {
            header += `,${year}`
        }
        result.push(header)

        ratsIdsList.forEach(ratsId => {
            let row = `${countryId}${ratsId}`
            const vector: ILineVector = vectorsMap.get(ratsId)
            for (let i = startYear; i < endYear; i++) {
                let value = vector && vector.values[i] ? vector.values[i] : undefined
                if (!this.vectorHasValue(value)) value = '#N/A'
                row += `,${value}`
            }
            result.push(row)
        })

        return result
    }

    /**********************************************************************************************
     * @method calculateStructuralBalance
     *********************************************************************************************/
    public calculateStructuralBalance(countryId: string, roundSid: number, user: string): Promise<number> {
        return RequestService.request(
            EApps.OG,
            `/calc/structuralBalance/${this.appId}/${user}/${countryId}/${roundSid}`,
            'put',
        )
    }

    /**********************************************************************************************
     * @method calculateOutputGap
     *********************************************************************************************/
    public async calculateOutputGap(countryId: string, roundSid: number, user: string): Promise<IOutputGapResult> {
        const gridLines = await this.getMemberStateGridLines(countryId, roundSid)
        if (!gridLines || gridLines.length === 0) {
            return { successful: false, message: 'Missing member states grids data!' }
        }

        try {
            const outputGap = await EucamLightApi.calculateOutputGap(countryId, gridLines)

            return this.uploadOutputGap(countryId, roundSid, user, outputGap)
        } catch (err) {
            let message = 'Output gap calculation procedure failed due to internal error! – Please Contact the IT Unit R3'
            switch (err.statusCode) {
                case 400: message = 'Failed to prepare the input country desk data! – Please Contact the IT Unit R3'
                    break
                case 403: message = 'User is not authorised to perform this action.'
                    break
                /* eslint-disable-next-line max-len */
                case 422: message = 'Eucam_light calculation failed due to internal error! – Please contact the OutputGap team in Unit B3 (Anna Thum – Francois Blondeau)'
                    break
                default:
                    if (err.cause && err.cause.errno === 'ECONNREFUSED') {
                        message = 'Could not run the calculation. Python server is down! – Please Contact the IT Unit R3'
                    }
                    break
            }
            return { successful: false, message }
        }
    }

    /**********************************************************************************************
     * @method getBaselineDefinition
     *********************************************************************************************/
    public async getBaselineDefinition(): Promise<IBaselineDefinition> {
        return RequestService.request(
            EApps.OG,
            '/upload/baseline/def',
            'get',
        )
    }

    /**********************************************************************************************
     * @method getBaselineData
     *********************************************************************************************/
    public async getBaselineData(roundSid: number): Promise<IBaselineData[]> {
        return RequestService.request(
            EApps.OG,
            `/upload/baseline/data/${roundSid}`,
            'get',
        )
    }

    /**********************************************************************************************
     * @method uploadBaselineData
     *********************************************************************************************/
    public async uploadBaselineData(roundSid: number, data: IBaselineUpload[]): Promise<number> {
        return RequestService.request(
            EApps.OG,
            `/upload/baseline/${roundSid}`,
            'post',
            data,
        )
    }

    /**********************************************************************************************
     * @method getCountryParamsDefinition
     *********************************************************************************************/
    public async getCountryParamsDefinition(): Promise<ICountryParamsDefinition> {
        return RequestService.request(
            EApps.OG,
            '/upload/countryParams/def',
            'get',
        )
    }

    /**********************************************************************************************
     * @method getCountryParamsData
     *********************************************************************************************/
    public async getCountryParamsData(roundSid: number): Promise<ICountryParamsData[]> {
        return RequestService.request(
            EApps.OG,
            `/upload/countryParams/data/${roundSid}`,
            'get',
        )
    }

    /**********************************************************************************************
     * @method uploadCountryParameters
     *********************************************************************************************/
    public async uploadCountryParameters(roundSid: number, data: ICountryParamsUpload[]): Promise<number> {
        return RequestService.request(
            EApps.OG,
            `/upload/countryParams/${roundSid}`,
            'post',
            data,
        )
    }

    /**********************************************************************************************
     * @method getGeneralParams
     *********************************************************************************************/
    public async getGeneralParams(roundSid: number): Promise<IGeneralParamValue[]> {
        return RequestService.request(
            EApps.OG,
            `/upload/generalParams/${roundSid}`,
            'get',
        )
    }

    /**********************************************************************************************
     * @method uploadGeneralParameters
     *********************************************************************************************/
    public uploadGeneralParameters(roundSid: number, data: IGeneralParamValue[]): Promise<number> {
        return RequestService.request(
            EApps.OG,
            `/upload/generalParams/${roundSid}`,
            'post',
            data,
        )
    }

    /**********************************************************************************************
     * @method validate
     *********************************************************************************************/
    public async validate(countryId: string, roundSid: number): Promise<IOutputGapValidation> {
        const calc = new SharedCalc(this.appId, countryId, roundSid, this.calcService)
        const [memberState, ecfin, ameco, bse, ctyStatus] = await Promise.all([
            this.validateMSIndicators(calc),
            this.validateCalculatedIndicators(calc),
            this.validateAmecoIndicators(calc),
            this.validateBSE(calc, roundSid),
            calc.countryStatus$
        ])

        return {
            hasErrors: this.checkHasErrors(memberState, ameco, bse),
            memberState,
            ecfin,
            ameco,
            bse,
            ctyStatus,
        }
    }

    /**********************************************************************************************
     * @method validateForLinkedTables
     *********************************************************************************************/
    public async validateForLinkedTables(countryId: string, roundSid: number): Promise<boolean> {
        const calc = new SharedCalc(this.appId, countryId, roundSid, this.calcService)
        const [memberState, ameco, bse] = await Promise.all([
            this.validateMSIndicators(calc),
            this.validateAmecoIndicators(calc),
            this.validateBSE(calc, roundSid),
        ])

        return !this.checkHasErrors(memberState, ameco, bse)
    }

    /**********************************************************************************************
     * @method getEucamLightVersion
     *********************************************************************************************/
    public getEucamLightVersion(): Promise<IEucamLightVersion> {
        return EucamLightApi.getEucamLightVersion()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRequiredAmecoIndicators
     *********************************************************************************************/
    protected async getRequiredAmecoIndicators(): Promise<string[]> {
        return amecoIndicators
    }

    /**********************************************************************************************
     * @method getRatsInputIndicators
     *********************************************************************************************/
    protected getRatsInputIndicators(): Record<string, string> {
        return ratsInputIndicators
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method checkHasErrors
     *********************************************************************************************/
    private checkHasErrors(
        memberState: IMemberStateValidation, ameco: IAmecoValidation, bse: IBSEValidation,
    ): boolean {
        return memberState.hasErrors || ameco.hasErrors || bse.hasErrors
    }

    /**********************************************************************************************
     * @method validateMSIndicators
     *********************************************************************************************/
    private async validateMSIndicators(calc: SharedCalc<LibOutputGapsService>): Promise<IMemberStateValidation> {
        const msValidation: IMemberStateValidation = {
            hasErrors: false,
            gridLines: []
        }
        const extraIndicators: string[] = []
        try {
            const tkp = (await EucamLightApi.getTKPCountries()).map(cty => cty.toUpperCase())
            if (!tkp.includes(calc.countryId)) extraIndicators.push('PCPH')
        } catch {
            // not a big deal, no extra indicators
        }
        const indicators = msIndicators.concat(extraIndicators)
        const indValidation: ICalculatedIndicatorValidation[] = await Promise.all<ICalculatedIndicatorValidation>(
            indicators.map(calc.validateCalculatedIndicator.bind(calc))
        )

        indValidation.forEach(rookInput => {
            if (rookInput.hasError) msValidation.hasErrors = true
            msValidation.gridLines.push({
                hasError: rookInput.hasError,
                lineId: rookInput.line_id,
                lineDesc: rookInput.descr,
                code: rookInput.code
            })
        })
        msValidation.gridLines.sort((a, b) => a.lineId.localeCompare(b.lineId))

        return msValidation
    }

    /**********************************************************************************************
     * @method validateCalculatedIndicators
     *********************************************************************************************/
    private async validateCalculatedIndicators(calc: SharedCalc<LibOutputGapsService>): Promise<IEcfinValidation> {
        const range: IVectorRange = await calc.getVectorRange()
        const calculatedDbIndicators: IOutputGapIndicator[] =
            await calc.getCalculatedIndicators(calculatedIndicators, range.startYear)
        const map = !calculatedDbIndicators ? {} : calculatedDbIndicators.reduce((acc, value) => {
            acc[value.indicatorId] = value
            return acc
        }, {})

        const ecfinValidation: IEcfinValidation = {
            hasErrors: false,
            hasOG: false,
            range,
            indicators: [],
            ratsLastUpdated: await calc.getRatsLastChangeDate(),
            ecfinLastUpdated: await calc.getEcfinLastChangeDate()
        }

        for (const indicatorId of calculatedIndicators) {
            const dbIndicator: IOutputGapIndicator = map[`${indicatorId}.ecfin`]
            const isUOOMS = indicatorId === 'UOOMS'
            if (dbIndicator) {
                if (indicatorId === 'OG') ecfinValidation.hasOG = true
                ecfinValidation.indicators.push({
                    indicatorId: dbIndicator.indicatorId,
                    descr: dbIndicator.descr,
                    vector: dbIndicator.vector,
                    source: isUOOMS ? OGCalculationSource.ECFIN : dbIndicator.source,
                    orderBy: dbIndicator.orderBy
                })
            } else if (!isUOOMS) {
                ecfinValidation.hasErrors = true
            }
        }

        ecfinValidation.indicators.sort((a, b) => (a.orderBy || Number.MAX_VALUE) - (b.orderBy || Number.MAX_VALUE))

        return ecfinValidation
    }

    /**********************************************************************************************
     * @method validateBSE
     *********************************************************************************************/
    private async validateBSE(calc: SharedCalc<LibOutputGapsService>, roundSid: number): Promise<IBSEValidation> {
        const bse: ISemiElasticity = await calc.getSemiElasticityInfo()
        let msg: string
        if (roundSid !== bse.ROUND_SID) {
            msg = "This BSE was taken from round: " + bse.PERIOD_DESCR + ' ' + bse.YEAR + ' (' + bse.DESCR + ')'
        }
        return {
            hasErrors: bse === null || isNaN(bse.VALUE),
            value: bse.VALUE,
            message: msg
        }
    }

    /**********************************************************************************************
     * @method validateOgParams
     *********************************************************************************************/
    private async validateOgParams(roundSid: number, countryId: string): Promise<boolean> {
        return Promise.all([this.calcService.checkBaselineData(roundSid, countryId),
                           this.calcService.checkCountryParamsData(roundSid, countryId)
                          ]).then( ([res1, res2]) => res1 && res2)
    }

    /**********************************************************************************************
     * @method uploadOutputGap
     *********************************************************************************************/
    private async uploadOutputGap(countryId: string,
                                  roundSid: number,
                                  user: string,
                                  data: IOutputGapUpload): Promise<IOutputGapResult> {

        const result: IOutputGapResult = {
            successful: false
        }

        const ctyStatus: EStatusRepo = await CountryStatusApi.getCountryStatusId(this.appId, countryId, {roundSid})
        if (this.calcService.canModifyCountry(ctyStatus)) {
            const commonParams = {
                p_round_sid: roundSid,
                p_country_id: countryId,
                p_start_year: data.startYear,
                p_last_change_user: user,
                p_source: OGCalculationSource.RATS
            }

            const ogIndSid: number = (await this.calcService.getIndicatorById('OG.ecfin')).INDICATOR_SID
            const res: number = await this.calcService.uploadCalculatedIndicatorData(
                Object.assign({ p_indicator_sid: ogIndSid,
                    p_vector: data.ygapVector
                }, commonParams)
            )
            result.successful = res > 0
            if (!result.successful) result.message = 'OG.ecfin indicator not found!'

            if (data.wypotVector) {
                const potgIndSid = (await this.calcService.getIndicatorById('potg.ecfin')).INDICATOR_SID
                await this.calcService.uploadCalculatedIndicatorData(
                    Object.assign({ p_indicator_sid: potgIndSid,
                        p_vector: data.wypotVector
                    }, commonParams)
                )
            }
        } else {
            result.message = `Country state is: ${ctyStatus} and cannot be modified!`
        }

        return result
    }
}
