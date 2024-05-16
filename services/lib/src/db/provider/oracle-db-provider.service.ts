import * as oracledb from 'oracledb'
import { DbType, getTypeByNum } from 'oracledb/lib/types'

import {
    BIND_IN,
    BIND_INOUT,
    BIND_OUT,
    BLOB,
    BUFFER,
    CURSOR,
    DATE,
    DB_TYPE_DATE,
    DB_TYPE_TIMESTAMP,
    ISPBaseParam,
    ISPOptions,
    ISPParam,
} from '..'
import { DbProviderService } from './db-provider.service'

import { IDbConfig, IOracleConfig } from 'config'
import { Level, LoggingService } from '../../logging.service'



export class OracleDbProviderService extends DbProviderService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        logs: LoggingService,
        config: IDbConfig,
    ) {
        super(logs, config)
        oracledb.initOracleClient()
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public get dbName(): string {
        const match = this.oracleConfig.connectString.match(/\/(.*)/)
        return match ? match[1] : this.oracleConfig.connectString
    }

    private get oracleConfig() {
        return this.config.providerConfig as IOracleConfig
    }

    private get poolAlias() {
        return this.oracleConfig.poolAlias
    }

    private get pool() {
        return oracledb.getPool(this.poolAlias)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method close clean up before closing
     *********************************************************************************************/
    public close(): Promise<void> {
        return this.pool.close(10)
    }

    /**********************************************************************************************
     * @method storedProc call a stored procedure
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async storedProc(name: string, options: ISPOptions): Promise<any> {
        const statement = this.createStatement(name, options.params)
        const bindings = this.prepareBindings(options.params)
        const executeOptions: oracledb.ExecuteOptions = this.prepareExecuteOptions(options)

        this.log(
            options.skipLogs,
            Level.DEBUG,
            `DBService: calling stored procedure '${statement}' with bindings `,
            bindings.debug,
        )

        let conn: oracledb.Connection
        try {
            const start = Date.now()

            conn = await this.getConnection()
            this.log(options.skipLogs, Level.DEBUG, `${name}: get connection - `, start)

            const result = await conn.execute(statement, bindings.values, executeOptions)
            this.log(options.skipLogs, Level.DEBUG, `${name}: execute statement - `, start)

            const values = await this.getValues(this.filterOutParams(options.params), result.outBinds, options.maxRows)
            this.log(options.skipLogs, Level.DEBUG, `${name}: get values - `, start)

            return values
        } catch (err) {
            this.logs.log('Unexpected DB error', Level.ERROR)
            throw err
        } finally {
            if (conn) await conn.close()
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getConnection
     *********************************************************************************************/
    protected async getConnection(): Promise<oracledb.Connection> {
        return this.pool.getConnection()
    }

    /**********************************************************************************************
     * @method createConnectionPool
     *********************************************************************************************/
    protected createConnectionPool() {
        try {
            this.logs.log(`OracleDbProviderService: reusing ${this.pool.poolAlias} pool`)
        } catch(ex) {
            // if the pool doesn't exist then create a new one
            oracledb.createPool(this.oracleConfig)
                .then(
                    pool => {
                        this.logs.log(
                            `OracleDbProviderService: Created pool ${pool.poolAlias} with max ${pool.poolMax} connections`
                        )
                    },
                    err => {
                        this.logs.log('OracleDbProviderService: Error creating connection pool', Level.ERROR)
                        this.logs.log(`Failed to create pool for config: ${JSON.stringify(this.oracleConfig)}`)
                        throw err
                    }
                )
        }
    }

    /**********************************************************************************************
     * @method prepareParamValue
     *********************************************************************************************/
    protected prepareParamValue(param: ISPParam, isBlob: boolean) {
        if (isBlob) return Buffer.from(param.value as Buffer)

        switch(param.type) {
            case DATE:
            case DB_TYPE_DATE:
            case DB_TYPE_TIMESTAMP:
                return Array.isArray(param.value)
                    ? (param.value as string[]).map(value => new Date(value))
                    : new Date(param.value as string)
        }
        return param.value
    }

    /**********************************************************************************************
     * @method prepareBindings
     *********************************************************************************************/
    protected prepareBindings(params: ISPParam[]) {
        return params.reduce((acc, param) => {
            const isBlob = param.type === BLOB || param.type === BUFFER
            acc.values[param.name] = {
                dir: param.dir || BIND_IN,
                type: this.getOracleDbType(param.type),
                val: this.prepareParamValue(param, isBlob)
            }
            acc.debug.push(
                isBlob ? Object.assign({}, acc.values[param.name], {val: '[Blob data]'}) : acc.values[param.name]
            )
            return acc
        }, { values: {}, debug: [] })
    }

    /**********************************************************************************************
     * @method prepareExecuteOptions
     *********************************************************************************************/
    protected prepareExecuteOptions(options: ISPOptions): oracledb.ExecuteOptions {
        return {
            outFormat: options.arrayFormat ? oracledb.OUT_FORMAT_ARRAY : oracledb.OUT_FORMAT_OBJECT,
            maxRows: options.maxRows,
            fetchTypeHandler: (metadata) => {
                if (options.fetchInfo && options.fetchInfo[metadata.name]) {
                    return { type: this.getOracleDbType(options.fetchInfo[metadata.name].type) }
                }
            },
            autoCommit: true,
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getOracleDbType
     *********************************************************************************************/
    private getOracleDbType(dbTypeCode: number | string): DbType {
        return typeof(dbTypeCode) === 'number' ? getTypeByNum(dbTypeCode) : dbTypeCode
    }

    /**********************************************************************************************
     * @method createStatement
     *********************************************************************************************/
    private createStatement(name: string, params: ISPBaseParam[]): string {
        const inlineParams = params.map(p => `:${p.name}`).join(', ')
        return `BEGIN ${name}(${inlineParams}); END;`
    }

    /**********************************************************************************************
     * @method filterOutParams
     *********************************************************************************************/
    private filterOutParams(params: ISPParam[]): ISPBaseParam[] {
        return params.filter( param => param.dir === BIND_OUT || param.dir === BIND_INOUT )
    }

    /**********************************************************************************************
     * @method getValues
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    private async getValues(outParams: ISPBaseParam[], outBinds: any, maxRows = this.config.maxRows): Promise<any> {
        const values = {}
        for (const param of outParams) {
            const outBind = outBinds[param.name]
            if (outBind && param.type === CURSOR) {
                /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
                let rows: any[]
                values[param.name] = []
                do {
                    // get maxRows rows at a time
                    rows = await outBind.getRows(maxRows)
                    values[param.name] = values[param.name].concat(rows)
                } while (rows.length === maxRows)
                await outBind.close()
            } else {
                values[param.name] = outBind
            }
        }
        return values
    }

}