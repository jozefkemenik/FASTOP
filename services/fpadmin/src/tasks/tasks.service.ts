import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { IDBNameValue } from '../shared/shared-interfaces'
import { IDBTask } from '.'

export class TasksService {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTaskRoundsDict
     *********************************************************************************************/
    public async getTaskCountriesDict(statuses: string[]): Promise<IDBNameValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_status_ids', type: STRING, value: statuses },
            ],
        }

        const dbResult = await DataAccessApi.execSP('task_getters.getTaskCountriesDict', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTaskRoundsDict
     *********************************************************************************************/
    public async getTaskRoundsDict(statuses: string[]): Promise<IDBNameValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_status_ids', type: STRING, value: statuses },
            ],
        }

        const dbResult = await DataAccessApi.execSP('task_getters.getTaskRoundsDict', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTaskStoragesDict
     *********************************************************************************************/
    public async getTaskStoragesDict(statuses: string[]): Promise<IDBNameValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_status_ids', type: STRING, value: statuses },
            ],
        }

        const dbResult = await DataAccessApi.execSP('task_getters.getTaskStoragesDict', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTaskNamesDict
     *********************************************************************************************/
    public async getTaskNamesDict(statuses: string[]): Promise<IDBNameValue[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_status_ids', type: STRING, value: statuses },
            ],
        }

        const dbResult = await DataAccessApi.execSP('task_getters.getTaskNamesDict', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTasks
     *********************************************************************************************/
    public async getTasks(
        countries: string[],
        storages: number[],
        rounds: number[],
        taskSids: number[],
        statuses: string[],
    ): Promise<IDBTask[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_country_ids', type: STRING, value: countries},
                { name: 'p_storage_sids', type: NUMBER, value: storages},
                { name: 'p_round_sids', type: NUMBER, value: rounds},
                { name: 'p_status_ids', type: STRING, value: statuses},
                { name: 'p_task_sids', type: NUMBER, value: taskSids},
            ],
        }

        const dbResult = await DataAccessApi.execSP('task_getters.getTasks', options)
        return dbResult.o_cur
    }
}
