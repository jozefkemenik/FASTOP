import { Request, Response, Router } from 'express'

import { IServerInfo } from '../../../shared/server'
import { config } from '../../config/config'

import { AuthzLibService } from './authzLib.service'
import { BaseRouter } from './base-router'
import { DataAccessApi } from './api'

export class ServerInfoRouter extends BaseRouter {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createRouter factory function to create an instance of ServerInfoRouter
     *********************************************************************************************/
    public static createRouter(serviceVersion: string): Router {
        return new ServerInfoRouter(serviceVersion).buildRouter()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _dbServer: string

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(private readonly serviceVersion: string) {
        super()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method configRoutes routes configuration for UsersRouter
     *********************************************************************************************/
    protected configRoutes(router: Router): Router {
        return router
            .get('/', this.getInfoHandler.bind(this))
            .get('/mem',
                AuthzLibService.checkAuthorisation('SU'),
                this.getMemoryHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getInfoHandler
     *********************************************************************************************/
    private async getInfoHandler(req: Request, res: Response) {
        this._dbServer = this._dbServer ?? await DataAccessApi.getDbServer()
        const serverName = process.env.HOSTNAME ??
            (this.isOnIntragate(req) ? config.host : config.host.replace('intragate', 'webgate'))
        const serverInfo: IServerInfo = {
            serverName,
            dbServer: this._dbServer,
            serviceVersion: this.serviceVersion,
        }
        res.json(serverInfo)
    }

    /**********************************************************************************************
     * @method getMemoryHandler
     *********************************************************************************************/
    private getMemoryHandler(req: Request, res: Response) {
        res.json({
            pid: process.pid,
            memory: process.memoryUsage(),
        })
    }
}
