import { IAmecoChapter, IAmecoSerie, IAmecoSeriesData } from './shared-interfaces'
import { AmecoType } from '../../../shared-lib/dist/prelib/ameco'
import { ExternalDataApi } from '../api'
import { ICountry } from '../addin/shared-interfaces'

export class LibAmecoService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getCountries
     *********************************************************************************************/
    public async getCountries(amecoType: AmecoType): Promise<ICountry[]> {
        return ExternalDataApi.getAmecoCountries(amecoType)
    }

    /**********************************************************************************************
     * @method getSeries
     *********************************************************************************************/
    public async getSeries(amecoType: AmecoType): Promise<IAmecoSerie[]> {
        return ExternalDataApi.getAmecoSeries(amecoType)
    }

    /**********************************************************************************************
     * @method getChapters
     *********************************************************************************************/
    public async getChapters(amecoType: AmecoType): Promise<IAmecoChapter[]> {
        return ExternalDataApi.getAmecoChapters(amecoType)
    }

    /**********************************************************************************************
     * @method getAmecoSeriesData
     *********************************************************************************************/
    public async getAmecoSeriesData(amecoType: AmecoType, countries: string, series: string): Promise<IAmecoSeriesData[]> {
        return ExternalDataApi.getAmecoSeriesData(amecoType, countries, series)
    }

}
