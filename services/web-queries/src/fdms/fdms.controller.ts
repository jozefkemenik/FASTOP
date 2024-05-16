import { EApps } from 'config'
import { FdmsService } from './fdms.service'
import { IWQFdmsRequestParams } from '.'
import { IWQInputParams } from '../shared/shared-interfaces'
import { IWQRenderData } from '../shared'
import { LoggingService } from '../../../lib/dist'
import { SharedService } from '../shared/shared.service'
import { WqController } from '../shared/wq.controller'

export class FdmsController extends WqController<IWQFdmsRequestParams, void> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        appId: EApps.FDMS | EApps.FDMSIE,
        fdmsService: FdmsService,
        sharedService: SharedService,
        logs: LoggingService,
    ) {
        super(appId,fdmsService, sharedService, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getFdmsData
     *********************************************************************************************/
    public getFdmsData(params: IWQInputParams, providerId: string, dataInfo: string): Promise<string> {
        return this.getWqData(this.getRequestParams(providerId, params), { name: 'FDMS', value: dataInfo })
    }

    /**********************************************************************************************
     * @method getEurostatData
     *********************************************************************************************/
    public getEurostatData(
        providerId: 'ESTAT_A' | 'ESTAT_Q' | 'ESTAT_M',
        params: IWQInputParams
    ): Promise<string> {
        const config = {
            ESTAT_A: { title: 'annual', periodicity: 'A' },
            ESTAT_Q: { title: 'quarterly', periodicity: 'Q' },
            ESTAT_M: { title: 'monthly', periodicity: 'M' }
        }
        params.periodicity = config[providerId]?.periodicity
        return this.getWqData(
            this.getRequestParams(providerId, params),
            { name: 'Eurostat', value: `${config[providerId]?.title}`}
        )
    }

    /**********************************************************************************************
     * @method getForecastIndicatorHandler
     *********************************************************************************************/
    public getForecastIndicators(params: IWQInputParams): Promise<string> {
        return this.getWqData(
            this.getRequestParams('PRE_PROD', params), { name: 'FDMS', value: 'Forecast' }
        )
    }

    /**********************************************************************************************
     * @method getForecastRawIndicators
     *********************************************************************************************/
    public getForecastRawIndicators(params: IWQInputParams): Promise<IWQRenderData<IWQFdmsRequestParams>> {
        return this.getWqIndicators(this.getRequestParams('PRE_PROD', params), false)
    }

    /**********************************************************************************************
     * @method getTceData
     *********************************************************************************************/
    public getTceData(params: IWQInputParams): Promise<string> {
        params.customColumns = [{ label: 'Partner', field: 'dataType' }]
        return this.getWqData(
            this.getRequestParams('TCE_RSLTS', params), { name: 'FDMS', value: 'TCE results' }
        )
    }

    /**********************************************************************************************
     * @method getForecastAmecoCurrent
     *********************************************************************************************/
    public getForecastAmecoCurrent(
        renderData: IWQRenderData<IWQFdmsRequestParams>, inputParams: IWQInputParams
    ): string {
        renderData.indicators.data = this.fillDataByParameters(
            renderData.indicators.data, inputParams, renderData.archivedRound, renderData.countries
        )

        return this.render(renderData,{ name: 'FDMS', value: 'Forecast ameco-current' })
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRequestParams
     *********************************************************************************************/
    private getRequestParams(providerId: string, params: IWQInputParams): IWQFdmsRequestParams {
        return Object.assign({ providerId }, params)
    }
}
