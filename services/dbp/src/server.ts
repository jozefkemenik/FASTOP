import {
    AggregatesRouter,
    FiscDashboardRouter,
    FiscRoundRouter,
    FiscalParametersRouter,
    IAggregateParameters,
    LibHelpRouter,
    LibLineIndicatorRouter,
    LibLinkedTablesRouter,
    LibLinkedTablesTplRouter,
    LibOutputGapsRouter,
    MenuRouter,
    SemiElasticityRouter,
} from '../../lib/dist/fisc'
import { BaseServer, LoggingService } from '../../lib/dist'
import { GuaranteeRouter } from '../../lib/dist/measure/fisc-drm/guarantee/guarantee.router'
import { LibWorkflowRouter } from '../../lib/dist/workflow/workflow.router'

import { ConfigRouter } from './config/config.router'
import { GridRouter } from './grid/grid.router'
import { LinkedTablesController } from './linked-tables/linked-tables.controller'
import { MeasureRouter } from './measure/measure.router'
import { OutputGapsController } from './output-gaps/output-gaps.controller'
import { SharedService } from './shared/shared.service'
import { version } from '../version'

export class WebServer extends BaseServer {
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
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private sharedService: SharedService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method setup local setup function
     * @overrides
     *********************************************************************************************/
    protected setup(): void {
        this.sharedService = new SharedService(this.appId)
    }

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/config', ConfigRouter.createRouter(this.sharedService))
            .use('/menus', MenuRouter.createFiscRouter(this.sharedService.menuService))
            .use('/dashboard', FiscDashboardRouter.createRouter(this.appId, this._logs))
            .use('/elasticity', SemiElasticityRouter.createRouter(this.appId))
            .use('/fiscalParams', FiscalParametersRouter.createRouter(this.appId))
            .use('/grids', GridRouter.createRouter(this.appId))
            .use('/guarantees', GuaranteeRouter.createRouter(this.appId, this.sharedService))
            .use('/rounds', FiscRoundRouter.createRouter(this.appId))
            .use('/linkedTables', LibLinkedTablesRouter.createRouter(new LinkedTablesController(this.appId, this.sharedService)))
            .use('/linkedTablesTemplates', LibLinkedTablesTplRouter.createRouter(this.appId))
            .use('/measures', MeasureRouter.createRouter(this.appId, this.sharedService))
            .use('/og', LibOutputGapsRouter.createRouter(new OutputGapsController(this.appId)))
            .use('/workflow', LibWorkflowRouter.createLibRouter(this.appId))
            .use('/help', LibHelpRouter.createRouter())
            .use('/aggregates', AggregatesRouter.createRouter(this.appId, this.getAggregateParams(), this._logs))
            .use('/indicator', LibLineIndicatorRouter.createRouter())
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// Private Methods ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getAggregateParams
     *********************************************************************************************/
    private getAggregateParams(): IAggregateParameters {
        return {
            countryArea: 'EADBP',
            eaArea: 'EADBP',
            nominalCode: 'T01aL07',
        }
    }
}
