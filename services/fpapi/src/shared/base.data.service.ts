import { EProvider, IDatePeriod, IFpapiParams, IOutput } from './shared-interfaces'
import { BadRequestError } from './errors'
import { BaseFormatter } from './formatters/base.formatter'
import { LoggingService } from '../../../lib/dist'

export abstract class BaseDataService {

    protected formatters: { [formatter: string]: BaseFormatter<unknown, unknown> } = {}

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Constructor ////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    constructor(protected logs: LoggingService) {
        this.registerOutputFormatters()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Public Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method getData
     *********************************************************************************************/
    public abstract getData(provider: EProvider, params: IFpapiParams): Promise<IOutput>

    /**********************************************************************************************
     * @method getSupportedProviders
     *********************************************************************************************/
    public abstract getSupportedProviders(): string[]

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Protected Methods //////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method registerOutputFormatters output formatters
     *********************************************************************************************/
    // eslint-disable-next-line @typescript-eslint/no-empty-function
    protected registerOutputFormatters(): void {
    }

    /**********************************************************************************************
     * @method formatDatePeriod
     * Providers support different date periods. Format timestamp to valid string representation.
     *********************************************************************************************/
    protected abstract formatDatePeriod(provider: EProvider, period: IDatePeriod): string

    /**********************************************************************************************
     * @method getFormatter
     *********************************************************************************************/
    protected getFormatter(format: string): BaseFormatter<unknown, unknown> {
        const formatter = this.formatters[format]
        if (!formatter) throw new BadRequestError(`Unsupported format type: ${format}!`)
        return formatter
    }
}
