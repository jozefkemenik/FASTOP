import { EDbProviders, IDbConfig } from 'config'
import { LoggingService } from '../logging.service'

import { DbProviderService } from './provider/db-provider.service'
import { ISPOptions } from '.'
import { MysqlDbProviderService } from './provider/mysql-db-provider.service'
import { OracleDbProviderService } from './provider/oracle-db-provider.service'

export class DbService<P extends DbProviderService> {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public static createDbService(logs: LoggingService, schema: IDbConfig) {
        let providerService: DbProviderService
        switch (schema.provider) {
            case EDbProviders.ORACLE:
                providerService = new OracleDbProviderService(logs, schema)
                break
            case EDbProviders.MYSQL:
                providerService = new MysqlDbProviderService(logs, schema)
                break
            default: throw new Error('Invalid DB provider in createDbService')
        }
        return new DbService<DbProviderService>(providerService)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    protected constructor(private readonly providerService: P) {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method close clean up before closing
     *********************************************************************************************/
    public close(): Promise<void> {
        return this.providerService.close()
    }

    /**********************************************************************************************
     * @method storedProc call a stored procedure
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public async storedProc(name: string, options: ISPOptions): Promise<any> {
        return this.providerService.storedProc(name, options)
    }

    /**********************************************************************************************
     * @method getDbName
     *********************************************************************************************/
    public getDbName(): string {
        return this.providerService.dbName
    }
}
