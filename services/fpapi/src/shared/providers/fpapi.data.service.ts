import { EOutputFormat, EProvider, IDatePeriod, IFpapiParams, IOutput } from '../shared-interfaces'
import { BadRequestError } from '../errors'
import { BaseDataService } from '../base.data.service'
import { BaseFormatter } from '../formatters/base.formatter'
import { SdmxApi } from '../../../../lib/dist/api'
import { SdmxCsvFormatter } from '../formatters/sdmx-csv.formatter'
import { SdmxJsonFormatter } from '../formatters/sdmx-json.formatter'

export class FpapiDataService extends BaseDataService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly MILISECONDS_IN_DAY = 1000 * 60 * 60 * 24.0

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    public async getData(provider: EProvider, params: IFpapiParams): Promise<IOutput> {
        const formatter: BaseFormatter<unknown, unknown> = this.getFormatter(params.format)
        if (!formatter) throw new BadRequestError(`Unsupported format type: ${params.format}!`)
        return SdmxApi.getFpapiData(
            provider, params.dataset, params.query,
            this.formatDatePeriod(provider, params.startPeriod),
            this.formatDatePeriod(provider, params.endPeriod),
            params.obsFlags
        ).then(data => formatter.format(data, params))
    }

    /**********************************************************************************************
     * @method getSupportedProviders
     *********************************************************************************************/
    public getSupportedProviders(): string[] {
        return [EProvider.EUROSTAT, EProvider.ECB, EProvider.BCS, EProvider.ECFIN]
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method registerOutputFormatters
     *********************************************************************************************/
    protected registerOutputFormatters(): void {
        this.formatters[EOutputFormat.JSON] = new SdmxJsonFormatter()
        this.formatters[EOutputFormat.SDMX_CSV] = new SdmxCsvFormatter()
    }

    /**********************************************************************************************
     * @method formatDatePeriod
     * Providers support different date periods. Format timestamp to valid string representation.
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-unused-vars */
    protected formatDatePeriod(provider: EProvider, period: IDatePeriod): string {
        if (!period) return undefined

        const { freq, date } = period
        const year = `${date.getFullYear()}`

        switch (freq) {
            case 'A': return `${year}`
            case 'S': return `${year}-S${Math.floor(date.getMonth() / 6) + 1}`
            case 'Q': return `${year}-Q${Math.floor(date.getMonth() / 3) + 1}`
            case 'M': return `${year}-${(date.getMonth() + 1).toString().padStart(2, '0')}`
            case 'D': return `${year}-${this.getDayOfYear(date).toString().padStart(3, '0')}`
            default: return undefined
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Private Methods ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getDayOfYear
     *********************************************************************************************/
    private getDayOfYear(date: Date): number {
        return Math.ceil(
            (date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / FpapiDataService.MILISECONDS_IN_DAY
        )
    }
}
