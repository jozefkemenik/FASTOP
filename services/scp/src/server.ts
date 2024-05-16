import {
    AggregatesRouter,
    FiscDashboardRouter,
    FiscRoundRouter,
    FiscalParametersRouter,
    IAggregateParameters,
    LibHelpRouter,
    LibLineIndicatorRouter,
    LibLinkedTablesController,
    LibLinkedTablesRouter,
    LibLinkedTablesTplRouter,
    LibOutputGapsController,
    LibOutputGapsRouter,
    MenuRouter,
    SemiElasticityRouter,
} from '../../lib/dist/fisc'
import { BaseServer, LoggingService } from '../../lib/dist'
import { GuaranteeRouter } from '../../lib/dist/measure/fisc-drm/guarantee/guarantee.router'
import { LibWorkflowRouter } from '../../lib/dist/workflow/workflow.router'
import { version } from '../version'

import { ConfigRouter } from './config/config.router'
import { GridRouter } from './grid/grid.router'
import { SharedService } from './shared/shared.service'

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

    /**********************************************************************************************
     * @method setup local setup function
     * @overrides
     *********************************************************************************************/
    protected setup(): void {
        this.sharedService = new SharedService(this.appId)
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
            .use('/config', ConfigRouter.createRouter(this.sharedService))
            .use('/menus', MenuRouter.createFiscRouter(this.sharedService.menuService))
            .use('/aggregates', AggregatesRouter.createRouter(this.appId, this.getAggregateParams(), this._logs))
            .use('/dashboard', FiscDashboardRouter.createRouter(this.appId, this._logs))
            .use('/elasticity', SemiElasticityRouter.createRouter(this.appId))
            .use('/fiscalParams', FiscalParametersRouter.createRouter(this.appId))
            .use('/guarantees', GuaranteeRouter.createRouter(this.appId, this.sharedService))
            .use('/grids', GridRouter.createRouter(this.appId))
            .use('/help', LibHelpRouter.createRouter())
            .use(
                '/linkedTables',
                LibLinkedTablesRouter.createRouter(new LibLinkedTablesController(this.appId, this.sharedService)),
            )
            .use('/linkedTablesTemplates', LibLinkedTablesTplRouter.createRouter(this.appId))
            .use('/og', LibOutputGapsRouter.createRouter(new LibOutputGapsController(this.appId)))
            .use('/rounds', FiscRoundRouter.createRouter(this.appId))
            .use('/workflow', LibWorkflowRouter.createLibRouter(this.appId))
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
            countryArea: 'EU',
            eaArea: 'EA',
            nominalCode: 'T01aL02',
        }
    }
}
