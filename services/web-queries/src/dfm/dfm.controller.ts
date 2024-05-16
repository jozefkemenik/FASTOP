import { DfmApi } from '../../../lib/dist/api/dfm.api'

import { IWQImpactIndicators, IWQImpactParams, IWQIndicators } from '../shared/shared-interfaces'
import { MeasureController } from '../common/measure/measure.controller'

export class DfmController extends MeasureController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountryTransferMatrix
     *********************************************************************************************/
    public async getCountryTransferMatrix(countryId: string): Promise<string> {
        const indicators: IWQIndicators = await DfmApi.getCountryTransferMatrix(countryId)
        return this.sharedService.renderTemplate('Indicator', indicators, 'dfm_indicators.pug')
    }

    /**********************************************************************************************
     * @method getCountryAdditionalImpact
     *********************************************************************************************/
    public async getCountryAdditionalImpact(countryId: string): Promise<string> {
        const indicators: IWQIndicators = await DfmApi.getCountryAdditionalImpact(countryId)
        return this.sharedService.renderTemplate('ESA code', indicators, 'dfm_indicators.pug')
    }

    /**********************************************************************************************
     * @method getImpact
     *********************************************************************************************/
    public async getImpact(params: IWQImpactParams, authorizedCountries: string[]): Promise<string> {
        // Check aggregation type
        if (!['ESA', 'OO'].includes(params.aggregationType)) {
            throw Error("Invalid aggregationType")
        }
        // Force oneOff filter to 1 when group by OO
        if (params.aggregationType === 'OO') {
            params.oneOff = 1
        }

        // Check euFunded
        if (params.euFundedIds?.length) {
            params.isEuFunded = true
        } else {
            // If not isEuFunded (=Exclude EU funded => force euFundedIds = 2 --No or -1 --null)
            if (!params.isEuFunded) {
                params.euFundedIds = [2, -1]
            } //else take all, euFundedIds = undefined (already!)
        }
   
        const indicators: IWQIndicators = await DfmApi.getImpact(params)

        // Filter the countries with authorized countries only
        indicators.indicators = indicators.indicators.filter((indicator: IWQImpactIndicators) =>
            authorizedCountries.includes(indicator.countryId)
        )

        // If isLight then return template dfm_indicators (only code, description and values columns)
        if (params.isLight) {
            return this.sharedService.renderTemplate(
                params.aggregationType === 'OO' ? 'One-off' : 'ESA code',
                indicators,
                'dfm_indicators.pug',
            )
        }

        return this.sharedService.renderTemplate(
            `DFM Measures by ${params.aggregationType === 'OO' ? "One-off" : "ESA code"}`,
            indicators,
            'dfm_impact.pug'
        )
    }    
}
