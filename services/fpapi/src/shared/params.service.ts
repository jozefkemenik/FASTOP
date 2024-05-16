import { EOutputFormat, EProvider, IDatePeriod, IFrequency, IPeriodInfo } from './shared-interfaces'
import { BadRequestError } from './errors'


export class ParamsService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly PERIODS: { [freq: string]: IPeriodInfo} = {
        A: { regexp: /^(\d{4})$/, months: 12 },
        S: { regexp: /^(\d{4})-S([1-2])$/, months: 6 },
        Q: { regexp: /^(\d{4})-?Q([1-4])$/, months: 3 },
        M: { regexp: /^(\d{4})[-M]{1,2}(\d{1,2})$/, months: 1 },
        D: { regexp: /^(\d{4})-(\d{1,2})-(\d{1,2})$/, months: 1 },
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method parseDate
     * Valid date formats:
     * - `YYYY` - annual, e.g. 1998
     * - `YYYY-S[1-2]` - semester, e.g. 1992-S1
     * - `YYYY-Q[1-4]` - quarter, e.g. 2010-Q3
     * - `YYYY-M[01-12] or YYYY-[01-12]` - monthly, e.g. 2001-M01, 2010-08
     * - `YYYY-[01-12]-[01-31]` - daily, e.g. 2023-07-30
     *********************************************************************************************/
    public static parseDate(raw: string): IDatePeriod {
        if (!raw) return undefined

        const freq: IFrequency = Object.keys(ParamsService.PERIODS).find(
            key => raw.match(ParamsService.PERIODS[key].regexp) !== null
        )

        if (!freq) throw new BadRequestError(`Unknown date period: ${raw}!`)

        const match: RegExpMatchArray = raw.match(ParamsService.PERIODS[freq].regexp)
        if (!match || match.length < 2) throw new BadRequestError(`Unknown date period: ${ raw }!`)


        const year = Number(match[1])
        const day = freq === 'D' ? Number(match[3]) : 1
        const month = freq === 'A' ? 0 : Number(match[2]) - 1

        if (day > 31) throw new BadRequestError(`Invalid number of days: ${day}, period: ${raw}!`)
        if (month > 11) throw new BadRequestError(`Invalid month number: ${month + 1}, period: ${raw}!`)

        return {
            raw,
            freq,
            date: new Date(year, ParamsService.PERIODS[freq].months * month, day),
        }
    }

    /**********************************************************************************************
     * @method parseFormat
     *********************************************************************************************/
    public static parseFormat(raw: string): EOutputFormat {
        return ParamsService.parseEnum<EOutputFormat>(raw, EOutputFormat) || EOutputFormat.JSON
    }

    /**********************************************************************************************
     * @method parseBoolean
     *********************************************************************************************/
    public static parseBoolean(data: unknown, defaultValue = false): boolean {
        return data !== undefined ? data === 'true' || Number(data) === 1 : defaultValue
    }

    /**********************************************************************************************
     * @method parseProvider
     *********************************************************************************************/
    public static parseProvider(provider: string): EProvider {
        return ParamsService.parseEnum<EProvider>(provider, EProvider)
    }

    /**********************************************************************************************
     * @method parseEnum
     *********************************************************************************************/
    public static parseEnum<T>(raw: string, enumType: unknown): T {
        const valueToType: { [key: string]: T} = Object.keys(enumType).reduce(
            (acc, key) => (acc[enumType[key].toLowerCase()] = enumType[key], acc), {}
        )
        return valueToType[raw?.toLowerCase()]
    }
}
