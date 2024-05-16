import { BaseServer, LoggingService } from '../../lib/dist'
import { CnsRouter } from './cns/cns.router'
import { MailRouter } from './mail/mail.router'
import { MailService } from './mail/mail.service'
import { SharedService } from './shared/shared.service'


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
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _mailService: MailService
    private _sharedService: SharedService

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        this._mailService.close()
    }

    /**********************************************************************************************
     * @method setup app specific setup
     *********************************************************************************************/
    protected setup(): void {
        this._mailService = MailService.getInstance(this._logs)
        this._sharedService = new SharedService()
        this.registerShutdownListeners()
    }

    /**********************************************************************************************
     * @method api set up api
     *********************************************************************************************/
    protected api(): void {
        this.app
            .use('/mail', MailRouter.createRouter(this.appId, this._mailService, this._sharedService, this._logs))
            .use('/cns', CnsRouter.createRouter(this.appId, this._sharedService, this._logs))
    }
}
