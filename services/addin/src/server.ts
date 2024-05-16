import { BaseAppServer, LoggingService } from '../../lib/dist'
import { AmecoRouter } from './ameco/ameco.router'
import { BcsRouter } from './bcs/bcs.router'
import { CalcRouter } from './calc/calc.router'
import { DashboardRouter } from './dashboard/dashboard.router'
import { DwhRouter } from './dwh/dwh.router'
import { EerRouter } from './eer/eer.router'
import { FdmsMainRouter } from './fdms/fdms-main.router'
import { NomicsRouter } from './dbnomics/dbnomics.router'
import { SdmxProvider } from '../../lib/dist/sdmx/shared-interfaces'
import { SdmxRouter } from './sdmx/sdmx.router'
import { version } from '../version'




export class WebServer extends BaseAppServer {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(logs: LoggingService): WebServer {
        return new WebServer(logs, version)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/ameco', AmecoRouter.createRouter(this.appId))
            .use('/bcs', BcsRouter.createRouter(this.appId))
            .use('/dashboard', DashboardRouter.createRouter(this.appId))
            .use('/estat', SdmxRouter.createRouter(this.appId, SdmxProvider.ESTAT, this._logs))
            .use('/ecb', SdmxRouter.createRouter(this.appId, SdmxProvider.ECB, this._logs))
            .use('/ecfin', SdmxRouter.createRouter(this.appId, SdmxProvider.ECFIN, this._logs))
            .use('/fdms', FdmsMainRouter.createRouter(this.appId))
            .use('/dwh', DwhRouter.createRouter(this.appId))
            .use('/nomics', NomicsRouter.createRouter(this.appId, this._logs))
            .use('/eer', EerRouter.createRouter(this.appId))
            .use('/calc', CalcRouter.createRouter(this.appId, this._logs))
    }
}
