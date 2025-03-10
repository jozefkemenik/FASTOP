import { IError } from '../../error.service'
import { IHelpMessage } from '../shared'

import { HelpMsgType } from './shared-interfaces'
import { LibHelpService } from './help.service'

export class LibHelpController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private helpService: LibHelpService) { }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method updateHelpMessage
     *********************************************************************************************/
    public async updateHelpMessage(helpMsgSid: number,
                                   helpMessage: IHelpMessage,
                                   helpMsgTypeId: HelpMsgType): Promise<number> {
        return this.helpService.saveHelpMessage(helpMsgSid, helpMessage, helpMsgTypeId).catch((err: IError) => {
            err.method = 'HelpController.saveHelpMessage'
            throw err
        })
    }
}
