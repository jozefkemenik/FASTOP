import { AuthzLibService, BaseServer, LoggingService } from '../../lib/dist'

import { AppRouter } from './app/app.router'
import { MailRouter } from './mail/mail.router'

export class WebServer extends BaseServer {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(logs: LoggingService): WebServer {
        return new WebServer(logs)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method middleware set up middleware
     * @overrides
     *********************************************************************************************/
    protected middleware(): void {
        super.middleware()

        this.app
            .use(AuthzLibService.checkAuthorisation())
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        this.app
            .use('/mails', MailRouter.createRouter())
            .use('/:appId', AppRouter.createRouter())
    }
}
