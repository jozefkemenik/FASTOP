import { EProvider, IFpapiParams, IOutput } from '../shared/shared-interfaces'
import { BadRequestError } from '../shared/errors'
import { BaseDataService } from '../shared/base.data.service'
import { FpapiDataService } from '../shared/providers/fpapi.data.service'
import { LoggingService } from '../../../lib/dist'


export class DataController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private providers: { [provider: string]: BaseDataService } = {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(private logs: LoggingService) {
        this.registerProviders(
            new FpapiDataService(this.logs)
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    public async getData(provider: EProvider, params: IFpapiParams): Promise<IOutput> {
        const service: BaseDataService = this.getDataService(provider, params)
        return service.getData(provider, params)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDataService
     * Add any logic here to find the correct data service (e.g. specific data service for provider and output format)
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    private getDataService(provider: EProvider, params: IFpapiParams): BaseDataService {
        const service = this.providers[provider]
        if (!service) {
            throw new BadRequestError(`Unsupported provider: ${provider}!`)
        }
        return service
    }

    /**********************************************************************************************
     * @method registerProviders
     *********************************************************************************************/
    private registerProviders(...services: BaseDataService[]) {
        services.forEach(
            service => service.getSupportedProviders().forEach(
                provider => this.providers[provider] = service
            )
        )
    }
}
