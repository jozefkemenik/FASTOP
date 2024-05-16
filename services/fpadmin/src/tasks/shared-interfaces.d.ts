import {ILabelValue} from '../shared/shared-interfaces'


export interface ITask {
    task_sid: number
    task_run_sid: number
    country_id: string
    country_descr: string
    round_sid : number
    round_descr: string
    storage_sid: number
    storage_id: string
    storage_descr: string
    task_id: string
    task_descr: string
    task_status_id: string
    status_descr: string
    user_run: string
    end_run: Date
    all_steps: number
    steps: number
    all_prep_steps: number
    prep_steps: number
}

export interface ITaskSearchCriteria{
    countries: string[]
    rounds: number[]
    storages: number[]
    tasks: number[]
    statuses: string[]
}


export interface ITaskDictionary{
    countries:ILabelValue[]
    rounds:ILabelValue[]
    storages:ILabelValue[]
    tasks:ILabelValue[]
}
