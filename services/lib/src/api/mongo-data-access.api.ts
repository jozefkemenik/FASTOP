import { EApps, MDAType } from 'config'
import {
    IFastopPiplineParams,
    IMongoAggregateOptions,
    IMongoDeleteOptions, IMongoDeleteResult, IMongoDistinctOptions,
    IMongoDoc, IMongoFilter,
    IMongoFindOptions,
    IMongoInsertDoc,
    IMongoInsertManyResult,
    IMongoUpdateFilter, IMongoUpdateOptions, IMongoUpdateResult
} from '../mongo/shared-interfaces'
import { RequestService } from '../request.service'


export class MongoDataAccessApi {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method create
     *********************************************************************************************/
    public static create(
        collection: string, documents: IMongoInsertDoc[], mdaApp: MDAType = EApps.MDA
    ): Promise<IMongoInsertManyResult> {
        return RequestService.request(mdaApp, `/create/${collection}`, 'post', documents)
    }

    /**********************************************************************************************
     * @method find
     *********************************************************************************************/
    public static find(
        collection: string, filter: IMongoFilter, options?: IMongoFindOptions, mdaApp: MDAType = EApps.MDA
    ):Promise<IMongoDoc[]> {
        return RequestService.request(mdaApp, `/find/${collection}`, 'post', { filter, options })
    }

    /**********************************************************************************************
     * @method update
     *********************************************************************************************/
    public static update(
        collection: string, filter: IMongoFilter, updateFilter: IMongoUpdateFilter, options?: IMongoUpdateOptions,
        mdaApp: MDAType = EApps.MDA
    ): Promise<IMongoUpdateResult> {
        return RequestService.request(
            mdaApp, `/update/${collection}`, 'post', { filter, updateFilter, options }
        )
    }

    /**********************************************************************************************
     * @method delete
     *********************************************************************************************/
    public static delete(
        collection: string, filter: IMongoFilter, options?: IMongoDeleteOptions, mdaApp: MDAType = EApps.MDA
    ): Promise<IMongoDeleteResult> {
        return RequestService.request(mdaApp, `/delete/${collection}`, 'post', { filter, options })
    }

    /**********************************************************************************************
     * @method aggregate
     *********************************************************************************************/
    public static aggregate(
        collection: string, pipeline: IMongoDoc[], options?: IMongoAggregateOptions, mdaApp: MDAType = EApps.MDA
    ): Promise<IMongoDoc[]> {
        return RequestService.request(mdaApp, `/aggregate/${collection}`, 'post', { pipeline, options })
    }

    /**********************************************************************************************
     * @method distinct
     *********************************************************************************************/
    public static distinct(
        collection: string, key: string, filter?: IMongoFilter, options?: IMongoDistinctOptions, mdaApp: MDAType = EApps.MDA
    ): Promise<IMongoDoc[]> {
        return RequestService.request(mdaApp, `/distinct/${collection}`, 'post', { key, filter, options })
    }

    /**********************************************************************************************
     * @method aggregateStoredPipeline
     *********************************************************************************************/
    public static aggregateStoredPipeline(
        collection: string, pipelineId: string, params?: IFastopPiplineParams, mdaApp: MDAType = EApps.MDA
    ): Promise<IMongoDoc[]> {
        return RequestService.request(mdaApp, `/aggregate/${collection}/${pipelineId}`, 'post', params)
    }

}
