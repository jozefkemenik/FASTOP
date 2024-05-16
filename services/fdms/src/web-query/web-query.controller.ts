import { EApps } from 'config'

import { IWQCountryIndicator, IWQCountryIndicators, IWQParams } from '../../../web-queries/src/shared/shared-interfaces'
import { DashboardApi } from '../../../lib/dist/api/dashboard.api'
import { VectorService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'

import { IDBIndicatorData } from '../report'
import { SharedService } from '../shared/shared.service'

@catchAll(__filename)
export class WebQueryController {

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
     * @method getProviderIndicators
     *********************************************************************************************/
    public async getProviderIndicators(params: IWQParams): Promise<IWQCountryIndicators> {
        const emptyResult: IWQCountryIndicators = {startYear: 0, vectorLength: -1, indicators: []}

       const countryIds: string[] =
            params.countryIds ?? (params.ctyGroup && await this.getGroupCountryIds(params.ctyGroup))
        if (countryIds?.length === 0) return emptyResult

        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        const roundSid = params.roundSid && params.storageSid ? params.roundSid : roundInfo.roundSid
        const storageSid = params.roundSid && params.storageSid ? params.storageSid : roundInfo.storageSid

        const yearsRange: number[] = params.yearsRange?.map(offset => offset + roundInfo.year)
        const indicatorData = params.providerId === 'TCE_RSLTS' ?
            await this.sharedService.getTceData(countryIds, params.indicatorIds, undefined, params.periodicity,
                                                roundSid, storageSid) :
            await this.sharedService.getProvidersIndicatorData(
            [params.providerId], countryIds, params.indicatorIds, params.periodicity, null,
            roundSid, storageSid,
        )
        if (countryIds) {
            const order = Object.fromEntries(Array.from(countryIds.entries(), ([k, v]) => [v, k]))
            indicatorData.sort((a, b) => order[a.COUNTRY_ID] - order[b.COUNTRY_ID])
        }
        const [startYear, vectorLength, indicators] = this.formatIndicatorData(
            indicatorData, params.periodicity, yearsRange
        )

        return {startYear, vectorLength, indicators}
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getGroupCountryIds
     *********************************************************************************************/
    private getGroupCountryIds(group: string) {
        return DashboardApi.getCountryGroupCountries(group)
            .then(countries => countries.map(country => country.COUNTRY_ID))
    }

    /**********************************************************************************************
     * @method formatIndicatorData
     *********************************************************************************************/
    private formatIndicatorData(
        dbData: IDBIndicatorData[], periodicity: string, yearsRange?: number[]
    ): [number, number, IWQCountryIndicator[]] {
        if (!dbData?.length) return [0, -1, []]

        const [startY, maxLength, indicators] = dbData.reduce(([start, end, ind], dbInd) => {
            const vector = dbInd.TIMESERIE_DATA.split(',').map(value => value ? Number(value) : NaN)
            ind.push({
                indicatorId: dbInd.INDICATOR_ID,
                startYear: dbInd.START_YEAR,
                scale: dbInd.SCALE_ID,
                countryId: dbInd.COUNTRY_ID,
                vector,
                updateDate: dbInd.UPDATE_DATE,
                dataType: dbInd.DATA_TYPE,
            })
            return [Math.min(start, dbInd.START_YEAR), Math.max(end, vector.length), ind]
        }, [3000, 0, [] as IWQRawIndicator[]])

        const startYear = (yearsRange && yearsRange[0]) || startY
        const mod: number = periodicity === 'M' ? 12 : (periodicity === 'Q' ? 4 : 1)
        const vectorLength = yearsRange ? (yearsRange[1] - startYear + 1) * mod : maxLength

        indicators.forEach(indicator => this.normaliseIndicatorVector(startYear, vectorLength, mod, indicator))
        return [startYear, vectorLength, indicators]
    }

    /**********************************************************************************************
     * @method normaliseIndicatorVector
     *********************************************************************************************/
    private normaliseIndicatorVector(
        normalisedStartYear: number,
        normalisedVectorLength: number,
        entriesPerYear: number,
        indicator: IWQRawIndicator,
    ): void {
        VectorService.normaliseVector(
            normalisedStartYear, normalisedVectorLength, entriesPerYear, indicator.startYear, indicator.vector
        )
        delete indicator.startYear
    }
}

interface IWQRawIndicator extends IWQCountryIndicator {
    startYear: number
}
