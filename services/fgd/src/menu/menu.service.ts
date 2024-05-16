import { BIND_OUT, CURSOR, ISPOptions, NUMBER, STRING} from '../../../lib/dist/db'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { LibMenuService } from '../../../lib/dist/menu/menu.service'

import { IDBQuestionnaire } from '../shared'
import { IQuestionnaireIndex } from '../questionnaires'

import { DashboardApi } from '../../../lib/dist/api'
import { EApps } from 'config'

export class MenuService extends LibMenuService  {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    public appId: EApps
    public constructor(_app: EApps, private dbService: DbService<DbProviderService>) {
        super(_app)
        this.appId = _app
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getQuestionnaires
     *********************************************************************************************/
    public async getQuestionnaires(): Promise<IDBQuestionnaire[]> {
            const options: ISPOptions = {
                params: [
                    { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                ],
            }
            const dbResult = await this.execSP('cfg_questionnaire.getQuestionnaires' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getQuestionnaireIndexes
     *********************************************************************************************/
    public async getQuestionnaireIndexes(appId: string): Promise<IQuestionnaireIndex[]> {
        const options: ISPOptions = {
            params: [
                { name: 'p_questionnaire_id', type: STRING, value: appId },
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
        }
        const dbResult = await this.execSP('cfg_questionnaire.getQuestionnaireIndexes' , options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getVintageYears
     *********************************************************************************************/
    public async getVintageYears(): Promise<number[]> {
        const roundInfo = await DashboardApi.getCurrentRoundInfo(this.appId)
        const options: ISPOptions = {
            params: [
                { name: 'p_app_id', type: STRING, value: this.appId},
                { name: 'p_round_year', type: NUMBER, value: roundInfo.year},
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
            ],
            arrayFormat: true
        }
        const dbResult = await this.execSP('cfg_questionnaire.getVintageYears' , options)
        return dbResult.o_cur
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /**********************************************************************************************
     * @method execSP
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private execSP(sp: string, options: ISPOptions): Promise<any> {
        return this.dbService.storedProc(sp, options)
    }
}
