import { EApps } from 'config'
import { ITaskSearchCriteria } from './shared-interfaces'
import { SharedService } from '../shared/shared.service'
import { TaskApi } from '../../../lib/dist/api/task.api'
import { TasksService } from './tasks.service'

export class TasksController {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private tasksService: TasksService, private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTasks
     *********************************************************************************************/
    public async getTasks(c: ITaskSearchCriteria) {
        return this.tasksService
            .getTasks(c.countries ?? [], c.storages ?? [], c.rounds ?? [], c.tasks ?? [], c.statuses ?? [])
    }

    /**********************************************************************************************
     * @method getDictionary
     *********************************************************************************************/
    public async getDictionary(statuses: string[]) {
        return Promise.all([
            this.tasksService.getTaskCountriesDict(statuses),
            this.tasksService.getTaskRoundsDict(statuses),
            this.tasksService.getTaskStoragesDict(statuses),
            this.tasksService.getTaskNamesDict(statuses),
        ]).then(this.toDictionary)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method toDictionary
     *********************************************************************************************/
    private toDictionary([countries, rounds, storages, names]) {
        return {
            countries: SharedService.mapCollectionToLabelValue(countries),
            rounds: SharedService.mapCollectionToLabelValue(rounds),
            storages: SharedService.mapCollectionToLabelValue(storages),
            tasks: SharedService.mapCollectionToLabelValue(names),
        }
    }

    /**********************************************************************************************
     * @method abortTask
     *********************************************************************************************/
    public abortTask(taskRunSid: number) {
        return TaskApi.abortTask(this.appId, taskRunSid)
    }
}
