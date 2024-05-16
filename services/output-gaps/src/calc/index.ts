import { IVector } from '../../../lib/dist/fisc/shared/calc'

export interface ICalculatedIndicators {
    [key: string]: IVector
}

export interface ICalcParams {
    changey: number
    vintageName: string
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    baseline: any[]
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    countryParams: any[]
}
