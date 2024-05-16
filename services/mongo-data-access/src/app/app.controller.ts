import {
    IFastopPiplineParams,
    IMongoAggregateRequest, IMongoDeleteOptions, IMongoDeleteResult, IMongoDistinctRequest,
    IMongoDoc,
    IMongoFindOptions, IMongoInsertDoc, IMongoInsertManyResult,
    IMongoRequest, IMongoUpdateRequest, IMongoUpdateResult
} from '../../../lib/dist/mongo/shared-interfaces'
import { LoggingService, MongoDbService } from '../../../lib/dist'
import { catchAll } from '../../../lib/dist/catch-decorator'


@catchAll(__filename)
export class AppController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly db: MongoDbService, private readonly logs: LoggingService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDbName
     *********************************************************************************************/
    public async getDbName(): Promise<string> {
        return this.db.dbName
    }

    /**********************************************************************************************
     * @method find
     *********************************************************************************************/
    public async find(
        collection: string, request: IMongoRequest<IMongoFindOptions>
    ): Promise<IMongoDoc[]> {
        return this.db.find(collection, request.filter, request.options)
    }

    /**********************************************************************************************
     * @method aggregate
     *********************************************************************************************/
    public async aggregate(
        collection: string, request: IMongoAggregateRequest
    ): Promise<IMongoDoc[]> {
        return this.db.aggregate(collection, request.pipeline, request.options)
    }

    /**********************************************************************************************
     * @method create
     *********************************************************************************************/
    public async create(collection: string, documents: IMongoInsertDoc[]): Promise<IMongoInsertManyResult> {
        return this.db.insert(collection, documents)
    }

    /**********************************************************************************************
     * @method update
     *********************************************************************************************/
    public async update(collection: string, request: IMongoUpdateRequest): Promise<IMongoUpdateResult> {
        return this.db.update(collection, request.filter, request.updateFilter, request.options)
    }

    /**********************************************************************************************
     * @method delete
     *********************************************************************************************/
    public async delete(collection: string, request: IMongoRequest<IMongoDeleteOptions>): Promise<IMongoDeleteResult> {
        return this.db.delete(collection, request.filter, request.options)
    }

    /**********************************************************************************************
     * @method distinct
     *********************************************************************************************/
    public async distinct(collection: string, request: IMongoDistinctRequest): Promise<IMongoDoc[]> {
        return this.db.distinct(collection, request.key, request.filter, request.options)
    }

    /**********************************************************************************************
     * @method aggregatePipeline
     *********************************************************************************************/
    public async aggregatePipeline(
        collection: string, pipelineId: string, params?: IFastopPiplineParams
    ): Promise<IMongoDoc[]> {
        return this.db.aggregateStoredPipeline(collection, pipelineId, params)
    }
}
