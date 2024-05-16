/**********************************************************************************************
 * @method buildQuery
 *********************************************************************************************/
export function buildQuery(queryObject: object): string {
    const query = Object.entries(queryObject ?? {})
        .filter(entry => entry[1])
        .reduce((acc, entry) => `${acc}&${entry[0]}=${entry[1]}`, '')
    return query ? `?${query.substring(1)}` : ''
}
