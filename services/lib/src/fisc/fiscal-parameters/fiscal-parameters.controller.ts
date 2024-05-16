import { IFPDefinition, IFPUpload, IFPUploadParamsDB, IFPWorksheet, IFPWorksheetIndicatorData } from './index'
import { FiscalParametersService } from './fiscal-parameters.service'

export class FiscalParametersController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private fiscalParametersService: FiscalParametersService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTemplateDefinition
     *********************************************************************************************/
    public async getTemplateDefinition(getData = false): Promise<IFPDefinition> {
        const [countries, worksheets] = await Promise.all([
            this.fiscalParametersService.getEU27CountyCodes(),
            this.fiscalParametersService.getWorksheetDefinitions(getData),
        ])
        return { countries, worksheets }
    }

    /**********************************************************************************************
     * @method getWorksheets
     *********************************************************************************************/
    public getWorksheets(): Promise<IFPWorksheet[]> {
        return this.fiscalParametersService.getWorksheets()
    }

    /**********************************************************************************************
     * @method getWorksheetIndicatorData
     *********************************************************************************************/
    public getWorksheetIndicatorData(
        worksheetSid: number, roundSid: number
    ): Promise<IFPWorksheetIndicatorData[]> {
        return this.fiscalParametersService.getWorksheetIndicatorData(worksheetSid, roundSid)
    }

    /**********************************************************************************************
     * @method storeFiscalParams
     *********************************************************************************************/
    public async storeFiscalParams(roundSid: number, lastChangeUser: string, data: IFPUpload[]): Promise<number> {
        const params: IFPUploadParamsDB = data.reduce((acc, indicator) => {
            indicator.ctyData.reduce((ctyAcc, ctyVal) => {
                acc.indicators.push(indicator.indSid)
                acc.countries.push(ctyVal.ctyId)
                acc.startYears.push(indicator.year)
                acc.vectors.push(ctyVal.vector)
                return ctyAcc
            }, acc)

            return acc
        }, {
            roundSid,
            lastChangeUser,
            indicators: [],
            countries: [],
            startYears: [],
            vectors: [],
        })

        return this.fiscalParametersService.storeFiscalParameters(params)
    }
}
