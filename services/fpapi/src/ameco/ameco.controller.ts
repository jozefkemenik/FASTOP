import { EApps } from 'config'
import { ExternalDataApi } from '../../../lib/dist/api/external-data.api'
import { IArrayData } from './index'
import { ISdmxData } from '../../../lib/dist/sdmx/shared-interfaces'
import { LoggingService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class AmecoController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly appId: EApps,
        private readonly logs: LoggingService,
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAmecoData
     *********************************************************************************************/
    public async getAmecoData(
        datasource: string, queryKey: string, startPeriod: string, endPeriod: string
    ): Promise<IArrayData> {
        const sdmxData: ISdmxData = await ExternalDataApi.getAmecoSdmxData(
            datasource, queryKey, startPeriod, endPeriod
        )
        const [startYear, maxLength] = sdmxData.data.reduce(([currStartYear, currMaxLength], data) => {
            const years = Object.keys(data.item).map(Number).sort()
            return [Math.min(currStartYear, years[0]), Math.max(currMaxLength, years.length)]
        }, [Number.MAX_VALUE, 0])

        const years = Array.from( { length: maxLength }, (_, index) => `${startYear + index}`)
        return [sdmxData.names.concat(years)].concat(
            sdmxData.data.map(d => d.index.concat(years.map(y => `${d.item[y] ?? ''}`)))
        )
    }
}
