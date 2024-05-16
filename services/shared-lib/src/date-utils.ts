
/**********************************************************************************************
 * @method dateToPeriod
 *********************************************************************************************/
export function dateToPeriod(date: Date, freq: string): string {
    const year = `${date.getFullYear()}`
    const month = `${ (date.getMonth() + 1).toString().padStart(2, '0') }`
    switch (freq) {
        case 'A':
            return year
        case 'M':
            return `${year}-${month}`
        case 'D':
            return `${year}-${month}-${(date.getDate()).toString().padStart(2, '0')}`
        case 'Q':
            return `${year}-Q${Math.floor(date.getMonth() / 3) + 1}`
        case 'S':
            return `${year}-S${Math.floor(date.getMonth() / 6) + 1}`
        case 'B':
            return `${year}-B${Math.floor(date.getMonth() / 2) + 1}`
        case 'W': {
            const firstDayOfYear = new Date(date.getFullYear(), 0, 1)
            const pastDaysOfYear = (date.getTime() - firstDayOfYear.getTime()) / 86400000
            const week = Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7)
            return `${year}-W${week.toString().padStart(2, '0')}`
        }
        default:
            throw Error(`Cannot convert date to period! Unknown frequency: ${freq}`)
    }
}
