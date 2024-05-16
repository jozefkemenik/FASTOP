import * as oracledb from 'oracledb'

import { ISPBaseParam, ISPOptions } from '../../../lib/dist/db'
import { Level } from '../../../lib/dist'
import { OracleDbProviderService } from '../../../lib/dist/db/provider/oracle-db-provider.service'

import { EStatementTypes } from '.'

export class SumDbService extends OracleDbProviderService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method execStat executes custom statement
     *********************************************************************************************/
    public async execStat(type: EStatementTypes,
        target: string,
        condition: string,
        /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
        options: ISPOptions): Promise<any> {
            const statement = this.createCustomStatement(type, options.params, target, condition)
            const bindings = this.prepareBindings(options.params)
            const executeOptions: oracledb.ExecuteOptions = Object.assign(
                super.prepareExecuteOptions(options),
                { autoCommit: type === EStatementTypes.INSERT, }
            )

            this.log(
                options.skipLogs,
                Level.DEBUG,
                `DBService: executing '${statement}' with bindings `,
                bindings.debug,
            )

            let conn: oracledb.Connection
            try {
                conn = await this.getConnection()

                const result = await conn.execute(statement, bindings.values, executeOptions)

                if (type === EStatementTypes.INSERT) {
                    return result.rowsAffected ? result.rowsAffected : 0
                } else {
                    return result.rows
                }
            } catch (err) {
                this.logs.log('Unexpected DB error', Level.ERROR)
                return -1
            } finally {
                if (conn) await conn.close()
            }
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createCustomStatement
     *********************************************************************************************/
    private createCustomStatement(
        statementType: string,
        params: ISPBaseParam[],
        target: string,
        condition?: string): string {
        const tabParams = params.map(p => `${p.name}`).join(', ')
        const inlineParams = params.map(p => `:${p.name}`).join(', ')
        const whereParams = params.map(p => ` ${p.name} = :${p.name}`).join(' AND ')
        switch(statementType) {
            case EStatementTypes.INSERT: return ` INSERT INTO ${target}(${tabParams}) VALUES (${inlineParams})`
            case EStatementTypes.SELECT: return condition ? `SELECT * FROM ${target}` +
                ` WHERE ${whereParams}` : `SELECT ${tabParams} FROM ${target}`
        }
    }

}
