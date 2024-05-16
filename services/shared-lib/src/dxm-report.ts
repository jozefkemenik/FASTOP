import { IStandardReport } from './prelib/report'

/**********************************************************************************************
 * @method roundMeasure
 * Round the data according to isGdp flag.
 *********************************************************************************************/
export function roundMeasure(value: number, isGdp = false): number {
    if (value === null || isNaN(value)) return NaN
    const rounding = isGdp ? 100 : 10
    return Math.round(value * rounding) / rounding
}

/**********************************************************************************************
 * @method sumTotalImpact
 * @param value - numeric data to be processed
 * @param isOneOff - indicates 'One-Off' impact data type
 * @param isGdp - indicates GDP flag
 * @param startIndex - indicates the starting index for calculation of the sum
 * @param onCalculatedValue - callback function to be executed when new sum is calculated
 * @return 'true' if sum not empty
 *********************************************************************************************/
export function sumTotalImpact(
    values: number[],
    isOneOff: boolean,
    isGdp: boolean,
    startIndex: number,
    onCalculatedValue: ((newValue: number, index: number) => void)
): boolean {
    let sum = 0
    let isEmpty = true
    const sumFromIndex = startIndex >= 0 ? startIndex : 0
    const precisionFactor = 1000
    values.forEach((val, idx) => {
        if (isOneOff || idx >= sumFromIndex) {
            sum += val * precisionFactor
        }
        const calculatedValue = isOneOff && idx < sumFromIndex ? 0 : roundMeasure((sum / precisionFactor), isGdp)
        if (calculatedValue !== 0) {
            isEmpty = false
        }
        onCalculatedValue(calculatedValue, idx)
    })

    return !isEmpty
}

/**********************************************************************************************
 * @function calculateTotalResidual
 * Calculate total residual values
 * measure vectors and gdp should be normalized to the same length and start_year
 *********************************************************************************************/
export function calculateTotalResidual<M extends IStandardReport>(
    measures: M[],
    gdp: number[],
    multi: number,
    isSelected: (measure: M) => boolean
) {
    const raw = measures.reduce((acc, m) => {
        if (isSelected(m)) {
            m.dataWithoutGDP.forEach((x, idx) => {
                acc[idx] = (acc[idx] || 0) + x
            })
        }
        return acc
    }, [])

    return {
        raw,
        gdp: raw.map((value, idx) => {
            if (!isNaN(gdp[idx])) {
                return ((value / multi) / gdp[idx]) * 100
            } else {
                return 0
            }
        })
    }
}
