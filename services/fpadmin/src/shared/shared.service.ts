import { IDBNameValue, ILabelValue } from './shared-interfaces'

export class SharedService {

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Static Methods /////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    /**********************************************************************************************
     * @method mapCollectionToLabelValue
     *********************************************************************************************/
    public static mapCollectionToLabelValue(collection: IDBNameValue[]): ILabelValue[] {
        return collection.map(item => ({ label: item.NAME, value: item.VALUE }))
    }
}
