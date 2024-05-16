import { EApps } from 'config'

import { BIND_OUT, BUFFER, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { SharedCalcService } from '../shared/calc/shared-calc.service'
import { WorkbookGroup } from '../../../../shared-lib/dist/prelib/fisc-grids'

import { ILinkedTableTemplateFile } from '.'

export class LibLinkedTablesService extends SharedCalcService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private appId: EApps) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getRequiredAmecoIndicators
     *********************************************************************************************/
    public async getRequiredAmecoIndicators(): Promise<string[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_workbook_id', type: STRING, value: WorkbookGroup.LINKED_TABLES },
            ],
        }
        const dbResult = await DataAccessApi.execSP('idr_getters.getAmecoIndForLinkedTables', options)
        return dbResult.o_cur.map(data => data.INDICATOR_ID)
    }

    /**********************************************************************************************
     * @method getLinkedTablesTemplate
     *********************************************************************************************/
    public async getLinkedTablesTemplate(appId: EApps): Promise<ILinkedTableTemplateFile> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
            ],
            fetchInfo: {
                content: { type: BUFFER }
            }
        }

        const dbResult = await DataAccessApi.execSP('gd_link_tables.getActiveTemplate', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method checkActiveTemplate
     *********************************************************************************************/
    public async checkActiveTemplate(appId: EApps): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_link_tables.checkActiveTemplate', options)
        return dbResult.o_res > 0
    }
}
