import { IDictionary, IIndicator, IIndicatorCode, ISearchCriteria } from './shared-interfaces'
import { EApps } from 'config'
import { IndicatorsService } from './indicators.service'
import { SharedService } from '../shared/shared.service'

export class IndicatorsController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private indicatorsService: IndicatorsService, private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDictionary
     *********************************************************************************************/
    public async getDictionary(): Promise<IDictionary> {
        return this.indicatorsService.getProviderPeriodicityIndCode().then(this.toDictionary)
    }

    /**********************************************************************************************
     * @method getIndicatorCodesData
     *********************************************************************************************/
    public async getIndicatorCodesData(param: ISearchCriteria): Promise<IIndicatorCode[]> {
        const forecast: number = param.forecast != null ? Number(param.forecast) : -1
        return this.indicatorsService.getIndicatorCodesByIds(param.indicators, forecast)
    }

    /**********************************************************************************************
     * @method getIndicatorData
     *********************************************************************************************/
    public async getIndicatorData(param: ISearchCriteria): Promise<IIndicator[]> {
        return this.indicatorsService.getIndicatorsBySidProviderPeriodicity(param.indicators, param.periodicities,param.providers)
    }

    /**********************************************************************************************
     * @method setIndicatorCodeData
     *********************************************************************************************/
    public async setIndicatorCodeData(param: IIndicatorCode): Promise<number> {
        const forecast = Number(param.forecast)
        if (isNaN(forecast)) throw Error('Invalid parameter')
        return this.indicatorsService.setIndicatorCodes(param.indicator_code_sid, param.descr, forecast)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method toDictionary
     *********************************************************************************************/
    private toDictionary([providers, periodicities,indicators ]): IDictionary {
        return {
            providers: SharedService.mapCollectionToLabelValue(providers),
            indicators: SharedService.mapCollectionToLabelValue(indicators),
            periodicities: SharedService.mapCollectionToLabelValue(periodicities),
        }
    }
}
