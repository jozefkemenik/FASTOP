import { ISdmxCode, ISdmxStructure } from '../../../lib/dist/sdmx/shared-interfaces'
import { Level, LoggingService } from '../../../lib/dist'
import { ISdmxDatasetData } from './shared-interfaces'
import { SdmxService } from './sdmx.service'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class SdmxController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(private readonly sdmxService: SdmxService, private logs: LoggingService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDatasets
     *********************************************************************************************/
    public async getDatasets(): Promise<ISdmxCode[]> {
        return this.sdmxService.getDatasets()
    }

    /**********************************************************************************************
     * @method getDatasetStructure
     *********************************************************************************************/
    public async getDatasetStructure(dataset: string): Promise<ISdmxStructure> {
        return this.sdmxService.getDatasetStructure(dataset)
    }

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    public async getData(dataset: string, queryKey: string, startPeriod?: string): Promise<ISdmxDatasetData> {
        return this.sdmxService.getData(dataset, queryKey, startPeriod)
    }

    /**********************************************************************************************
     * @method getDataByKeys
     *********************************************************************************************/
    public async getDataByKeys(dataset: string, keys: string[], startPeriod?: string): Promise<ISdmxDatasetData> {

        const promises = await Promise.allSettled(
            keys.map(series => this.sdmxService.getData(
                dataset, series, startPeriod
            ))
        )

        const result: ISdmxDatasetData = {
            sdmx: {
                names: [],
                data: [],
            },
            dataset
        }
        keys.forEach((key, index) => {
            const promiseResult = promises[index]
            if (promiseResult.status === 'fulfilled') {
                result.sdmx.names = promiseResult.value.sdmx.names
                result.sdmx.data.push(...promiseResult.value.sdmx.data)
            } else if (promiseResult.status === 'rejected') {
                this.logs.log(
                    `Failed to get data for dataset: ${dataset}, key: ${key}. Result: ${JSON.stringify(promiseResult)}`,
                    Level.ERROR
                )
            }
        })

        return result
    }
}
