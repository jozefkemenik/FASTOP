import { Pool, createPool } from 'mysql2/promise'

import { ISPBaseParam, ISPOptions } from '..'
import { DbProviderService } from './db-provider.service'
import { IMySqlConfig } from 'config'
import { Level } from '../../logging.service'

export class MysqlDbProviderService extends DbProviderService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Instance Members ///////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private _pool: Pool

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get dbName(): string {
        return this.mysqlConfig.database
    }

    private get mysqlConfig() {
        return this.config.providerConfig as IMySqlConfig
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method close clean up before closing
     *********************************************************************************************/
    public close(): Promise<void> {
        return this._pool.end()
    }

    /**********************************************************************************************
     * @method storedProc call a stored procedure
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async storedProc(name: string, options: ISPOptions): Promise<any> {
        const statement = this.createStatement(name, options.params)
        const bindings = options.params.map(p => p.value)

        this.log(
            options.skipLogs,
            Level.DEBUG,
            `DBService: calling stored procedure '${statement}' with bindings `,
            bindings,
        )

        try {
            const start = Date.now()

            /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
            const [[data, stats], fields] = await this._pool.execute(statement, bindings)
            this.log(options.skipLogs, Level.DEBUG, `${name}: execute statement - `, start)

            return data
        } catch (err) {
            this.logs.log('Unexpected DB error', Level.ERROR)
            throw err
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createConnectionPool
     *********************************************************************************************/
    protected createConnectionPool() {
        try {
            this._pool = createPool(this.mysqlConfig)
            this.logs.log(
                `MysqlDbProviderService: Created pool with max ${this.mysqlConfig.connectionLimit} connections`
            )
        } catch(ex) {
            this.logs.log('MysqlDbProviderService: Error creating connection pool', Level.ERROR)
            throw ex
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createStatement
     *********************************************************************************************/
    private createStatement(name: string, params: ISPBaseParam[]): string {
        const inlineParams = params.map(() => `?`).join(', ')
        return `call ${name}(${inlineParams});`
    }
}
