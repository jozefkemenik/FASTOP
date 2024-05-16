import { NextFunction, Request, Response, Router } from 'express'

import { BaseRouter, LoggingService, MongoDbService } from '../../../lib/dist'
import { AppController } from './app.controller'


export class AppRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of this Router
     *********************************************************************************************/
    public static createRouter(db: MongoDbService, logs: LoggingService): Router {
        return new AppRouter(db, logs).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private readonly controller: AppController

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(db: MongoDbService, logs: LoggingService) {
        super()
        this.controller = new AppController(db, logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for this Router
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/dbServer', this.getDbServerHandler)
            .post('/find/:collection', this.findHandler)
            .post('/aggregate/:collection', this.aggregateHandler)
            .post('/aggregate/:collection/:pipelineId', this.aggregateStoredPipelineHandler)
            .post('/create/:collection', this.createHandler)
            .post('/update/:collection', this.updateHandler)
            .post('/delete/:collection', this.deleteHandler)
            .post('/distinct/:collection', this.getDistinctHandler)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDbServerHandler
     *********************************************************************************************/
    private getDbServerHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.getDbName().then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method findHandler
     *********************************************************************************************/
    private findHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.find(req.params.collection, req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method aggregateStoredPipelineHandler
     *********************************************************************************************/
    private aggregateStoredPipelineHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.aggregatePipeline(
            req.params.collection, req.params.pipelineId, req.body
        ).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method aggregateHandler
     *********************************************************************************************/
    private aggregateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.aggregate(req.params.collection, req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method createHandler
     *********************************************************************************************/
    private createHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.create(req.params.collection, req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method updateHandler
     *********************************************************************************************/
    private updateHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.update(req.params.collection, req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method deleteHandler
     *********************************************************************************************/
    private deleteHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.delete(req.params.collection, req.body).then(res.json.bind(res), next)

    /**********************************************************************************************
     * @method getDistinctHandler
     *********************************************************************************************/
    private getDistinctHandler = (req: Request, res: Response, next: NextFunction) =>
        this.controller.distinct(req.params.collection, req.body).then(res.json.bind(res), next)

}
