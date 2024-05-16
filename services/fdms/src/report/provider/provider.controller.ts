import { ICompressedData, IIndicator, IIndicatorCodeMapping, IIndicatorData } from '../shared-interfaces'
import { ICountry } from '../../../../lib/dist/menu'
import { ProviderService } from './provider.service'
import { SharedService } from '../../shared/shared.service'
import { catchAll } from '../../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class ProviderController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly providerService: ProviderService,
        private readonly sharedService: SharedService
    ) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviderData
     *********************************************************************************************/
    public async getProviderData(
        periodicityId: string, roundSid: number, storageSid: number, custTextSid: number,
        providerIds: string[], countryIds?: string[], indicatorIds?: string[], compress?: boolean,
    ): Promise<IIndicatorData[] | ICompressedData> {
        return this.sharedService.getCompressedIndicatorsData(
            providerIds, countryIds, indicatorIds, periodicityId, roundSid, storageSid, custTextSid, compress
        )
    }

     /**********************************************************************************************
     * @method getProviderDataByKeys
     *********************************************************************************************/
     public async getProviderDataByKeys(
        providerIds: string[],
        keys: string[],
        roundSid: number,
        storageSid: number,
        custTextSid: number,
        compress?: boolean,
    ): Promise<IIndicatorData[] | ICompressedData> {
         return this.sharedService.getProvidersIndicatorDataByKeys(
             providerIds, keys, roundSid, storageSid, custTextSid, compress
         )
    }

    /**********************************************************************************************
     * @method getProviderCountries
     *********************************************************************************************/
    public async getProviderCountries(providerIds: string[]): Promise<ICountry[]> {
        return this.providerService.getProviderCountries(providerIds)
    }

    /**********************************************************************************************
     * @method getProviderIndicators
     *********************************************************************************************/
    public async getProviderIndicators(providerIds: string[], periodicity: string): Promise<IIndicator[]> {
        return this.providerService.getProviderIndicators(providerIds, periodicity)
    }

    /**********************************************************************************************
     * @method getProviderIndicatorsMappings
     *********************************************************************************************/
    public async getProviderIndicatorsMappings(
        providerIds: string[], periodicity: string
    ): Promise<IIndicatorCodeMapping[]> {
        return this.providerService.getProviderIndicatorsMappings(providerIds, periodicity)
    }
}
