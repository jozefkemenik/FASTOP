import { EApps } from 'config'

import { BIND_OUT, BUFFER, CURSOR, ISPOptions, STRING } from '../../../lib/dist/db'
import { DataAccessApi } from '../../../lib/dist/api'
import { ETemplateTypes } from '../../../shared-lib/dist/prelib/files'
import { IBinaryFile } from '../../../lib/dist/template/shared-interfaces'


export class TemplateService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActiveTemplate
     *********************************************************************************************/
    public async getActiveTemplate(appId: EApps, templateId: ETemplateTypes
    ): Promise<IBinaryFile> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: appId },
                { name: 'p_template_type_id', type: STRING, value: templateId },
            ],
            fetchInfo: {
                content: { type: BUFFER }
            }
        }

        const dbResult = await DataAccessApi.execSP('core_templates.getActiveTemplate', options)
        return dbResult.o_cur[0]
    }
}
