import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { ISPOptions} from '../../../lib/dist/db'

export class FgdDbService {

    public constructor(public dbService: DbService<DbProviderService>) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method execSP
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public  execSP(sp: string, options: ISPOptions): Promise<any> {
        return this.dbService.storedProc(sp, options)
    }
}
