import { EApps } from 'config'

import { ETemplateTypes } from '../../../shared-lib/dist/prelib/files'
import { TemplateService } from './template.service'
import { catchAll } from '../../../lib/dist/catch-decorator'

@catchAll('TemplateController')
export class TemplateController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly templateService: TemplateService) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getActiveTemplate
     *********************************************************************************************/
    public getActiveTemplate(appId: EApps, templateId: ETemplateTypes) {
        return this.templateService.getActiveTemplate(appId, templateId)
    }
}
