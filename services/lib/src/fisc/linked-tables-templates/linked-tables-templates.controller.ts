import { ILinkedTableTemplateFile } from '../linked-tables'

import { IFileTemplate } from '.'
import { LibLinkedTablesTplService } from './linked-tables-templates.service'

export class LibLinkedTablesTplController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private service: LibLinkedTablesTplService) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method uploadTemplate
     *********************************************************************************************/
    public uploadTemplate(file: Express.Multer.File, descr: string, user: string) {
        return this.service.uploadTemplate(file.originalname, file.mimetype, file.buffer, descr, user)
    }

    /**********************************************************************************************
     * @method getTemplateList
     *********************************************************************************************/
    public getTemplateList(): Promise<IFileTemplate[]> {
        return this.service.getTemplates()
    }

    /**********************************************************************************************
     * @method getTemplate
     *********************************************************************************************/
    public getTemplate(templateSid: number): Promise<ILinkedTableTemplateFile> {
        return this.service.getTemplate(templateSid)
    }

    /**********************************************************************************************
     * @method activateTemplate
     *********************************************************************************************/
    public activateTemplate(templateSid: number): Promise<boolean> {
        return this.service.activateTemplate(templateSid)
    }

    /**********************************************************************************************
     * @method deleteTemplate
     *********************************************************************************************/
    public deleteTemplate(templateSid: number): Promise<boolean> {
        return this.service.deleteTemplate(templateSid)
    }
}
