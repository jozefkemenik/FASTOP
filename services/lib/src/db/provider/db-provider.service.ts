import { Level, LoggingService } from '../../logging.service'
import { IDbConfig } from 'config'
import { ISPOptions } from '..'

export abstract class DbProviderService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        protected readonly logs: LoggingService,
        protected readonly config: IDbConfig,
    ) {
        this.createConnectionPool()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Accessors //////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    public abstract get dbName()

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method close clean up before closing
     *********************************************************************************************/
    public abstract close(): Promise<void>

    /**********************************************************************************************
     * @method storedProc call a stored procedure
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public abstract storedProc(name: string, options: ISPOptions): Promise<any>

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method createConnectionPool
     *********************************************************************************************/
    protected abstract createConnectionPool()

    /**********************************************************************************************
     * @method log avoids building messages which don't get logged eventually
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected log(skipLogs: boolean, level: number, ...messageParts: any[]): void {
        const adaptedLevel = skipLogs ? Level.NONE : level
        this.logs.log(
            adaptedLevel < this.logs.level
                ? ''
                : messageParts.reduce(
                    (acc: string, part) => {
                        let formatted: string
                        switch (typeof part) {
                            case 'string': formatted = part; break
                            case 'number': formatted = (Date.now() - part).toString() + ' ms'; break
                            default: formatted = JSON.stringify(part); break
                        }
                        return acc += formatted
                    },
                    ''
                ),
            adaptedLevel
        )
    }
}
