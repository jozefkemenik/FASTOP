import { EApps } from 'config'

import { BIND_OUT, BLOB, BUFFER, CURSOR, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api/data-access.api'
import { ILinkedTableTemplateFile } from '../linked-tables'

import { IFileTemplate } from '.'

export class LibLinkedTablesTplService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly appId: EApps) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getTemplates
     *********************************************************************************************/
    public async getTemplates(): Promise<IFileTemplate[]> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_link_tables.getAllTemplates', options)
        return dbResult.o_cur
    }

    /**********************************************************************************************
     * @method getTemplate
     *********************************************************************************************/
    public async getTemplate(templateSid: number): Promise<ILinkedTableTemplateFile> {
        const options: ISPOptions = {
            params: [
                { name: 'o_cur', type: CURSOR, dir: BIND_OUT },
                { name: 'p_template_sid', type: NUMBER, value: templateSid },
            ],
            fetchInfo: {
                content: { type: BUFFER }
            }
        }

        const dbResult = await DataAccessApi.execSP('core_templates.getTemplate', options)
        return dbResult.o_cur[0]
    }

    /**********************************************************************************************
     * @method uploadTemplate
     *********************************************************************************************/
    public async uploadTemplate(fileName: string, mimeType: string,
                                fileContent: Buffer, description: string, user: string): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_title', type: STRING, value: fileName },
                { name: 'p_content_type', type: STRING, value: mimeType },
                { name: 'p_content', type: BLOB, value: fileContent },
                { name: 'p_descr', type: STRING, value: description },
                { name: 'p_last_change_user', type: STRING, value: user },
            ]
        }

        const dbResult = await DataAccessApi.execSP('gd_link_tables.uploadTemplate', options)
        return dbResult.o_res
    }

    /**********************************************************************************************
     * @method activateTemplate
     *********************************************************************************************/
    public async activateTemplate(templateSid: number): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_app_id', type: STRING, value: this.appId },
                { name: 'p_template_sid', type: NUMBER, value: templateSid },
            ],
        }

        const dbResult = await DataAccessApi.execSP('gd_link_tables.activateTemplate', options)
        return dbResult.o_res > 0
    }

    /**********************************************************************************************
     * @method deleteTemplate
     *********************************************************************************************/
    public async deleteTemplate(templateSid: number): Promise<boolean> {
        const options: ISPOptions = {
            params: [
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
                { name: 'p_template_sid', type: NUMBER, value: templateSid },
            ],
        }

        const dbResult = await DataAccessApi.execSP('core_templates.deleteTemplate', options)
        return dbResult.o_res > 0
    }

}
