import { IDBAmecoChapter, IDBAmecoSerie, IDBCountry } from '.'
import { DbProviderService } from '../../../lib/dist/db/provider/db-provider.service'
import { DbService } from '../../../lib/dist/db/db.service'
import { IAmecoLastUpdate } from './shared-interfaces'
import { ISPOptions } from '../../../lib/dist/db'

export abstract class BaseAmecoService {

    public constructor(private dbService: DbService<DbProviderService>) {
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(): Promise<IDBCountry[]> {
        return this.execAmecoSP<IDBCountry[]>('getCountries', { params: [] })
    }

    /**********************************************************************************************
     * @method getNomSeries
     *********************************************************************************************/
    public async getNomSeries(): Promise<IDBAmecoSerie[]> {
        return this.execAmecoSP<IDBAmecoSerie[]>('getNomSeries', { params: [] })
    }

    /**********************************************************************************************
     * @method getChapters
     *********************************************************************************************/
    public async getChapters(): Promise<IDBAmecoChapter[]> {
        return this.execAmecoSP<IDBAmecoChapter[]>('getChapters', { params: [] })
    }

    /**********************************************************************************************
     * @method getLastUpdate
     *********************************************************************************************/
    public async getLastUpdate(): Promise<IAmecoLastUpdate> {
        return this.execAmecoSP<IAmecoLastUpdate>(
            'getLastUpdateInfo', {params: []}
        ).then(data => this.convertLastUpdate(data[0]))
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method execAmecoSP
     *********************************************************************************************/
    protected async execAmecoSP<T>(name: string, options: ISPOptions): Promise<T> {
        return this.dbService.storedProc(name, options)
    }

    /**********************************************************************************************
     * @method convertLastUpdate
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    protected abstract convertLastUpdate(data: any): IAmecoLastUpdate

    /**********************************************************************************************
     * @method convertToDate
     * @param data - date in mysql date format: dd/mm/yyyy-hh:MM, eg.30/11/2022-09:11
     *********************************************************************************************/
    protected convertToDate(data: string): Date {
        if (!data) return undefined

        const [date, time] = data.split('-')
        const [hours, minutes] = time.split(':').map(Number)
        const [day, month, year] = date.split('/').map(Number)

        return new Date(year, month - 1, day, hours, minutes)
    }
}
