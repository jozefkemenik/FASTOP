export class ParamsService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Members /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method arrayParamUpper
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static arrayParamUpper(data: any): string[] {
        return ParamsService.arrayParam(data)?.map(v => v.toUpperCase())
    }

    /**********************************************************************************************
     * @method arrayParam
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static arrayParam(data: any): string[] {
        return typeof data === 'string' && data ? data.split(/[+ ,]/) : undefined
    }

    /**********************************************************************************************
     * @method stringParam
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static stringParam(data: any, defaultValue?: string): string {
        return typeof data === 'string' ? data : defaultValue
    }

    /**********************************************************************************************
     * @method stringParamUpper
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static stringParamUpper(data: any, defaultValue?: string): string {
        return (typeof data === 'string' ? data : defaultValue)?.toUpperCase()
    }

    /**********************************************************************************************
     * @method boolParamMatchValue
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static boolParamMatchValue(data: any, matchValue: string): boolean {
        return (data as string)?.toUpperCase() === matchValue
    }

    /**********************************************************************************************
     * @method numericParam
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static numericParam(data: any, defaultValue?: number): number {
        return data !== undefined ? Number(data) : defaultValue
    }

    /**********************************************************************************************
     * @method boolParam
     *********************************************************************************************/
    /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
    public static boolParam(data: any, defaultValue = false): boolean {
        return data !== undefined ? Number(data) === 1 : defaultValue
    }
}
