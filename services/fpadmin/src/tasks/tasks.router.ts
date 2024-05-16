import { NextFunction, Request, Response, Router } from 'express'

import { AuthzLibService, BaseRouter } from '../../../lib/dist'
import { EApps } from 'config'
import { ITaskSearchCriteria } from './shared-interfaces'
import { TasksController } from './tasks.controller'
import { TasksService } from './tasks.service'


export class TasksRouter extends BaseRouter {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of StatsRouter
     *********************************************************************************************/
    public static createRouter(appId: EApps): Router {
        return new TasksRouter(appId).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private controller: TasksController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(appId: EApps) {
        super(appId)
        this.controller = new TasksController(new TasksService(),appId)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for TasksRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router.get('/data', AuthzLibService.checkAuthorisation('ADMIN'), this.getTasksHandler)
                     .get('/dictionary', AuthzLibService.checkAuthorisation('ADMIN'), this.getDictionaryHandler)
                     .delete('/runs/:taskRunSid',AuthzLibService.checkAuthorisation('ADMIN'),this.abortTaskHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTasksHandler
     *********************************************************************************************/
    private getTasksHandler = (req: Request, res: Response, next: NextFunction) =>{
        const param:ITaskSearchCriteria ={
            countries: JSON.parse(req.query.countries as string), 
            rounds: JSON.parse(req.query.rounds  as string),
            storages: JSON.parse(req.query.storages  as string),
            tasks: JSON.parse(req.query.tasks  as string),
            statuses: JSON.parse(req.query.statuses  as string)
        }

        return this.controller.getTasks(param).then(res.json.bind(res), next)
    }

    /**********************************************************************************************
     * @method getDictionaryHandler
     *********************************************************************************************/
    private getDictionaryHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDictionary(JSON.parse(req.query.statuses  as string) ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method abortTaskHandler
     *********************************************************************************************/
    private abortTaskHandler(req: Request, res: Response, next: NextFunction) {
        return this.controller.abortTask(Number(req.params.taskRunSid))
            .then(res.json.bind(res), next)
    }



}
