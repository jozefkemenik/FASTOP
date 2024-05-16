export const enum EFastopStorages {
    FIRST = 'FIRST',
    SECOND = 'SECOND',
    FINAL = 'FINAL',
    CUSTOM = 'CUST',
    TCE1 = 'TCE1',
    TCE3 = 'TCE3',
    TCE5 = 'TCE5',
}

/**********************************************************************************************
 * @method isMeasureDataOneOffReady
 *********************************************************************************************/
export function isMeasureDataOneOffReady(data: number[]): boolean {
    if (!data) return true

    // filter non zero values only
    const values = data.map((d, idx) => [d, idx]).filter(pair => pair[0])

    return values.length === 0 ||    // ok if all zeroes
        (    // or 2 values in consecutive years summing up to zero
            values.length === 2 &&
            values[0][0] + values[1][0] === 0 &&
            values[1][1] - values[0][1] === 1
        )
}
