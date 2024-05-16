import { BIND_OUT, ISPOptions, NUMBER, STRING } from '../../db'
import { DataAccessApi } from '../../api'

import { HelpMsgType } from './shared-interfaces'
import { IHelpMessage } from '../shared'

export class LibHelpService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method openApplication
     *********************************************************************************************/
    public async saveHelpMessage(helpMsgSid: number,
                                 helpMessage: IHelpMessage,
                                 helpMsgTypeId: HelpMsgType): Promise<number> {
        const options: ISPOptions = {
            params: [
                { name: 'p_help_msg_sid', type: NUMBER, value: helpMsgSid },
                { name: 'p_help_msg_type_id', type: STRING, value: helpMsgTypeId },
                { name: 'p_descr', type: STRING, value: helpMessage.DESCR },
                { name: 'p_mess', type: STRING, value: helpMessage.MESS },
                { name: 'o_res', type: NUMBER, dir: BIND_OUT },
            ],
        }
        const dbResult = await DataAccessApi.execSP('core_help.saveHelpMessage', options)
        return dbResult.o_res
    }
}
