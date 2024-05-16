import { Collection, MongoClient } from 'mongodb'

import {
    IFastopPipeline, IFastopPiplineParams,
    IMongoAggregateOptions,
    IMongoDeleteOptions, IMongoDeleteResult, IMongoDistinctOptions,
    IMongoDoc,
    IMongoFilter,
    IMongoFindOptions, IMongoIdDoc, IMongoInsertDoc,
    IMongoInsertManyResult,
    IMongoUpdateFilter,
    IMongoUpdateOptions, IMongoUpdateResult
} from './shared-interfaces'
import { Level, LoggingService } from '../logging.service'
import { IMongoConfig } from 'config'


export class MongoDbService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _client: MongoClient

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        private readonly logs: LoggingService,
        private readonly config: IMongoConfig,
    ) {
        this.createClient()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get dbName() {
        return this.db.databaseName
    }

    public get db() {
        return this._client.db(this.config.database)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method listCollections
     *********************************************************************************************/
    public async listCollections(): Promise<string[]> {
        return this.db.listCollections().toArray().then(
            collections => collections.map(c => c.name)
        )
    }

    /**********************************************************************************************
     * @method insert documents into collection
     *********************************************************************************************/
    public async insert(collection: string, documents: IMongoInsertDoc[]): Promise<IMongoInsertManyResult> {
        return this.getCollection(collection).insertMany(documents)
    }

    /**********************************************************************************************
     * @method find documents in collection
     *********************************************************************************************/
    public async find(collection: string, filter?: IMongoFilter, options?: IMongoFindOptions): Promise<IMongoIdDoc[]> {
        return this.getCollection(collection).find(filter, options).toArray()
    }

    /**********************************************************************************************
     * @method findOne
     *********************************************************************************************/
    public findOne(collection: string, filter: IMongoFilter, options?: IMongoFindOptions): Promise<IMongoIdDoc> {
        return this.getCollection(collection).findOne(filter, options)
    }

    /**********************************************************************************************
     * @method update documents in collection
     *********************************************************************************************/
    public async update(
        collection: string, filter: IMongoFilter, updateFilter: IMongoUpdateFilter, options?: IMongoUpdateOptions
    ): Promise<IMongoUpdateResult> {
        return this.getCollection(collection).updateMany(filter, updateFilter, options)
    }

    /**********************************************************************************************
     * @method delete documents in collection
     *********************************************************************************************/
    public async delete(
        collection: string, filter: IMongoFilter, options?: IMongoDeleteOptions
    ): Promise<IMongoDeleteResult> {
        return this.getCollection(collection).deleteMany(filter, options)
    }

    /**********************************************************************************************
     * @method aggregate documents in collection
     *********************************************************************************************/
    public async aggregate(
        collection: string, pipeline: IMongoDoc[], options?: IMongoAggregateOptions
    ): Promise<IMongoDoc[]> {
        return this.getCollection(collection).aggregate(pipeline, options).toArray()
    }

    /**********************************************************************************************
     * @method aggregateStoredPipeline execute stored pipeline
     *********************************************************************************************/
    public async aggregateStoredPipeline(
        collection: string, pipelineId: string, params?: IFastopPiplineParams
    ): Promise<IMongoDoc[]> {
        const fastopPipeline: IFastopPipeline = await this.getPipeline(pipelineId)
        if (!fastopPipeline || !fastopPipeline.pipeline?.length) {
            throw new Error(`Cannot find pipeline: ${pipelineId}!`)
        }

        const pipeline: IMongoDoc[] = !params ? fastopPipeline.pipeline :
                                                this.mergePipelineWithParams(fastopPipeline.pipeline, params)
        return this.getCollection(collection).aggregate(pipeline).toArray()
    }

    /**********************************************************************************************
     * @method distinct
     *********************************************************************************************/
    public async distinct(
        collection: string, key: string, filter?: IMongoFilter, options?: IMongoDistinctOptions
    ): Promise<IMongoDoc[]> {
        return this.getCollection(collection).distinct(key, filter, options)
    }

    /**********************************************************************************************
     * @method close clean up before closing
     *********************************************************************************************/
    public close(): Promise<void> {
        return this._client.close()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createClient
     *********************************************************************************************/
    private createClient() {
        MongoClient.connect(this.config.uri).then(
            client => {
                this._client = client

                this.logs.log(
                    `MongoDbService: Created pool with max ${client.options.maxPoolSize} connections`
                )
            },
            err => {
                this.logs.log('MongoDbService: Error creating connection pool', Level.ERROR)
                this.logs.log(`Failed to create pool for config: ${JSON.stringify(this.config)}`)
                throw err
            }
        )
    }

    /**********************************************************************************************
     * @method getCollection
     *********************************************************************************************/
    private getCollection(name: string): Collection {
        return this.db.collection(name)
    }

    /**********************************************************************************************
     * @method getPipeline
     *********************************************************************************************/
    private getPipeline(pipelineId: string): Promise<IFastopPipeline> {
        return this.findOne(
            this.config.pipelinesCollection,
            { "_id" : `${pipelineId}` }
            ).then(pipeline => pipeline as IFastopPipeline)
    }

    /**********************************************************************************************
     * @method mergePipelineWithParams
     *********************************************************************************************/
    private mergePipelineWithParams(pipeline: IMongoDoc[], params: IFastopPiplineParams): IMongoDoc[] {
        let pipelineString = JSON.stringify(pipeline)
        Object.keys(params).forEach(param => {
            pipelineString = pipelineString.replace(`"${param}"`, JSON.stringify(params[param]))
        })

        return JSON.parse(pipelineString)
    }
}
