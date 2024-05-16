import { NextFunction, Request, Response } from 'express'

import { Level, LoggingService } from '../../lib/dist'
import { BaseServerDb } from '../../lib/dist/db/base-server-db'
import { DbProviderService } from '../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../lib/dist/db/db.service'
import { ISchemaConfigs } from 'config'
import { version } from '../version'

import { AdminRouter } from './admin/admin.router'
import { ConfigRouter } from './config/config.router'
import { EntriesRouter } from './entries/entries.router'
import { IndexesRouter } from './indexes/indexes.router'
import { IndicesRouter } from './indices/indices.router'
import { MenuRouter } from './menu/menu.router'
import { QuestionnaireRouter } from './questionnaires/questionnaire.router'
import { QuestionsRouter } from './questions/questions.router'
import { ScoresRouter } from './scores/scores.router'
import { SectionsRouter } from './sections/sections.router'
import { SharedService } from './shared/shared.service'
import { VintagesRouter } from './vintages/vintages.router'

export class WebServer extends BaseServerDb {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getServer static factory method
     *********************************************************************************************/
    public static getServer(schemas: ISchemaConfigs, logs: LoggingService): WebServer {
        BaseServerDb.schemas = schemas
        return new WebServer(logs, version)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private sharedService: SharedService
    private _fgdDb: DbService<DbProviderService>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method shutdown
     *********************************************************************************************/
    protected shutdown() {
        Promise.all([
            this._fgdDb.close()
        ]).then(
            () => {
                this._logs.log('Server: Successfully closed DBs')
                process.exit(0)
            },
            err => {
                this._logs.log(`Server: Error closing DB: ${err}`, Level.ERROR)
                process.exit(1)
            }
        )
    }

    /**********************************************************************************************
     * @method setup local setup function
     * @overrides
     *********************************************************************************************/
    protected setup(): void {
        this._fgdDb = DbService.createDbService(this._logs, BaseServerDb.schemas.fgd)
        this.sharedService = new SharedService(this.appId, this._fgdDb)
    }

    /**********************************************************************************************
     * @method api set up api
     * @overrides
     *********************************************************************************************/
    protected api(): void {
        super.api()

        this.app
            .use('/menus', MenuRouter.createFgdRouter(this._appId, this.sharedService.menuService))
            .use('/config', ConfigRouter.createRouter(this.appId, this.sharedService, this._fgdDb))
            .use('/questionnaires', QuestionnaireRouter.createRouter(this.sharedService, this.appId, this._fgdDb))
            .use('/questions', QuestionsRouter.createRouter(this.sharedService))
            .use('/entries', EntriesRouter.createRouter(this.sharedService, this._fgdDb))
            .use('/scores', ScoresRouter.createRouter(this.sharedService, this._fgdDb))
            .use('/sections', SectionsRouter.createRouter(this.sharedService))
            .use('/vintages', VintagesRouter.createRouter(this.appId, this._fgdDb))
            .use('/indices', IndicesRouter.createRouter(this._fgdDb, this.sharedService, this.appId))
            .use('/indexes', IndexesRouter.createRouter(this.sharedService, this._fgdDb, this.appId))
            .use('/admin', AdminRouter.createRouter(this.appId, this._fgdDb, this.sharedService))
    }

    /**********************************************************************************************
     * @method error set up error handler
     *********************************************************************************************/
    protected error(): void {
        this.app.use(this.errorHandler.bind(this))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method errorHandler
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/no-unused-vars */
    private errorHandler(err: any, req: Request, res: Response, next: NextFunction) {
        const error = `External service returned error: ${req.path} \n${err.toString()}`
        this._logs.log(error, Level.ERROR)
        res.status(err.statusCode || 500).send(err.error?.detail || err.error || error)
    }
}
