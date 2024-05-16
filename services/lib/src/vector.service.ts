export class VectorService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method normaliseVector
     *********************************************************************************************/
    public static normaliseVector(
        normalisedStartYear: number,
        normalisedVectorLength: number,
        entriesPerYear: number,
        vectorStartYear: number,
        vector: number[],
    ): number[] {
        const startDiff = (normalisedStartYear - vectorStartYear) * entriesPerYear
        vector.splice(0, startDiff, ...Array(Math.max(0, -startDiff)).fill(NaN))

        const lengthDiff = normalisedVectorLength - vector.length
        vector.splice(normalisedVectorLength, 999, ...Array(Math.max(0, lengthDiff)).fill(NaN))

        return vector
    }

    /**********************************************************************************************
     * @method normaliseVectorStart
     *********************************************************************************************/
    public static normaliseVectorStart(
        periodicity: string, minStartYear: number, vectorStartYear: number, vector: number[]
    ): number[] {
        if (minStartYear === vectorStartYear) return vector

        const entriesPerYear = VectorService.getEntriesPerYear(periodicity)
        const length = (vectorStartYear - minStartYear) * entriesPerYear
        return Array.from({length}, () => NaN).concat(vector)
    }

    /**********************************************************************************************
     * @method stringToVector
     *********************************************************************************************/
    public static stringToVector(data: string): number[] {
        return data ? data.split(',').map(
            value => value === null || value === undefined || value.trim() === '' ? NaN : Number(value)
        ) : []
    }

    /**********************************************************************************************
     * @method getEntriesPerYear
     *********************************************************************************************/
    private static getEntriesPerYear(periodicity: string): number {
        switch (periodicity) {
            case 'A': return 1
            case 'S': return 2
            case 'Q': return 4
            case 'M': return 12
            default: throw Error(`Not supported periodicity: ${periodicity}!`)
        }
    }
}
