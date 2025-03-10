import * as debug from 'debug'

import { EApps } from 'config'

export class LoggingService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method log - static method, requires the app name and the message, does not check level
     *********************************************************************************************/
    public static log(app: EApps, message: string): void {
        this.logger(debug(app), message)
    }

    /**********************************************************************************************
     * @method logger - logs the message
     *********************************************************************************************/
    private static logger(dbgr: debug.IDebugger, message: string): void {
        dbgr(message)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _dbgr: debug.IDebugger

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly _app: EApps, private readonly _level = Level.DEBUG) {
        this._dbgr = debug(_app)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get level() {
        return this._level
    }

    public get appId() {
        return this._app
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method log - instance method, uses the app name passed in constructor
     *********************************************************************************************/
    public log(message: string, level = Level.INFO): void {
        if (level >= this._level) LoggingService.logger(this._dbgr, message)
    }
}

export enum Level { DEBUG, INFO, WARNING, ERROR, NONE }
