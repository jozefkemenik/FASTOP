import { EApps } from 'config'
import { ISetStatusChangeDate } from 'country-status'

import { CountryStatusApi } from '../../../lib/dist/api/country-status.api'

import { Calc } from './calc'
import { CalcService } from './calc.service'
import { ICalcParams } from '.'

const indicators = ['UBLGE', 'UYIGE', 'UOOMS']
export class CalcController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private calcService: CalcService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method calcStructuralBalance
     *********************************************************************************************/
    public async calcStructuralBalance(appId: EApps, user: string, countryId: string, roundSid: number) {
        const ctyStatus: string = await CountryStatusApi.getCountryStatusId(appId, countryId, {roundSid})
        if (this.calcService.canModifyCountry(ctyStatus)) {
            const calc = new Calc(appId, countryId, roundSid, this.calcService, user)
            return Promise.all([calc.getInputIndicators(indicators), calc.getSemiElasticityValue()])
                .then(results => calc.calculateCAB(...results))
                .then(calc.calculateCAPB.bind(calc))
                .then(calc.calculateSB.bind(calc))
                .then(calc.calculateSPB.bind(calc))
                .then(() => {
                    const setChangeDate: ISetStatusChangeDate = {
                        statusChange: 'OutputGap',
                        roundKeys: {roundSid},
                    }
                    CountryStatusApi.setStatusChangeDate(appId, countryId, setChangeDate)
                    return 1
                })
        } else {
            return 0
        }
    }

    /**********************************************************************************************
     * @method getCalculationParameters
     *********************************************************************************************/
    public async getCalculationParameters(roundSid: number, countries: string[], ): Promise<ICalcParams> {
        return Promise.all([
               this.calcService.getOutputGapParam(roundSid, 'changey'),
               this.calcService.getOutputGapParam(roundSid, 'vintage_name'),
               this.calcService.getOgBaselineParamsData(roundSid, countries),
               this.calcService.getOgCountryParamsData(roundSid, countries),
            ]).then( ([changeyStr, vintageName, baseline, countryParams]) => (
                {
                    changey: Number(changeyStr),
                    vintageName,
                    baseline,
                    countryParams
                })
            )
    }
}
