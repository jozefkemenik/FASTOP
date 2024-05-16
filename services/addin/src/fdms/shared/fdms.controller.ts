import { ICompressedData, IIndicator, IIndicatorCodeMapping } from '../../../../fdms/src/report/shared-interfaces'
import { DashboardApi } from '../../../../lib/dist/api/dashboard.api'
import { FdmsApi } from '../../../../lib/dist/api/fdms.api'
import { ICountry } from '../../../../lib/dist/addin/shared-interfaces'
import { IFdmsAddinData } from './shared-interfaces'
import { IRoundStorage } from '../../../../dashboard/src/config/shared-interfaces'


export class FdmsController {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getProviderCountries
     *********************************************************************************************/
    public async getProviderCountries(providerIds: string[]): Promise<ICountry[]> {
        return FdmsApi.getProviderCountries(providerIds).then(
            countries => countries.map(c => ({ COUNTRY_ID: c.COUNTRY_ID, NAME: c.DESCR }))
        )
    }

    /**********************************************************************************************
     * @method getProviderIndicators
     *********************************************************************************************/
    public async getProviderIndicators(providerIds: string[], periodicity: string): Promise<IIndicator[]> {
        return FdmsApi.getProviderIndicators(providerIds, periodicity)
    }

    /**********************************************************************************************
     * @method getFdmsIndicatorsMappings
     *********************************************************************************************/
    public async getFdmsIndicatorsMappings(
        providerIds: string[], periodicity: string
    ): Promise<IIndicatorCodeMapping[]> {
        return FdmsApi.getFdmsIndicatorsMappings(providerIds, periodicity)
    }

    /**********************************************************************************************
     * @method getProviderData
     *********************************************************************************************/
    public async getProviderData(
        providerIds: string[], countries: string[], indicators: string[], periodicity: string, startPeriod: string,
        roundSid: number, storageSid: number, textSid: number
    ): Promise<IFdmsAddinData> {

        return this.getData(
            FdmsApi.getProviderDataCompressed(
                providerIds, periodicity, countries, indicators, roundSid, storageSid, textSid,
            ),
            startPeriod, roundSid, storageSid, textSid
        )
    }

    /**********************************************************************************************
     * @method getProviderDataByKeys
     * keys are in format: <country_code>.<indicator_code>.<trn>.<agg>.<unit>.<ref>.<freq>
     *********************************************************************************************/
    public async getProviderDataByKeys(
        providerIds: string[], keys: string[], startPeriod: string,
        roundSid: number, storageSid: number, textSid: number
    ): Promise<IFdmsAddinData> {

        return this.getData(
            FdmsApi.getProviderDataByKeysCompressed(
                providerIds,
                keys,
                roundSid,
                storageSid,
                textSid,
            ),
            startPeriod, roundSid, storageSid, textSid
        )
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method convertToAddinData
     *********************************************************************************************/
    protected convertToAddinData(
        startPeriod: string, data: ICompressedData, roundStorage: IRoundStorage
    ): IFdmsAddinData {
        let result = undefined
        if (data && data.data?.length) {

            const startYearIndex = data.columns.findIndex(c => c.name === 'START_YEAR')
            const minYear = Math.min(...data.columns[startYearIndex].dictionary.map(Number))
            const freq = data.columns.find(c => c.name === 'PERIODICITY_ID').dictionary[0]
            let startDate = new Date(minYear, 0, 1)

            if (startPeriod || data.columns[startYearIndex].dictionary.length > 1) {
                if (startPeriod) startDate = this.periodToDate(startPeriod, freq)
                const multiplier = freq === 'M' ? 12 : (freq === 'Q' ? 4 : 1)
                const startPeriodIndex = startDate.getFullYear() * multiplier +
                    (freq === 'A' ? 0 :
                        (freq === 'M' ? startDate.getMonth() + 1 : Math.ceil((startDate.getMonth() + 1)/ 3))
                    )
                const vectorIndex = data.columns.findIndex(c => c.timeserie)

                for(const raw of data.data) {
                    const rawStartYear = Number(data.columns[startYearIndex].dictionary[raw[startYearIndex]])
                    const rawPeriodIndex = rawStartYear * multiplier + (freq === 'A' ? 0 : 1)
                    const diff = startPeriodIndex - rawPeriodIndex
                    let vector = raw[vectorIndex].split(',')
                    if (diff < 0) {
                        // add empty data to the beginning of the vector
                        vector = Array.from({ length: Math.abs(diff) }, () => '').concat(vector)
                    } else if (diff > 0) {
                        // cut the vector
                        vector = vector.slice(diff)
                    }
                    // set the new start period (there will be only one in the dictionary!)
                    raw[startYearIndex] = 0
                    raw[vectorIndex] = vector.join(',')
                }
            }

            data.columns[startYearIndex].name = 'START_PERIOD'
            data.columns[startYearIndex].dictionary = [this.dateToPeriod(startDate, freq)]

            result = {
                roundStorage,
                data,
            }
        }

        return result
    }

    /**********************************************************************************************
     * @method periodToDate
     *********************************************************************************************/
    protected periodToDate(period: string, freq: Freq): Date {
        if (freq === 'A') return new Date(Number(period), 0, 1)
        const [year, periodCount] = period.replace('-', '').split(freq).map(Number)
        return new Date(year, periodCount * (freq === 'Q' ? 3 : 1) - 1, 1 )
    }

    /**********************************************************************************************
     * @method dateToPeriod
     *********************************************************************************************/
    protected dateToPeriod(date: Date, freq: string): string {
        const m = date.getMonth() + 1
        const suffix = freq === 'M' ? `M${m < 10 ? '0': ''}${m}` :
                       freq === 'Q' ? `Q${Math.ceil(m / 3)}` : ''
        return `${date.getFullYear()}${suffix}`
    }

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    protected async getData(
        dataPromise: Promise<ICompressedData>, startPeriod: string,
        roundSid: number, storageSid: number, textSid: number
    ): Promise<IFdmsAddinData> {
        return Promise.all([
            dataPromise,
            DashboardApi.getRoundStorage(roundSid, storageSid, textSid),
        ]).then(
            ([data, roundStorage]) => this.convertToAddinData(
                startPeriod, data, roundStorage
            )
        )
    }
}

type Freq = 'A' | 'Q' | 'M'
