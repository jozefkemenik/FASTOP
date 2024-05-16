import {
    AmecoNsiType,
    IAmecoCountryCode,
    IAmecoData,
    IAmecoInputSource,
    IAmecoNsiIndicator,
} from '.'
import { AmecoApi } from '../../../lib/dist/api/ameco.api'
import { EApps } from 'config'
import { ReportService } from './report.service'
import { VectorService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class ReportController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly reportService: ReportService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoCalculatedData
     *********************************************************************************************/
    public async getAmecoCalculatedData(providerId: string, periodicityId: string): Promise<IAmecoData[]> {
        return this.reportService.getAmecoCalculatedData(providerId, periodicityId).then(
            dbData => dbData?.map(
                ({TIMESERIE_DATA, HST_TIMESERIE_DATA, SRC_TIMESERIE_DATA,LEVEL_TIMESERIE_DATA, ...rest}) => ({
                    TIMESERIE_DATA: VectorService.stringToVector(TIMESERIE_DATA),
                    HST_TIMESERIE_DATA: VectorService.stringToVector(HST_TIMESERIE_DATA),
                    SRC_TIMESERIE_DATA: VectorService.stringToVector(SRC_TIMESERIE_DATA),
                    LEVEL_TIMESERIE_DATA: VectorService.stringToVector(LEVEL_TIMESERIE_DATA),
                    ...rest
                }))
        )
    }

    /**********************************************************************************************
     * @method getAmecoDownloadCountryCodes
     *********************************************************************************************/
    public async getAmecoDownloadCountryCodes(): Promise<IAmecoCountryCode[]> {
        return AmecoApi.getAmecoDownloadCountryCodes()
    }

    /**********************************************************************************************
     * @method getAmecoInputSources
     *********************************************************************************************/
    public async getAmecoInputSources(): Promise<IAmecoInputSource[]> {
        return this.reportService.getAmecoInputSources()
    }

    /**********************************************************************************************
     * @method getAmecoNsiData
     *********************************************************************************************/
    public async getAmecoNsiData(
        periodicityId: string, countryId?: string,
    ): Promise<IAmecoNsiIndicator[]> {
        return this.reportService.getAmecoNsiData(periodicityId, countryId).then(
            (dbData) =>
                [...dbData.reduce((acc, val) => {
                    if (!acc.has(val.NSI_INDICATOR_SID)) {
                        const ind: IAmecoNsiIndicator = {
                            indicatorId: val.NSI_INDICATOR_ID,
                            countryId: val.COUNTRY_ID,
                            type: val.TYPE as AmecoNsiType,
                            periodicity: val.PERIODICITY_ID,
                            startYear: val.START_YEAR,
                            lastUpdate: val.UPDATE_DATE,
                            updatedBy: val.UPDATE_USER,
                            timeSeries: [],
                        }
                        acc.set(val.NSI_INDICATOR_SID, ind)
                    }
                    acc.get(val.NSI_INDICATOR_SID).timeSeries[val.ORDER_BY - 1] =
                        VectorService.stringToVector(val.TIMESERIE_DATA)

                    return acc
                }, new Map<number, IAmecoNsiIndicator>()).values()]
            )
    }

}
