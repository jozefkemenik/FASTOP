import { ICosnapCountry, ICosnapReport } from './model/shared-interfaces'
import { DashboardApi } from '../../../lib/dist/api'
import { ReportService } from './report.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class ReportController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private reportService: ReportService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(): Promise<ICosnapCountry[]> {
        return this.reportService.getCountryCodes().then(
            countryCodes => DashboardApi.getCountries(countryCodes).then(
                countries => countries.map(cty => ({ code: cty.COUNTRY_ID, name: cty.DESCR }))
            )
        )
    }

    /**********************************************************************************************
     * @method getReport
     *********************************************************************************************/
    public async getReport(countryId: string): Promise<ICosnapReport> {
       return this.reportService.getReport(countryId)
    }

    /**********************************************************************************************
     * @method updateText
     *********************************************************************************************/
    public async updateText(countryId: string, id: string, text: string): Promise<number> {
        return this.reportService.updateText(countryId, id, text)
    }
}
