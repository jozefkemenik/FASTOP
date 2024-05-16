import { BaseAppServer, LoggingService } from '../../lib/dist'
import { DocRouter } from './doc/doc.router'
import { EApps } from 'config'
import { ETasks } from 'task'
import { EerRouter } from './eer/eer.router'
import { HicpRouter } from './hicp/hicp.router'
import { LibTaskRouter } from '../../lib/dist/task/task.router'
import { TaskComputationService } from '../../lib/dist/task'
import { UtilRouter } from './util/util.router'
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

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        const taskComputationConfig = [
            [ETasks.HICP_DATA_REFRESH, EApps.HICP],
            [ETasks.EER_WEIGHTS, EApps.NEER],
            [ETasks.NEER, EApps.NEER],
            [ETasks.REER, EApps.NEER],
        ]

        const taskComputation: TaskComputationService = taskComputationConfig.reduce(
            (acc, [taskId, computationService]) => (acc[taskId] = computationService, acc), {})

        this.app
            .use('/tasks', LibTaskRouter.createRouter(this.appId, taskComputation))
            .use('/hicp', HicpRouter.createRouter(this.appId))
            .use('/eer', EerRouter.createRouter(this.appId))
            .use('/util', UtilRouter.createRouter(this.appId))
            .use('/doc', DocRouter.createRouter(this.appId))
    }

}
