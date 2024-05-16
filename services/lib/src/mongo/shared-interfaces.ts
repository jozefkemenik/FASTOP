import {
    AggregateOptions,
    DeleteOptions, DeleteResult, DistinctOptions, Document,
    Filter,
    FindOptions,
    InsertManyResult,
    OptionalUnlessRequiredId,
    UpdateFilter,
    UpdateOptions,
    UpdateResult,
    WithId
} from 'mongodb'

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type IMongoInsertDoc = OptionalUnlessRequiredId<any>
export type IMongoIdDoc = WithId<Document>
export type IMongoDoc = Document

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type IMongoFilter = Filter<any>

/* eslint-disable-next-line @typescript-eslint/no-explicit-any */
export type IMongoUpdateFilter = UpdateFilter<any>

export type IMongoFindOptions = FindOptions
export type IMongoUpdateOptions = UpdateOptions
export type IMongoDeleteOptions = DeleteOptions
export type IMongoAggregateOptions = AggregateOptions
export type IMongoDistinctOptions = DistinctOptions

export type IMongoInsertManyResult = InsertManyResult
export type IMongoUpdateResult = UpdateResult
export type IMongoDeleteResult = DeleteResult


export interface IMongoRequest<T> {
    filter: IMongoFilter,
    options?: T
}

export interface IMongoUpdateRequest extends IMongoRequest<IMongoUpdateOptions> {
    updateFilter: IMongoUpdateFilter
}

export interface IMongoAggregateRequest {
    pipeline: IMongoDoc[]
    options?: IMongoAggregateOptions
}

export interface IMongoDistinctRequest extends IMongoRequest<IMongoDistinctOptions>{
    key: string
}

export interface IFastopPipeline extends IMongoIdDoc {
    pipeline: IMongoDoc[]
}

export interface IFastopPiplineParams {
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    [key: string]: any
}
