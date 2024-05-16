import { EApps } from 'config'

import {
    IMeasureTable,
    IMeasuresRange,
    IPublicMeasures,
    IReportData,
    IResidual,
    ITransparencyReport
} from '../../../lib/dist/measure'
import { calculateTotalResidual } from '../../../shared-lib/dist/dxm-report'

import { IMeasureDetails } from '.'
import { SharedService } from '../shared/shared.service'

export class TransparencyReportService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly sharedService: SharedService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method generateTransparencyReport
     *********************************************************************************************/
    public async generateTransparencyReport(
        countryId: string,
        range: IMeasuresRange,
        data: IMeasureTable<IMeasureDetails>,
        roundSid?: number
    ): Promise<ITransparencyReport> {
        const [roundPeriod, currencyInfo]  = await Promise.all([
            this.sharedService.getRoundPeriod(this.appId, roundSid),
            this.sharedService.getCountryCurrencyInfo(countryId, roundSid, null)
        ])

        return {
            countryId,
            reportRange: this.getTransparencyReportRange(roundPeriod.year, range),
            oneOffs: await this.sharedService.getOneOff(),
            esaCodes: await this.sharedService.getESACodes(roundPeriod.roundSid),
            reportData: await this.prepareReportData(countryId, data),
            scale: currencyInfo?.descr,
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method prepareReportData
     *********************************************************************************************/
    private async prepareReportData(countryId: string, data: IMeasureTable<IMeasureDetails>): Promise<IReportData> {
        const publicMeasures: IPublicMeasures = {}
        const publicYears: number[] = []
        let publicMeasuresCount = 0

        const gdpPonderation = await this.sharedService.getGDPPonderation(countryId)
        const countryMultipliers = await this.sharedService.getCountryMultipliers()

        const residualValues = calculateTotalResidual<IMeasureDetails>(
            data.measures, gdpPonderation[countryId],
            countryMultipliers[countryId].multi,
            (m: IMeasureDetails) => m.IS_PUBLIC !== 1
        )

        data.measures.forEach((measure: IMeasureDetails) => {
            if (measure.IS_PUBLIC === 1) {
                if (publicMeasures[measure.YEAR] === undefined) {
                    publicMeasures[measure.YEAR] = []
                    publicYears.push(measure.YEAR)
                }
                publicMeasuresCount++
                publicMeasures[measure.YEAR].push(measure)
            }
        })

        const residual: IResidual = residualValues.raw.reduce( (acc, value, idx) => {
            acc[data.startYear + idx] = value
            return acc
        }, {})
        const gdpResidual: IResidual = residualValues.gdp.reduce( (acc, value, idx) => {
            acc[data.startYear + idx] = value
            return acc
        }, {})

        return {
            publicMeasures,
            publicMeasuresCount,
            publicYears: publicYears.sort( (a, b) => a - b),
            residual,
            gdpResidual,
            startYear: data.startYear
        }
    }

    /**********************************************************************************************
     * @method getTransparencyReportRange
     *********************************************************************************************/
    private getTransparencyReportRange(year: number, range: IMeasuresRange) {
        return range && range.startYear ? range : { startYear: year - 1, yearsCount: 3 }
    }
}
