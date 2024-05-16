import { IDwhIndicator, IDwhIndicatorData } from './shared-interfaces'
import { DwhService } from './dwh.service'
import { IDBDwhIndicatorData } from './dwh'
import { VectorService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class DwhController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly dwhService: DwhService,
    ) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getIndicators
     *********************************************************************************************/
    public async getIndicators(providers: string[]): Promise<IDwhIndicator[]> {
        return this.dwhService.getIndicators(providers)
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(
        providers: string[], periodicity: string, indicatorIds: string[]
    ): Promise<IDwhIndicatorData[]> {
        return this.dwhService.getIndicatorData(providers, periodicity, indicatorIds).then(
            indicators => this.normalizeIndicatorData(periodicity, indicators)
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method normalizeIndicatorData
     *********************************************************************************************/
    private normalizeIndicatorData(
        periodicity: string, datas: IDBDwhIndicatorData[]
    ): IDwhIndicatorData[] {
        if (!datas) return []
        const minYear = datas.reduce(
            (year, indicator) => Math.min(year, indicator.startYear), new Date().getFullYear())

        return datas.map(data => ({
            indicatorId: data.indicatorId,
            periodicityId: data.periodicityId,
            startYear: minYear,
            vector: this.getVector(periodicity, minYear, data.startYear, data.timeserie),
            updateDate: data.updateDate,
            updateUser: data.updateUser,
        }))
    }

    /**********************************************************************************************
     * @method getVector
     *********************************************************************************************/
    private getVector(
        periodicity: string, minYear: number, startYear: number, timeserie: string
    ): number[] {
        return VectorService.normaliseVectorStart(
            periodicity, minYear, startYear, VectorService.stringToVector(timeserie)
        )
    }
}
